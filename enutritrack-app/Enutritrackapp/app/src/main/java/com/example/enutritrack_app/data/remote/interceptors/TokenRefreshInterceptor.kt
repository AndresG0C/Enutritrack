package com.example.enutritrack_app.data.remote.interceptors

import android.content.Context
import com.example.enutritrack_app.config.ApiConfig
import com.example.enutritrack_app.data.local.SecurityManager
import com.example.enutritrack_app.data.remote.api.AuthApiService
import com.example.enutritrack_app.data.remote.dto.RefreshTokenRequest
import com.google.gson.Gson
import kotlinx.coroutines.runBlocking
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.IOException

/**
 * Interceptor que renueva automáticamente el token cuando expira (401)
 */
class TokenRefreshInterceptor(private val context: Context) : Interceptor {

    private val securityManager = SecurityManager(context)

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        var response = chain.proceed(request)

        // Si recibimos 401, intentar renovar el token
        if (response.code == 401 && !request.url.encodedPath.contains("auth/")) {
            val refreshToken = securityManager.getRefreshToken()
            
            if (refreshToken != null) {
                synchronized(this) {
                    // Verificar nuevamente después del lock
                    if (response.code == 401) {
                        try {
                            // Crear un Retrofit temporal para renovar token
                            val retrofit = Retrofit.Builder()
                                .baseUrl(ApiConfig.BASE_URL_AUTH)
                                .client(OkHttpClient())
                                .addConverterFactory(GsonConverterFactory.create(Gson()))
                                .build()
                            
                            val authService = retrofit.create(AuthApiService::class.java)
                            val refreshResponse = runBlocking {
                                authService.refreshToken(
                                    RefreshTokenRequest(refreshToken)
                                )
                            }

                            if (refreshResponse.isSuccessful && refreshResponse.body() != null) {
                                val loginResponse = refreshResponse.body()!!
                                // Guardar nuevos tokens
                                securityManager.saveAccessToken(loginResponse.accessToken)
                                securityManager.saveRefreshToken(loginResponse.refreshToken)
                                securityManager.saveUserInfo(
                                    loginResponse.user.id,
                                    loginResponse.user.email,
                                    loginResponse.user.nombre,
                                    loginResponse.user.userType
                                )
                                
                                // Reintentar request original con nuevo token
                                val newRequest = request.newBuilder()
                                    .header("Authorization", "Bearer ${loginResponse.accessToken}")
                                    .build()
                                response.close()
                                response = chain.proceed(newRequest)
                            } else {
                                // Refresh falló, limpiar tokens y forzar logout
                                securityManager.clearAll()
                            }
                        } catch (e: Exception) {
                            // Error al renovar, limpiar tokens
                            securityManager.clearAll()
                        }
                    }
                }
            } else {
                // No hay refresh token, limpiar todo
                securityManager.clearAll()
            }
        }

        return response
    }
}
