import { recommendationAPI } from "../axios";

// ========== APIS PARA RECOMENDACIONES ==========
export const createRecommendationRequest = (recommendationData) =>
  recommendationAPI.post("/", recommendationData);
export const createAIRecommendationRequest = (aiRecommendationData) =>
  recommendationAPI.post("/ai", aiRecommendationData);
export const getRecommendationsByUserRequest = (
  userId,
  includeInactive = false
) =>
  recommendationAPI.get(
    `/user/${userId}${
      includeInactive ? "?includeInactive=true" : ""
    }`
  );
export const getActiveRecommendationsByUserRequest = (userId) =>
  recommendationAPI.get(`/user/${userId}/active`);
export const getRecommendationByIdRequest = (id) =>
  recommendationAPI.get(`/${id}`);
export const updateRecommendationRequest = (id, recommendationData) =>
  recommendationAPI.put(`/${id}`, recommendationData);
export const deactivateRecommendationRequest = (id) =>
  recommendationAPI.put(`/${id}/deactivate`);
export const deleteRecommendationRequest = (id) =>
  recommendationAPI.delete(`/${id}`);
export const addRecommendationDataRequest = (id, data) =>
  recommendationAPI.post(`/${id}/data`, data);
// ========== APIS PARA TIPOS DE RECOMENDACIÓN ==========
export const getRecommendationTypesRequest = () =>
  recommendationAPI.get("/types");
export const createRecommendationTypeRequest = (typeData) =>
  recommendationAPI.post("/types", typeData);
export const getRecommendationTypeByIdRequest = (id) =>
  recommendationAPI.get(`/types/${id}`);
export const updateRecommendationTypeRequest = (id, typeData) =>
  recommendationAPI.put(`/types/${id}`, typeData);
export const deleteRecommendationTypeRequest = (id) =>
  recommendationAPI.delete(`/types/${id}`);
// ========== APIS PARA ESTADÍSTICAS ==========
export const getWeeklySummaryRequest = (userId, startDate) =>
  recommendationAPI.get(
    `/user/${userId}/weekly-summary?startDate=${startDate.toISOString()}`
  );
export const getMonthlyStatsRequest = (userId, year, month) =>
  recommendationAPI.get(
    `/user/${userId}/monthly-stats?year=${year}&month=${month}`
  );
