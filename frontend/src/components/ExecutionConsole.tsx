import React, { useState, useEffect, useRef } from 'react';
import { executionAPI } from '../services/api';
import { Play, X, AlertCircle, CheckCircle, Loader, Terminal } from 'lucide-react';
import type { Script, Execution } from '../types';

interface ExecutionConsoleProps {
  script: Script;
  onClose: () => void;
}

const ExecutionConsole: React.FC<ExecutionConsoleProps> = ({ script, onClose }) => {
  const [parameters, setParameters] = useState<Record<string, any>>({});
  const [execution, setExecution] = useState<Execution | null>(null);
  const [isExecuting, setIsExecuting] = useState(false);
  const [pollInterval, setPollInterval] = useState<NodeJS.Timeout | null>(null);
  const outputRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Initialize parameters with defaults
    const initialParams: Record<string, any> = {};
    script.parameters?.forEach((param) => {
      if (param.default_value !== undefined) {
        initialParams[param.name] = param.default_value;
      } else if (param.type === 'bool') {
        initialParams[param.name] = false;
      } else if (param.type === 'int') {
        initialParams[param.name] = 0;
      } else {
        initialParams[param.name] = '';
      }
    });
    setParameters(initialParams);
  }, [script]);

  useEffect(() => {
    // Auto-scroll to bottom when output updates
    if (outputRef.current) {
      outputRef.current.scrollTop = outputRef.current.scrollHeight;
    }
  }, [execution?.output, execution?.error_output]);

  useEffect(() => {
    // Cleanup poll interval on unmount
    return () => {
      if (pollInterval) {
        clearInterval(pollInterval);
      }
    };
  }, [pollInterval]);

  const pollExecution = (executionId: number) => {
    const interval = setInterval(async () => {
      try {
        const data = await executionAPI.get(executionId);
        setExecution(data);

        if (data.status === 'completed' || data.status === 'failed') {
          clearInterval(interval);
          setPollInterval(null);
          setIsExecuting(false);
        }
      } catch (error) {
        console.error('Failed to poll execution:', error);
      }
    }, 1000);

    setPollInterval(interval);
  };

  const handleExecute = async () => {
    setIsExecuting(true);
    setExecution(null);

    try {
      const response = await executionAPI.execute(script.id, {
        parameters,
        timeout: 300,
      });

      // Start polling for execution status
      pollExecution(response.execution_id);
    } catch (error: any) {
      alert(error.response?.data?.error || 'Failed to execute script');
      setIsExecuting(false);
    }
  };

  const getStatusIcon = () => {
    if (!execution) return null;

    switch (execution.status) {
      case 'running':
        return <Loader className="w-5 h-5 text-blue-400 animate-spin" />;
      case 'completed':
        return <CheckCircle className="w-5 h-5 text-green-400" />;
      case 'failed':
        return <AlertCircle className="w-5 h-5 text-red-400" />;
      default:
        return null;
    }
  };

  const getStatusColor = () => {
    if (!execution) return 'text-gray-400';

    switch (execution.status) {
      case 'running':
        return 'text-blue-400';
      case 'completed':
        return 'text-green-400';
      case 'failed':
        return 'text-red-400';
      default:
        return 'text-gray-400';
    }
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center">
          <Terminal className="w-6 h-6 text-green-400 mr-3" />
          <div>
            <h2 className="text-xl font-bold text-white">{script.name}</h2>
            <p className="text-sm text-gray-400">{script.description}</p>
          </div>
        </div>
        <button
          onClick={onClose}
          className="px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded transition"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      <div className="flex-1 overflow-auto p-6">
        <div className="max-w-4xl mx-auto space-y-6">
          {/* Parameters Section */}
          {script.parameters && script.parameters.length > 0 && (
            <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
              <h3 className="text-lg font-semibold text-white mb-4">Parameters</h3>
              <div className="space-y-3">
                {script.parameters.map((param, idx) => (
                  <div key={idx}>
                    <label className="block text-gray-300 mb-1">
                      {param.name}
                      {param.required && <span className="text-red-400 ml-1">*</span>}
                    </label>
                    {param.description && (
                      <p className="text-xs text-gray-500 mb-1">{param.description}</p>
                    )}
                    {param.type === 'bool' ? (
                      <input
                        type="checkbox"
                        checked={parameters[param.name] || false}
                        onChange={(e) =>
                          setParameters({
                            ...parameters,
                            [param.name]: e.target.checked,
                          })
                        }
                        className="mt-1"
                      />
                    ) : param.type === 'int' ? (
                      <input
                        type="number"
                        value={parameters[param.name] || ''}
                        onChange={(e) =>
                          setParameters({
                            ...parameters,
                            [param.name]: parseInt(e.target.value) || 0,
                          })
                        }
                        className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
                      />
                    ) : (
                      <input
                        type="text"
                        value={parameters[param.name] || ''}
                        onChange={(e) =>
                          setParameters({
                            ...parameters,
                            [param.name]: e.target.value,
                          })
                        }
                        className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
                      />
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Execute Button */}
          <button
            onClick={handleExecute}
            disabled={isExecuting}
            className="w-full flex items-center justify-center px-6 py-3 bg-green-600 hover:bg-green-700 disabled:bg-green-800 text-white font-semibold rounded-lg transition"
          >
            {isExecuting ? (
              <>
                <Loader className="w-5 h-5 mr-2 animate-spin" />
                Executing...
              </>
            ) : (
              <>
                <Play className="w-5 h-5 mr-2" />
                Execute Script
              </>
            )}
          </button>

          {/* Execution Status */}
          {execution && (
            <div className="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
              <div className="bg-gray-900 px-4 py-3 border-b border-gray-700 flex items-center justify-between">
                <div className="flex items-center">
                  {getStatusIcon()}
                  <span className={`ml-2 font-semibold ${getStatusColor()}`}>
                    {execution.status.toUpperCase()}
                  </span>
                </div>
                <div className="text-sm text-gray-400">
                  {execution.duration_seconds && (
                    <span>Duration: {execution.duration_seconds.toFixed(2)}s</span>
                  )}
                  {execution.exit_code !== undefined && (
                    <span className="ml-4">Exit Code: {execution.exit_code}</span>
                  )}
                </div>
              </div>

              {/* Output */}
              <div
                ref={outputRef}
                className="p-4 bg-black text-green-400 font-mono text-sm max-h-96 overflow-auto"
              >
                {execution.output && (
                  <div className="whitespace-pre-wrap">{execution.output}</div>
                )}
                {execution.error_output && (
                  <div className="text-red-400 whitespace-pre-wrap mt-2">
                    {execution.error_output}
                  </div>
                )}
                {!execution.output && !execution.error_output && execution.status === 'running' && (
                  <div className="text-gray-500">Waiting for output...</div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ExecutionConsole;
