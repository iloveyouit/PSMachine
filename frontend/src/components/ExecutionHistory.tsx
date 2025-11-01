import React, { useState, useEffect } from 'react';
import { executionAPI } from '../services/api';
import { Clock, CheckCircle, XCircle, Loader, RefreshCw, Trash2 } from 'lucide-react';
import type { Execution } from '../types';

interface ExecutionHistoryProps {
  selectedExecution: Execution | null;
  onExecutionSelect: (execution: Execution) => void;
}

const ExecutionHistory: React.FC<ExecutionHistoryProps> = ({
  selectedExecution,
  onExecutionSelect,
}) => {
  const [executions, setExecutions] = useState<Execution[]>([]);
  const [loading, setLoading] = useState(true);

  const loadExecutions = async () => {
    setLoading(true);
    try {
      const data = await executionAPI.list({ limit: 100 });
      setExecutions(data);
    } catch (error) {
      console.error('Failed to load executions:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadExecutions();
  }, []);

  const handleDelete = async (execution: Execution) => {
    if (!confirm('Delete this execution record?')) return;

    try {
      await executionAPI.delete(execution.id);
      loadExecutions();
      if (selectedExecution?.id === execution.id) {
        onExecutionSelect(null as any);
      }
    } catch (error) {
      alert('Failed to delete execution');
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'running':
        return <Loader className="w-5 h-5 text-blue-400 animate-spin" />;
      case 'completed':
        return <CheckCircle className="w-5 h-5 text-green-400" />;
      case 'failed':
        return <XCircle className="w-5 h-5 text-red-400" />;
      default:
        return <Clock className="w-5 h-5 text-gray-400" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running':
        return 'text-blue-400 bg-blue-900 bg-opacity-30';
      case 'completed':
        return 'text-green-400 bg-green-900 bg-opacity-30';
      case 'failed':
        return 'text-red-400 bg-red-900 bg-opacity-30';
      default:
        return 'text-gray-400 bg-gray-900 bg-opacity-30';
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleString();
  };

  return (
    <div className="h-full flex">
      {/* Execution List */}
      <div className="w-1/3 border-r border-gray-700 overflow-auto">
        <div className="bg-gray-800 border-b border-gray-700 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-bold text-white">Execution History</h2>
          <button
            onClick={loadExecutions}
            className="px-3 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded transition"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="text-center text-gray-400 py-12">Loading...</div>
        ) : executions.length === 0 ? (
          <div className="text-center text-gray-400 py-12">No executions yet</div>
        ) : (
          <div className="divide-y divide-gray-700">
            {executions.map((execution) => (
              <div
                key={execution.id}
                onClick={() => onExecutionSelect(execution)}
                className={`p-4 cursor-pointer hover:bg-gray-800 transition ${
                  selectedExecution?.id === execution.id ? 'bg-gray-800' : ''
                }`}
              >
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center">
                    {getStatusIcon(execution.status)}
                    <span className="ml-2 text-white font-semibold">
                      {execution.script_name}
                    </span>
                  </div>
                  <span
                    className={`px-2 py-1 text-xs rounded ${getStatusColor(
                      execution.status
                    )}`}
                  >
                    {execution.status}
                  </span>
                </div>

                <div className="text-xs text-gray-400 space-y-1">
                  <div>Started: {formatDate(execution.started_at)}</div>
                  {execution.duration_seconds && (
                    <div>Duration: {execution.duration_seconds.toFixed(2)}s</div>
                  )}
                  {execution.exit_code !== undefined && (
                    <div>Exit Code: {execution.exit_code}</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Execution Details */}
      <div className="flex-1 overflow-auto">
        {selectedExecution ? (
          <div className="p-6">
            <div className="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
              <div className="bg-gray-900 px-6 py-4 border-b border-gray-700 flex items-center justify-between">
                <div className="flex items-center">
                  {getStatusIcon(selectedExecution.status)}
                  <h3 className="ml-3 text-xl font-bold text-white">
                    {selectedExecution.script_name}
                  </h3>
                </div>
                <button
                  onClick={() => handleDelete(selectedExecution)}
                  className="px-3 py-2 bg-red-600 hover:bg-red-700 text-white rounded transition"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              <div className="p-6 space-y-4">
                {/* Metadata */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <span className="text-gray-400 text-sm">Status</span>
                    <div className={`mt-1 font-semibold ${getStatusColor(selectedExecution.status)}`}>
                      {selectedExecution.status.toUpperCase()}
                    </div>
                  </div>
                  <div>
                    <span className="text-gray-400 text-sm">Exit Code</span>
                    <div className="mt-1 text-white">
                      {selectedExecution.exit_code ?? 'N/A'}
                    </div>
                  </div>
                  <div>
                    <span className="text-gray-400 text-sm">Started At</span>
                    <div className="mt-1 text-white">
                      {formatDate(selectedExecution.started_at)}
                    </div>
                  </div>
                  <div>
                    <span className="text-gray-400 text-sm">Duration</span>
                    <div className="mt-1 text-white">
                      {selectedExecution.duration_seconds
                        ? `${selectedExecution.duration_seconds.toFixed(2)}s`
                        : 'N/A'}
                    </div>
                  </div>
                </div>

                {/* Parameters */}
                {selectedExecution.parameters &&
                  Object.keys(selectedExecution.parameters).length > 0 && (
                    <div>
                      <h4 className="text-gray-400 text-sm mb-2">Parameters</h4>
                      <div className="bg-gray-900 rounded p-3">
                        <pre className="text-sm text-gray-300">
                          {JSON.stringify(selectedExecution.parameters, null, 2)}
                        </pre>
                      </div>
                    </div>
                  )}

                {/* Output */}
                {selectedExecution.output && (
                  <div>
                    <h4 className="text-gray-400 text-sm mb-2">Output</h4>
                    <div className="bg-black rounded p-4 max-h-96 overflow-auto">
                      <pre className="text-sm text-green-400 whitespace-pre-wrap">
                        {selectedExecution.output}
                      </pre>
                    </div>
                  </div>
                )}

                {/* Error Output */}
                {selectedExecution.error_output && (
                  <div>
                    <h4 className="text-gray-400 text-sm mb-2">Error Output</h4>
                    <div className="bg-black rounded p-4 max-h-96 overflow-auto">
                      <pre className="text-sm text-red-400 whitespace-pre-wrap">
                        {selectedExecution.error_output}
                      </pre>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        ) : (
          <div className="h-full flex items-center justify-center text-gray-400">
            Select an execution to view details
          </div>
        )}
      </div>
    </div>
  );
};

export default ExecutionHistory;
