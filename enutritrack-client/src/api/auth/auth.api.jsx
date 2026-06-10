import { authAPI } from "../axios";

// Servicios de autenticacion
export const loginRequest = (credentials) =>
  authAPI.post("/login", credentials);
export const logoutRequest = () => authAPI.post("/logout");
export const validateTokenRequest = (data) =>
  authAPI.post("/validate", data);
export const refreshTokenRequest = (data) =>
  authAPI.post("/refresh", data);
