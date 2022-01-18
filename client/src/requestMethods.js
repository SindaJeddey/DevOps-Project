import axios from "axios";

const BASE_URL = "http://13.37.222.37:5000/";
export const publicRequest = axios.create({
  baseURL: BASE_URL,
});
