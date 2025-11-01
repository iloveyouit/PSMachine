export interface User {
  id: number;
  username: string;
  email: string;
  role: 'admin' | 'user';
  created_at: string;
  is_active: boolean;
}

export interface Script {
  id: number;
  name: string;
  description: string;
  content?: string;
  category: string;
  tags: string[];
  parameters: ScriptParameter[];
  author_id: number;
  author_username?: string;
  created_at: string;
  updated_at: string;
  is_public: boolean;
  execution_count: number;
}

export interface ScriptParameter {
  name: string;
  type: 'string' | 'int' | 'bool';
  description?: string;
  required: boolean;
  default_value?: any;
  pattern?: string;
}

export interface Execution {
  id: number;
  script_id: number;
  script_name?: string;
  user_id: number;
  username?: string;
  parameters: Record<string, any>;
  status: 'pending' | 'running' | 'completed' | 'failed';
  output?: string;
  error_output?: string;
  exit_code?: number;
  started_at: string;
  completed_at?: string;
  duration_seconds?: number;
}

export interface ScriptVersion {
  id: number;
  script_id: number;
  version_number: number;
  content: string;
  change_description?: string;
  created_at: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  user: User;
}

export interface ExecuteScriptRequest {
  parameters?: Record<string, any>;
  timeout?: number;
}

export interface ExecuteScriptResponse {
  message: string;
  execution_id: number;
}
