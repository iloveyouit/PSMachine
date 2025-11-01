import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import ScriptList from './ScriptList';
import ScriptEditor from './ScriptEditor';
import ExecutionHistory from './ExecutionHistory';
import ExecutionConsole from './ExecutionConsole';
import {
  FileCode,
  Play,
  LogOut,
  Plus,
  History,
  Settings,
  BarChart,
} from 'lucide-react';
import type { Script, Execution } from '../types';

type View = 'scripts' | 'editor' | 'history' | 'execution' | 'stats';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();
  const [view, setView] = useState<View>('scripts');
  const [selectedScript, setSelectedScript] = useState<Script | null>(null);
  const [selectedExecution, setSelectedExecution] = useState<Execution | null>(null);

  const handleCreateScript = () => {
    setSelectedScript(null);
    setView('editor');
  };

  const handleEditScript = (script: Script) => {
    setSelectedScript(script);
    setView('editor');
  };

  const handleExecuteScript = (script: Script) => {
    setSelectedScript(script);
    setView('execution');
  };

  const handleViewExecution = (execution: Execution) => {
    setSelectedExecution(execution);
    setView('history');
  };

  const handleScriptSaved = () => {
    setView('scripts');
    setSelectedScript(null);
  };

  return (
    <div className="min-h-screen bg-gray-900">
      {/* Top Navigation Bar */}
      <nav className="bg-gray-800 border-b border-gray-700 px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <FileCode className="w-8 h-8 text-blue-400" />
            <h1 className="text-2xl font-bold text-white">PSMachine</h1>
          </div>

          <div className="flex items-center space-x-6">
            <span className="text-gray-300">
              {user?.username}
              {user?.role === 'admin' && (
                <span className="ml-2 px-2 py-1 bg-blue-600 text-xs rounded">
                  Admin
                </span>
              )}
            </span>
            <button
              onClick={logout}
              className="flex items-center text-gray-300 hover:text-white"
            >
              <LogOut className="w-5 h-5 mr-1" />
              Logout
            </button>
          </div>
        </div>
      </nav>

      <div className="flex h-[calc(100vh-73px)]">
        {/* Sidebar */}
        <aside className="w-64 bg-gray-800 border-r border-gray-700 p-4">
          <div className="space-y-2">
            <button
              onClick={() => setView('scripts')}
              className={`w-full flex items-center px-4 py-3 rounded transition ${
                view === 'scripts'
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-700'
              }`}
            >
              <FileCode className="w-5 h-5 mr-3" />
              Scripts
            </button>

            <button
              onClick={handleCreateScript}
              className="w-full flex items-center px-4 py-3 rounded text-gray-300 hover:bg-gray-700 transition"
            >
              <Plus className="w-5 h-5 mr-3" />
              New Script
            </button>

            <button
              onClick={() => setView('history')}
              className={`w-full flex items-center px-4 py-3 rounded transition ${
                view === 'history'
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-700'
              }`}
            >
              <History className="w-5 h-5 mr-3" />
              Execution History
            </button>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-auto">
          {view === 'scripts' && (
            <ScriptList
              onEdit={handleEditScript}
              onExecute={handleExecuteScript}
            />
          )}

          {view === 'editor' && (
            <ScriptEditor script={selectedScript} onSaved={handleScriptSaved} />
          )}

          {view === 'history' && (
            <ExecutionHistory
              selectedExecution={selectedExecution}
              onExecutionSelect={setSelectedExecution}
            />
          )}

          {view === 'execution' && selectedScript && (
            <ExecutionConsole
              script={selectedScript}
              onClose={() => setView('scripts')}
            />
          )}
        </main>
      </div>
    </div>
  );
};

export default Dashboard;
