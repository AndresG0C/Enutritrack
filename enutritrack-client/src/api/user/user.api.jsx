import { userAPI } from "../axios";

export const getUsersRequest = () => userAPI.get("/");
export const getUsersByDoctorIdRequest = (doctorId) =>
  userAPI.get(`/doctor/${doctorId}`);
export const createUsersRequest = (user) => userAPI.post("/", user);
export const createUsersCompleteRequest = (user) =>
  userAPI.post("/complete", user);
export const getUserByEmailRequest = (email) =>
  userAPI.get(`/email/${email}`);
export const getUserByIdRequest = (id) => userAPI.get(`/${id}`);
export const deleteUserByIdRequest = (id) => userAPI.delete(`/${id}`);
export const updateUsersRequest = (id, user) =>
  userAPI.patch(`/${id}`, user);
