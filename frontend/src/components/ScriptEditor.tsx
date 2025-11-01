import React, { useState, useEffect } from 'react';
import Editor from '@monaco-editor/react';
import { scriptsAPI } from '../services/api';
import { Save, X, Plus, Trash2 } from 'lucide-react';
import type { Script, ScriptParameter } from '../types';

interface ScriptEditorProps {
  script: Script | null;
  onSaved: () => void;
}

const ScriptEditor: React.FC<ScriptEditorProps> = ({ script, onSaved }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    content: '# PowerShell Script\n\n',
    category: 'Utilities',
    tags: [] as string[],
    parameters: [] as ScriptParameter[],
    is_public: false,
  });
  const [newTag, setNewTag] = useState('');
  const [saving, setSaving] = useState(false);
  const [categories, setCategories] = useState<string[]>([]);

  useEffect(() => {
    if (script) {
      setFormData({
        name: script.name,
        description: script.description,
        content: script.content || '',
        category: script.category,
        tags: script.tags || [],
        parameters: script.parameters || [],
        is_public: script.is_public,
      });
    }

    scriptsAPI.getCategories().then(setCategories);
  }, [script]);

  const handleSave = async () => {
    if (!formData.name || !formData.content) {
      alert('Name and content are required');
      return;
    }

    setSaving(true);
    try {
      if (script) {
        await scriptsAPI.update(script.id, formData);
      } else {
        await scriptsAPI.create(formData);
      }
      onSaved();
    } catch (error: any) {
      alert(error.response?.data?.error || 'Failed to save script');
    } finally {
      setSaving(false);
    }
  };

  const addTag = () => {
    if (newTag && !formData.tags.includes(newTag)) {
      setFormData({ ...formData, tags: [...formData.tags, newTag] });
      setNewTag('');
    }
  };

  const removeTag = (tag: string) => {
    setFormData({
      ...formData,
      tags: formData.tags.filter((t) => t !== tag),
    });
  };

  const addParameter = () => {
    const param: ScriptParameter = {
      name: '',
      type: 'string',
      description: '',
      required: false,
    };
    setFormData({
      ...formData,
      parameters: [...formData.parameters, param],
    });
  };

  const updateParameter = (index: number, updates: Partial<ScriptParameter>) => {
    const newParams = [...formData.parameters];
    newParams[index] = { ...newParams[index], ...updates };
    setFormData({ ...formData, parameters: newParams });
  };

  const removeParameter = (index: number) => {
    setFormData({
      ...formData,
      parameters: formData.parameters.filter((_, i) => i !== index),
    });
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 px-6 py-4 flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">
          {script ? 'Edit Script' : 'New Script'}
        </h2>
        <div className="flex gap-2">
          <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center px-4 py-2 bg-green-600 hover:bg-green-700 disabled:bg-green-800 text-white rounded transition"
          >
            <Save className="w-4 h-4 mr-2" />
            {saving ? 'Saving...' : 'Save'}
          </button>
          <button
            onClick={onSaved}
            className="flex items-center px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded transition"
          >
            <X className="w-4 h-4 mr-2" />
            Cancel
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-auto">
        <div className="grid grid-cols-3 gap-6 p-6 h-full">
          {/* Left Column - Metadata */}
          <div className="space-y-4">
            <div>
              <label className="block text-gray-300 mb-2">Script Name *</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
                placeholder="My PowerShell Script"
              />
            </div>

            <div>
              <label className="block text-gray-300 mb-2">Description</label>
              <textarea
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
                rows={3}
                placeholder="What does this script do?"
              />
            </div>

            <div>
              <label className="block text-gray-300 mb-2">Category</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
              >
                {categories.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-gray-300 mb-2">Tags</label>
              <div className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={newTag}
                  onChange={(e) => setNewTag(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && addTag()}
                  className="flex-1 px-4 py-2 bg-gray-800 border border-gray-700 rounded text-white focus:outline-none focus:border-blue-500"
                  placeholder="Add tag"
                />
                <button
                  onClick={addTag}
                  className="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded"
                >
                  <Plus className="w-4 h-4" />
                </button>
              </div>
              <div className="flex flex-wrap gap-2">
                {formData.tags.map((tag, idx) => (
                  <span
                    key={idx}
                    className="px-2 py-1 bg-gray-700 text-gray-300 text-sm rounded flex items-center"
                  >
                    {tag}
                    <button
                      onClick={() => removeTag(tag)}
                      className="ml-2 text-red-400 hover:text-red-300"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                ))}
              </div>
            </div>

            <div>
              <label className="flex items-center text-gray-300">
                <input
                  type="checkbox"
                  checked={formData.is_public}
                  onChange={(e) =>
                    setFormData({ ...formData, is_public: e.target.checked })
                  }
                  className="mr-2"
                />
                Make script public
              </label>
            </div>

            {/* Parameters Section */}
            <div className="border-t border-gray-700 pt-4">
              <div className="flex items-center justify-between mb-2">
                <label className="text-gray-300">Parameters</label>
                <button
                  onClick={addParameter}
                  className="px-2 py-1 bg-blue-600 hover:bg-blue-700 text-white text-sm rounded"
                >
                  <Plus className="w-4 h-4" />
                </button>
              </div>

              <div className="space-y-2 max-h-64 overflow-auto">
                {formData.parameters.map((param, idx) => (
                  <div key={idx} className="bg-gray-800 p-2 rounded border border-gray-700">
                    <div className="flex items-center justify-between mb-1">
                      <input
                        type="text"
                        value={param.name}
                        onChange={(e) =>
                          updateParameter(idx, { name: e.target.value })
                        }
                        className="flex-1 px-2 py-1 bg-gray-700 text-white text-sm rounded"
                        placeholder="Parameter name"
                      />
                      <button
                        onClick={() => removeParameter(idx)}
                        className="ml-2 text-red-400 hover:text-red-300"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                    <div className="flex gap-2">
                      <select
                        value={param.type}
                        onChange={(e) =>
                          updateParameter(idx, {
                            type: e.target.value as any,
                          })
                        }
                        className="px-2 py-1 bg-gray-700 text-white text-xs rounded"
                      >
                        <option value="string">String</option>
                        <option value="int">Integer</option>
                        <option value="bool">Boolean</option>
                      </select>
                      <label className="flex items-center text-xs text-gray-300">
                        <input
                          type="checkbox"
                          checked={param.required}
                          onChange={(e) =>
                            updateParameter(idx, { required: e.target.checked })
                          }
                          className="mr-1"
                        />
                        Required
                      </label>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right Column - Code Editor */}
          <div className="col-span-2 bg-gray-800 rounded border border-gray-700 overflow-hidden">
            <div className="bg-gray-900 px-4 py-2 border-b border-gray-700">
              <span className="text-gray-300 text-sm font-mono">PowerShell Script</span>
            </div>
            <Editor
              height="calc(100vh - 250px)"
              defaultLanguage="powershell"
              value={formData.content}
              onChange={(value) =>
                setFormData({ ...formData, content: value || '' })
              }
              theme="vs-dark"
              options={{
                minimap: { enabled: false },
                fontSize: 14,
                lineNumbers: 'on',
                scrollBeyondLastLine: false,
                automaticLayout: true,
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default ScriptEditor;
