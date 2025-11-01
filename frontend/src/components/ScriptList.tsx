import React, { useState, useEffect } from 'react';
import { scriptsAPI } from '../services/api';
import { Search, Play, Edit, Trash2, Filter, RefreshCw } from 'lucide-react';
import type { Script } from '../types';

interface ScriptListProps {
  onEdit: (script: Script) => void;
  onExecute: (script: Script) => void;
}

const ScriptList: React.FC<ScriptListProps> = ({ onEdit, onExecute }) => {
  const [scripts, setScripts] = useState<Script[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [categories, setCategories] = useState<string[]>([]);

  const loadScripts = async () => {
    setLoading(true);
    try {
      const data = await scriptsAPI.list({
        search: searchTerm || undefined,
        category: selectedCategory || undefined,
      });
      setScripts(data);
    } catch (error) {
      console.error('Failed to load scripts:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadCategories = async () => {
    try {
      const data = await scriptsAPI.getCategories();
      setCategories(data);
    } catch (error) {
      console.error('Failed to load categories:', error);
    }
  };

  useEffect(() => {
    loadScripts();
    loadCategories();
  }, []);

  useEffect(() => {
    const debounce = setTimeout(() => {
      loadScripts();
    }, 300);
    return () => clearTimeout(debounce);
  }, [searchTerm, selectedCategory]);

  const handleDelete = async (script: Script) => {
    if (!confirm(`Delete script "${script.name}"?`)) return;

    try {
      await scriptsAPI.delete(script.id);
      loadScripts();
    } catch (error) {
      alert('Failed to delete script');
    }
  };

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      VMware: 'bg-green-600',
      Azure: 'bg-blue-600',
      'Active Directory': 'bg-purple-600',
      Utilities: 'bg-gray-600',
      Network: 'bg-yellow-600',
      Security: 'bg-red-600',
    };
    return colors[category] || 'bg-gray-600';
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h2 className="text-3xl font-bold text-white mb-4">PowerShell Scripts</h2>

        {/* Search and Filter Bar */}
        <div className="flex gap-4 mb-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-3 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search scripts..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
            />
          </div>

          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
          >
            <option value="">All Categories</option>
            {categories.map((cat) => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>

          <button
            onClick={loadScripts}
            className="px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white hover:bg-gray-700"
          >
            <RefreshCw className="w-5 h-5" />
          </button>
        </div>
      </div>

      {loading ? (
        <div className="text-center text-gray-400 py-12">Loading scripts...</div>
      ) : scripts.length === 0 ? (
        <div className="text-center text-gray-400 py-12">
          No scripts found. Create your first script!
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {scripts.map((script) => (
            <div
              key={script.id}
              className="bg-gray-800 border border-gray-700 rounded-lg p-4 hover:border-blue-500 transition"
            >
              <div className="flex items-start justify-between mb-2">
                <h3 className="text-lg font-semibold text-white">{script.name}</h3>
                <span
                  className={`px-2 py-1 text-xs rounded text-white ${getCategoryColor(
                    script.category
                  )}`}
                >
                  {script.category}
                </span>
              </div>

              <p className="text-gray-400 text-sm mb-3 line-clamp-2">
                {script.description || 'No description'}
              </p>

              <div className="flex flex-wrap gap-1 mb-3">
                {script.tags.slice(0, 3).map((tag, idx) => (
                  <span
                    key={idx}
                    className="px-2 py-1 bg-gray-700 text-gray-300 text-xs rounded"
                  >
                    {tag}
                  </span>
                ))}
              </div>

              <div className="flex items-center justify-between text-xs text-gray-500 mb-3">
                <span>by {script.author_username}</span>
                <span>{script.execution_count} runs</span>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => onExecute(script)}
                  className="flex-1 flex items-center justify-center px-3 py-2 bg-green-600 hover:bg-green-700 text-white rounded transition"
                >
                  <Play className="w-4 h-4 mr-1" />
                  Execute
                </button>
                <button
                  onClick={() => onEdit(script)}
                  className="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded transition"
                >
                  <Edit className="w-4 h-4" />
                </button>
                <button
                  onClick={() => handleDelete(script)}
                  className="px-3 py-2 bg-red-600 hover:bg-red-700 text-white rounded transition"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ScriptList;
