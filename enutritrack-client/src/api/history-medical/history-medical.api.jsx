// api/medical-history/medicalHistoryAuth.js
import { medicalAPI } from "../../api/axios";

export const createMedicalHistoryRequest = (medicalHistory) =>
  medicalAPI.post("/", medicalHistory);
export const getMedicalHistoryByUserRequest = (userId) =>
  medicalAPI.get(`/${userId}`);
export const updateMedicalHistoryRequest = (userId, medicalHistory) =>
  medicalAPI.patch(`/${userId}`, medicalHistory);
