package com.example.enutritrack_app.data.remote.api

import com.example.enutritrack_app.data.remote.dto.*
import retrofit2.Response
import retrofit2.http.*

/**
 * API Service para endpoints relacionados con alertas
 * 
 * Nota: Todos los endpoints están en el servidor principal (puerto 4000)
 * Base URL: ApiConfig.BASE_URL_SERVER
 * 
 * Endpoints disponibles:
 * - GET /alertas/usuario/{userId} - Obtiene alertas de un usuario
 * - GET /alertas/{id} - Obtiene una alerta por ID
 * - GET /tipos-alerta - Catálogo de tipos de alerta
 * - GET /categorias-alerta - Catálogo de categorías
 * - GET /niveles-prioridad-alerta - Catálogo de niveles de prioridad
 * - GET /estados-alerta - Catálogo de estados
 */
interface AlertsApiService {

    /**
     * Obtiene todas las alertas de un usuario
     * Endpoint: GET /alertas/usuario/{userId}
     * Servidor: Principal (puerto 4000)
     */
    @GET("alertas/usuario/{userId}")
    suspend fun getAlertsByUser(
        @Path("userId") userId: String
    ): Response<List<AlertaResponse>>

    /**
     * Obtiene una alerta por ID
     * Endpoint: GET /alertas/{id}
     * Servidor: Principal (puerto 4000)
     */
    @GET("alertas/{id}")
    suspend fun getAlertById(
        @Path("id") id: String
    ): Response<AlertaResponse>

    // ========== CATÁLOGOS (SOLO LECTURA) ==========
    // Todos los catálogos están en el servidor principal (puerto 4000)

    /**
     * Obtiene todos los tipos de alerta
     * Endpoint: GET /tipos-alerta
     * Servidor: Principal (puerto 4000)
     */
    @GET("tipos-alerta")
    suspend fun getTiposAlerta(): Response<List<TipoAlertaResponse>>

    /**
     * Obtiene todas las categorías de alerta
     * Endpoint: GET /categorias-alerta
     * Servidor: Principal (puerto 4000)
     */
    @GET("categorias-alerta")
    suspend fun getCategoriasAlerta(): Response<List<CategoriaAlertaResponse>>

    /**
     * Obtiene todos los niveles de prioridad de alerta
     * Endpoint: GET /niveles-prioridad-alerta
     * Servidor: Principal (puerto 4000)
     */
    @GET("niveles-prioridad-alerta")
    suspend fun getNivelesPrioridadAlerta(): Response<List<NivelPrioridadAlertaResponse>>

    /**
     * Obtiene todos los estados de alerta
     * Endpoint: GET /estados-alerta
     * Servidor: Principal (puerto 4000)
     */
    @GET("estados-alerta")
    suspend fun getEstadosAlerta(): Response<List<EstadoAlertaResponse>>
}

