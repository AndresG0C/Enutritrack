// api/appointments/appointments.api.js
import { citasAPI } from "../../api/axios";

export const createAppointmentRequest = (appointmentData) =>
  citasAPI.post("/", appointmentData);

export const getAppointmentsRequest = (filters = {}) =>
  citasAPI.get("/", { params: filters });

export const getAppointmentByIdRequest = (id) =>
  citasAPI.get(`/${id}`);

export const updateAppointmentRequest = (id, appointmentData) =>
  citasAPI.patch(`/${id}`, appointmentData);

export const deleteAppointmentRequest = (id) =>
  citasAPI.delete(`/${id}`);

export const changeAppointmentStateRequest = (id, stateId) =>
  citasAPI.patch(`/${id}/estado/${stateId}`);

export const getAppointmentStatesRequest = () =>
  citasAPI.get("/estados");

export const getConsultationTypesRequest = () =>
  citasAPI.get("/tipos-consulta");

export const getMyAppointmentsRequest = (filters = {}) =>
  citasAPI.get("/mis-citas", { params: filters });
