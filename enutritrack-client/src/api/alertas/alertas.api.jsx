import { alertasAPI } from "../axios";

export const createAlertRequest = (alertData) =>
  alertasAPI.post("/", alertData);
export const getAlertsByUserRequest = (userId, includeResolved = false) =>
  alertasAPI.get(
    `/user/${userId}${includeResolved ? "?includeResolved=true" : ""}`
  );
export const getActiveAlertsByUserRequest = (userId) =>
  alertasAPI.get(`/user/${userId}/active`);
export const getAlertByIdRequest = (id) => alertasAPI.get(`/${id}`);
export const updateAlertRequest = (id, alertData) =>
  alertasAPI.put(`/${id}`, alertData);
export const resolveAlertRequest = (id, doctorId, notas) =>
  alertasAPI.put(`/${id}/resolve`, { doctor_id: doctorId, notas });
export const addAlertActionRequest = (id, actionData) =>
  alertasAPI.post(`/${id}/actions`, actionData);
export const deleteAlertRequest = (id) => alertasAPI.delete(`/${id}`);
export const getAlertTypesRequest = () => alertasAPI.get("/types");
export const getAlertCategoriesRequest = () =>
  alertasAPI.get("/categories");
export const getAlertPrioritiesRequest = () =>
  alertasAPI.get("/priorities");
export const getAlertStatesRequest = () => alertasAPI.get("/states");
export const createAutomaticConfigRequest = (configData) =>
  alertasAPI.post("/automatic-configs", configData);
export const getAutomaticConfigsByUserRequest = (userId) =>
  alertasAPI.get(`/automatic-configs/user/${userId}`);
export const updateAutomaticConfigRequest = (id, configData) =>
  alertasAPI.put(`/automatic-configs/${id}`, configData);
export const deleteAutomaticConfigRequest = (id) =>
  alertasAPI.delete(`/automatic-configs/${id}`);
