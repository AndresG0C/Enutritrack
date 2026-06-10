package com.example.enutritrack_app.data.remote.api

import com.example.enutritrack_app.data.remote.dto.CreateMedicalHistoryDto
import com.example.enutritrack_app.data.remote.dto.MedicalHistoryResponse
import retrofit2.Response
import retrofit2.http.*

/**
 * API Service para endpoints de historial médico
 */
interface MedicalHistoryApiService {
    
    /**
     * Crea un nuevo historial médico
     * El userId se obtiene del token JWT
     */
    @POST("/")
    suspend fun createMedicalHistory(
        @Body request: CreateMedicalHistoryDto
    ): Response<MedicalHistoryResponse>
    
    /**
     * Obtiene el historial médico de un usuario
     */
    @GET("/{userId}")
    suspend fun getMedicalHistory(
        @Path("userId") userId: String
    ): Response<List<MedicalHistoryResponse>>
    
    /**
     * Actualiza el historial médico de un usuario
     */
    @PATCH("/{userId}")
    suspend fun updateMedicalHistory(
        @Path("userId") userId: String,
        @Body request: CreateMedicalHistoryDto
    ): Response<MedicalHistoryResponse>
}

