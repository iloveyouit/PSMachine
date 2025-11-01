import axios from 'axios';
import type {
  User,
  Script,
  Execution,
  ScriptVersion,
  LoginRequest,
  RegisterRequest,
  AuthResponse,
  ExecuteScriptRequest,
  ExecuteScriptResponse,
} from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5001';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  login: async (data: LoginRequest): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/api/auth/login', data);
    return response.data;
  },

  register: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/api/auth/register', data);
    return response.data;
  },

  getCurrentUser: async (): Promise<User> => {
    const response = await api.get<User>('/api/auth/me');
    return response.data;
  },

  listUsers: async (): Promise<User[]> => {
    const response = await api.get<User[]>('/api/auth/users');
    return response.data;
  },
};

// Scripts API
export const scriptsAPI = {
  list: async (params?: {
    category?: string;
    search?: string;
    tags?: string;
  }): Promise<Script[]> => {
    const response = await api.get<Script[]>('/api/scripts/', { params });
    return response.data;
  },

  get: async (id: number): Promise<Script> => {
    const response = await api.get<Script>(`/api/scripts/${id}`);
    return response.data;
  },

  create: async (data: Partial<Script>): Promise<{ message: string; script: Script }> => {
    const response = await api.post('/api/scripts/', data);
    return response.data;
  },

  update: async (
    id: number,
    data: Partial<Script>
  ): Promise<{ message: string; script: Script }> => {
    const response = await api.put(`/api/scripts/${id}`, data);
    return response.data;
  },

  delete: async (id: number): Promise<{ message: string }> => {
    const response = await api.delete(`/api/scripts/${id}`);
    return response.data;
  },

  getVersions: async (id: number): Promise<ScriptVersion[]> => {
    const response = await api.get<ScriptVersion[]>(`/api/scripts/${id}/versions`);
    return response.data;
  },

  getCategories: async (): Promise<string[]> => {
    const response = await api.get<string[]>('/api/scripts/categories');
    return response.data;
  },
};

// Execution API
export const executionAPI = {
  execute: async (
    scriptId: number,
    data: ExecuteScriptRequest
  ): Promise<ExecuteScriptResponse> => {
    const response = await api.post<ExecuteScriptResponse>(
      `/api/execution/execute/${scriptId}`,
      data
    );
    return response.data;
  },

  list: async (params?: {
    script_id?: number;
    status?: string;
    limit?: number;
  }): Promise<Execution[]> => {
    const response = await api.get<Execution[]>('/api/execution/executions', { params });
    return response.data;
  },

  get: async (id: number): Promise<Execution> => {
    const response = await api.get<Execution>(`/api/execution/executions/${id}`);
    return response.data;
  },

  delete: async (id: number): Promise<{ message: string }> => {
    const response = await api.delete(`/api/execution/executions/${id}`);
    return response.data;
  },

  validate: async (
    scriptId: number
  ): Promise<{ valid: boolean; issues: string[]; restrictions_enabled: boolean }> => {
    const response = await api.post(`/api/execution/validate/${scriptId}`);
    return response.data;
  },

  getSystemInfo: async (): Promise<{
    powershell_version: string;
    restrictions_enabled: boolean;
  }> => {
    const response = await api.get('/api/execution/system/info');
    return response.data;
  },
};

export default api;
