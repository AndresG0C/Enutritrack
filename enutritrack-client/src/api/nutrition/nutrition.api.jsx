// api/nutrition/nutrition.api.js
import { nutritionAPI } from "../axios";

// Registros de comida
export const createFoodRecordRequest = (foodRecordData) =>
  nutritionAPI.post("/records", foodRecordData);
export const addFoodItemRequest = (recordId, foodItemData) =>
  nutritionAPI.post(`/records/${recordId}/items`, foodItemData);
export const getFoodRecordsByUserRequest = (userId) =>
  nutritionAPI.get(`/records/user/${userId}`);
export const getDailySummaryRequest = (userId, date) =>
  nutritionAPI.get(
    `/daily-summary/${userId}?date=${date.toISOString()}`
  );
export const getFoodRecordByIdRequest = (id) =>
  nutritionAPI.get(`/records/${id}`);
export const updateFoodRecordRequest = (id, foodRecordData) =>
  nutritionAPI.patch(`/records/${id}`, foodRecordData);
export const deleteFoodRecordItemRequest = (itemId) =>
  nutritionAPI.delete(`/records/items/${itemId}`);
export const deleteFoodRecordRequest = (id) =>
  nutritionAPI.delete(`/records/${id}`);

// Alimentos
export const searchFoodsRequest = (query) =>
  nutritionAPI.get(`/foods/search?q=${encodeURIComponent(query)}`);
export const getFoodsByCategoryRequest = (category) =>
  nutritionAPI.get(`/foods/category/${encodeURIComponent(category)}`);
export const createFoodRequest = (foodData) =>
  nutritionAPI.post("/foods", foodData);
