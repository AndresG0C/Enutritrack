import axios from "axios";

// ============================================
// CONFIGURACIÓN BASE SIN PUERTOS
// ============================================

/**
 * Construye la URL base dinámicamente sin usar puertos
 * - En local: usa http://localhost
 * - En AWS/producción: usa el mismo protocolo y hostname del frontend
 */
const getBaseUrl = () => {
  if (typeof window === "undefined") {
    // Server-Side Rendering (Next.js) - fallback seguro
    return "http://localhost";
  }

  const { hostname, protocol } = window.location;

  // Desarrollo local
  if (hostname === "localhost" || hostname === "127.0.0.1" || hostname === "") {
    return "http://localhost";
  }

  // Producción: usa el mismo host que el frontend
  // Ejemplo: https://enutritrack.com o http://alb-frontend-123.elb.amazonaws.com
  return `${protocol}//${hostname}`;
};

const BASE_URL = getBaseUrl();

// ============================================
// URLs BASE PARA CADA MICROSERVICIO (SOLO PATHS)
// ============================================

// Todas las URLs usan el mismo host/base y solo cambia el path
const API_BASE_URL_USER = `${BASE_URL}/users`;
const API_BASE_URL_MEDICAL = `${BASE_URL}/medical-history`;
const API_BASE_URL_NUTRITION = `${BASE_URL}/nutrition`;
const API_BASE_URL_AUTH = `${BASE_URL}/auth`;
const API_BASE_URL_ACTIVITY = `${BASE_URL}/physical-activity`;  // ← CAMBIADO
const API_BASE_URL_RECOMMENDATION = `${BASE_URL}/recommendations`;  // ← CAMBIADO
const API_BASE_URL_CITAS_MEDIAS = `${BASE_URL}/citas-medicas`;  // ← CAMBIADO
const API_BASE_URL_ALERTAS = `${BASE_URL}/alerts`;  // ← CAMBIADO

// ============================================
// FUNCIONES AUXILIARES
// ============================================

/**
 * Convierte un objeto JavaScript a formato XML
 * Útil para endpoints que esperan XML
 */
const objectToXml = (obj, rootName = "root") => {
  let xml = `<?xml version="1.0" encoding="UTF-8"?><${rootName}>`;

  const toXml = (obj) => {
    for (let key in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        if (typeof obj[key] === "object" && obj[key] !== null) {
          xml += `<${key}>${toXml(obj[key])}</${key}>`;
        } else {
          xml += `<${key}>${obj[key]}</${key}>`;
        }
      }
    }
    return "";
  };

  toXml(obj);
  xml += `</${rootName}>`;
  return xml;
};

// ============================================
// FACTORY DE INSTANCIAS AXIOS
// ============================================

/**
 * Crea una instancia de axios configurada con:
 * - Credenciales (cookies)
 * - Headers por defecto
 * - Interceptores para token JWT
 * - Manejo de errores 401
 */
const createAxiosInstance = (baseURL) => {
  const instance = axios.create({
    baseURL,
    withCredentials: true,  // Importante para cookies de autenticación
    headers: {
      "Content-Type": "application/json",
    },
  });

  // Interceptor de request: agrega token JWT desde cookies
  instance.interceptors.request.use(
    (config) => {
      // Obtener token de las cookies
      const token = document.cookie
        .split("; ")
        .find((row) => row.startsWith("access_token="))
        ?.split("=")[1];

      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }

      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  // Interceptor de response: manejo global de errores
  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        console.error("Error de autenticación:", error.response.data);
        // Opcional: redirigir a login
        // if (typeof window !== "undefined") {
        //   window.location.href = "/login";
        // }
      }
      return Promise.reject(error);
    }
  );

  return instance;
};

// ============================================
// INSTANCIAS EXPORTADAS
// ============================================

export const userAPI = createAxiosInstance(API_BASE_URL_USER);
export const medicalAPI = createAxiosInstance(API_BASE_URL_MEDICAL);
export const citasAPI = createAxiosInstance(API_BASE_URL_CITAS_MEDIAS);
export const nutritionAPI = createAxiosInstance(API_BASE_URL_NUTRITION);
export const authAPI = createAxiosInstance(API_BASE_URL_AUTH);
export const activityAPI = createAxiosInstance(API_BASE_URL_ACTIVITY);
export const recommendationAPI = createAxiosInstance(API_BASE_URL_RECOMMENDATION);
export const alertasAPI = createAxiosInstance(API_BASE_URL_ALERTAS);

// ============================================
// EXPORTAR UTILIDADES SI SE NECESITAN
// ============================================

export { objectToXml, getBaseUrl };