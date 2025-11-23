import axios from "axios";

// Construir URL base usando la IP/hostname actual y el puerto del microservicio
const getBaseUrl = (microservicePort) => {
  if (typeof window === "undefined") {
    // SSR fallback - usar localhost
    return `http://localhost:${microservicePort}`;
  }
  
  const hostname = window.location.hostname;
  const protocol = window.location.protocol;
  
  // Si es localhost o 127.0.0.1, usar localhost
  if (hostname === "localhost" || hostname === "127.0.0.1" || hostname === "") {
    return `http://localhost:${microservicePort}`;
  }
  
  // Para cualquier otra IP (GCP u otra), usar esa IP con el puerto del microservicio
  // Sin slash final - los archivos .api.jsx ya agregan las rutas con slash
  return `${protocol}//${hostname}:${microservicePort}`;
};

// URLs base para cada microservicio (sin slash final)
const API_BASE_URL_USER = getBaseUrl(3001);
const API_BASE_URL_MEDICAL = getBaseUrl(3002);
const API_BASE_URL_NUTRITION = getBaseUrl(3003);
const API_BASE_URL_AUTH = getBaseUrl(3004);
const API_BASE_URL_ACTIVITY = getBaseUrl(3005);
const API_BASE_URL_RECOMMENDATION = getBaseUrl(3006);
const API_BASE_URL_CITAS_MEDIAS = getBaseUrl(3008);
const API_BASE_URL_ALERTAS = getBaseUrl(3009);

// Función para convertir objeto a XML
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

const createAxiosInstance = (baseURL) => {
  const instance = axios.create({
    baseURL,
    withCredentials: true,
    headers: {
      "Content-Type": "application/json",
    },
  });

  instance.interceptors.request.use(
    (config) => {
      // Obtener token de cookies
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

  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        console.error("Error de autenticación:", error.response.data);
      }
      return Promise.reject(error);
    }
  );

  return instance;
};

export const userAPI = createAxiosInstance(API_BASE_URL_USER);
export const medicalAPI = createAxiosInstance(API_BASE_URL_MEDICAL);
export const citasAPI = createAxiosInstance(API_BASE_URL_CITAS_MEDIAS);
export const nutritionAPI = createAxiosInstance(API_BASE_URL_NUTRITION);
export const authAPI = createAxiosInstance(API_BASE_URL_AUTH);
export const activityAPI = createAxiosInstance(API_BASE_URL_ACTIVITY);
export const recommendationAPI = createAxiosInstance(
  API_BASE_URL_RECOMMENDATION
);
export const alertasAPI = createAxiosInstance(API_BASE_URL_ALERTAS);
