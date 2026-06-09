import { activityAPI } from "../axios";

export const createPhysicalActivityRequest = (activityData) =>
  activityAPI.post("/", activityData);
export const getPhysicalActivitiesByUserRequest = (userId) =>
  activityAPI.get(`/user/${userId}`);
export const getPhysicalActivityByIdRequest = (id) =>
  activityAPI.get(`/${id}`);
export const updatePhysicalActivityRequest = (id, activityData) =>
  activityAPI.put(`/${id}`, activityData);
export const deletePhysicalActivityRequest = (id) =>
  activityAPI.delete(`/${id}`);
export const getActivityTypesRequest = () =>
  activityAPI.get("/types");
export const getWeeklySummaryRequest = (userId, startDate) =>
  activityAPI.get(
    `/user/${userId}/weekly-summary?startDate=${startDate.toISOString()}`
  );
export const getMonthlyStatsRequest = (userId, year, month) =>
  activityAPI.get(
    `/user/${userId}/monthly-stats?year=${year}&month=${month}`
  );
