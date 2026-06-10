package com.example.enutritrack_app.config

/**
 * Configuración de URLs de la API
 * 
 * ═══════════════════════════════════════════════════════════════
 * 📝 INSTRUCCIONES PARA CAMBIAR LA IP DESPUÉS DEL DESPLIEGUE
 * ═══════════════════════════════════════════════════════════════
 * 
 * Para usar con GCP después del despliegue:
 * 1. Abre este archivo en Android Studio
 * 2. Reemplaza [TU_IP_GCP] con la IP de tu VM de GCP
 * 3. Cambia USE_PRODUCTION = true
 * 4. Recompila la app (Build > Rebuild Project)
 * 5. Instala el APK
 * 
 * Ejemplo:
 * Si tu IP de GCP es 34.123.45.67, cambia:
 *   private const val PROD_IP = "34.123.45.67"
 *   private const val USE_PRODUCTION = true
 * 
 * ═══════════════════════════════════════════════════════════════
 */
object ApiConfig {
    // ============================================
    // ⚙️ CONFIGURACIÓN - CAMBIAR AQUÍ LA IP O DNS ⚙️
    // ============================================

    /**
     * DNS del ALB de MICROSERVICIOS
     * ⚠️ REEMPLAZAR con el DNS real de tu ALB de microservicios
     *
     * Se encuentra en: AWS Console → EC2 → Load Balancers
     * Nombre típico: enutritrack-microservices
     * Ejemplo: enutritrack-microservices-1234567890.us-east-1.elb.amazonaws.com
     */
    private const val ALB_MICROSERVICES_DNS = "enutritrack-microservices-1024331855.us-east-1.elb.amazonaws.com"

    /**
     * DNS del ALB del CMS (Backend)
     * ⚠️ REEMPLAZAR con el DNS real de tu ALB del CMS
     *
     * Nombre típico: enutritrack-alb-cms
     * Ejemplo: enutritrack-alb-cms-1234567890.us-east-1.elb.amazonaws.com
     */
    private const val ALB_CMS_DNS = "enutritrack-alb-cms-1814714288.us-east-1.elb.amazonaws.com"

    /**
     * Puerto de los ALBs (80 para HTTP, 443 para HTTPS)
     */
    private const val ALB_PORT = 80

    /**
     * Protocolo (http o https)
     */
    private const val PROTOCOL = "http"
    
    /**
     * IP para desarrollo local (emulador Android)
     * 10.0.2.2 es la IP especial del emulador que apunta a localhost de la máquina host
     */

    private const val DEV_IP = "10.0.2.2"

    /**
     * Modo de operación:
     * - false = Desarrollo local (usa DEV_IP con puertos directos)
     * - true = Producción GCP (usa PROD_IP con puertos directos)
     */
    private const val USE_PRODUCTION = true

    /**
     * URLs para desarrollo local (puertos directos)
     * Usadas cuando USE_PRODUCTION = false
     * 
     * Puertos utilizados:
     * - 3004: Microservicio de Autenticación (Auth)
     * - 3001: Microservicio de Usuarios (Users)
     * - 3002: Microservicio de Historial Médico (Medical History)
     * - 4000: Servidor principal (Backend/CMS) - contiene: health, nutrition, appointments, alerts, activity, etc.
     */
    val BASE_URL_AUTH_DEV = "http://$DEV_IP:3004/"
    val BASE_URL_USERS_DEV = "http://$DEV_IP:3001/"
    val BASE_URL_MEDICAL_DEV = "http://$DEV_IP:3002/"
    val BASE_URL_SERVER_DEV = "http://$DEV_IP:4000/"

    // ============================================
    // URLs para PRODUCCIÓN AWS
    // ============================================
    val BASE_URL_MICROSERVICES = "$PROTOCOL://$ALB_MICROSERVICES_DNS:$ALB_PORT"
    val BASE_URL_CMS = "$PROTOCOL://$ALB_CMS_DNS:$ALB_PORT"

    // Microservicios que tu app usa:
    val BASE_URL_AUTH_PROD = "$BASE_URL_MICROSERVICES/auth/"
    val BASE_URL_USERS_PROD = "$BASE_URL_MICROSERVICES/users/"
    val BASE_URL_MEDICAL_PROD = "$BASE_URL_MICROSERVICES/medical-history/"
    val BASE_URL_SERVER_PROD = "$BASE_URL_CMS/"
    
    /**
     * URLs finales según el modo seleccionado
     * Estas son las que se usan en NetworkModule
     */
    val BASE_URL_AUTH = if (USE_PRODUCTION) BASE_URL_AUTH_PROD else BASE_URL_AUTH_DEV
    val BASE_URL_USERS = if (USE_PRODUCTION) BASE_URL_USERS_PROD else BASE_URL_USERS_DEV
    val BASE_URL_MEDICAL = if (USE_PRODUCTION) BASE_URL_MEDICAL_PROD else BASE_URL_MEDICAL_DEV
    val BASE_URL_SERVER = if (USE_PRODUCTION) BASE_URL_SERVER_PROD else BASE_URL_SERVER_DEV
}

