import { useState } from 'react';
import { Cpu, Plus } from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

import Badge from '../components/Badge';
import Modal from '../components/Modal';
import { ML_MODELS_DATA, MODEL_COMPARISON } from '../data/dummy';

const MLModelPage = () => {
  const [showAddModal, setShowAddModal] = useState(false);

  return (
    <div className="space-y-6">
      {/* Active model hero */}
      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between bg-gradient-to-r from-white to-purple-50">
        <div className="flex items-center gap-6">
          <div className="w-20 h-20 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center shadow-inner">
            <Cpu size={40} />
          </div>
          <div>
            <div className="flex items-center gap-2 mb-1">
              <h3 className="text-3xl font-black text-gray-800 tracking-tight">
                EfficientNetB4 <span className="text-purple-600">v2.1.0</span>
              </h3>
              <Badge variant="active">AKTIF</Badge>
            </div>
            <p className="text-gray-500 font-medium">
              Model produksi utama untuk deteksi glaukoma otomatis.
            </p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-x-8 gap-y-2 text-right">
          <div>
            <p className="text-xs text-gray-400 font-bold uppercase">Akurasi</p>
            <p className="text-xl font-bold text-blue-600">95.23%</p>
          </div>
          <div>
            <p className="text-xs text-gray-400 font-bold uppercase">AUC-ROC</p>
            <p className="text-xl font-bold text-blue-600">0.9812</p>
          </div>
        </div>
      </div>

      {/* Charts + training info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="text-lg font-bold mb-6">Perbandingan Akurasi Versi</h3>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={MODEL_COMPARISON} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" hide />
                <YAxis
                  dataKey="version"
                  type="category"
                  axisLine={false}
                  tickLine={false}
                  width={70}
                />
                <Tooltip cursor={{ fill: 'transparent' }} />
                <Bar
                  dataKey="accuracy"
                  fill="#1565C0"
                  radius={[0, 4, 4, 0]}
                  label={{ position: 'right', formatter: (v) => `${v}%`, fontSize: 12, fontWeight: 'bold' }}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="text-lg font-bold mb-4">Informasi Training Terakhir</h3>
          <div className="space-y-4">
            {[
              { label: 'Total Dataset Training', value: '12,450 Citra' },
              { label: 'Data Validation',         value: '2,100 Citra'  },
              { label: 'Epochs',                  value: '150'          },
              { label: 'Training Time',            value: '14h 22m'     },
            ].map(({ label, value }) => (
              <div key={label} className="flex justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-gray-500">{label}</span>
                <span className="font-bold">{value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Model history table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-6 border-b flex justify-between items-center">
          <h3 className="text-lg font-bold">Riwayat Model</h3>
          <button
            onClick={() => setShowAddModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-all font-bold"
          >
            <Plus size={20} /> Daftarkan Model Baru
          </button>
        </div>
        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
            <tr>
              <th className="px-6 py-4">Versi</th>
              <th className="px-6 py-4">Arsitektur</th>
              <th className="px-6 py-4 text-center">Akurasi</th>
              <th className="px-6 py-4 text-center">AUC-ROC</th>
              <th className="px-6 py-4">Deploy</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {ML_MODELS_DATA.map((m) => (
              <tr key={m.version} className="hover:bg-gray-50">
                <td className="px-6 py-4 font-bold text-blue-600">{m.version}</td>
                <td className="px-6 py-4">{m.arch}</td>
                <td className="px-6 py-4 text-center font-bold">{m.accuracy}</td>
                <td className="px-6 py-4 text-center">{m.auc}</td>
                <td className="px-6 py-4 text-gray-500 text-sm">{m.deploy}</td>
                <td className="px-6 py-4">
                  <Badge variant={m.status === 'AKTIF' ? 'active' : 'default'}>{m.status}</Badge>
                </td>
                <td className="px-6 py-4 text-right">
                  {m.status !== 'AKTIF' && (
                    <button className="text-blue-600 hover:underline font-bold text-sm">
                      Aktifkan
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Add model modal */}
      <Modal
        isOpen={showAddModal}
        onClose={() => setShowAddModal(false)}
        title="Daftarkan Model ML Baru"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-bold">Versi Model</label>
              <input
                type="text"
                className="w-full px-3 py-2 border rounded-lg mt-1"
                placeholder="v2.2.0"
              />
            </div>
            <div>
              <label className="text-sm font-bold">Arsitektur</label>
              <select className="w-full px-3 py-2 border rounded-lg mt-1">
                <option>EfficientNet</option>
                <option>ResNet</option>
                <option>VGG</option>
              </select>
            </div>
          </div>
          <div>
            <label className="text-sm font-bold">Path Model File (.h5 / .onnx)</label>
            <input
              type="text"
              className="w-full px-3 py-2 border rounded-lg mt-1"
              placeholder="/models/eye/v220.h5"
            />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="text-xs font-bold">Accuracy (%)</label>
              <input type="text" className="w-full px-3 py-2 border rounded-lg mt-1" />
            </div>
            <div>
              <label className="text-xs font-bold">Sensitivity</label>
              <input type="text" className="w-full px-3 py-2 border rounded-lg mt-1" />
            </div>
            <div>
              <label className="text-xs font-bold">AUC-ROC</label>
              <input type="text" className="w-full px-3 py-2 border rounded-lg mt-1" />
            </div>
          </div>
          <div>
            <label className="text-sm font-bold">Changelog / Deskripsi</label>
            <textarea
              className="w-full px-3 py-2 border rounded-lg mt-1 h-20"
              placeholder="Apa yang baru di versi ini?"
            />
          </div>
          <button className="w-full bg-blue-600 text-white font-bold py-3 rounded-xl">
            Simpan &amp; Daftarkan
          </button>
        </div>
      </Modal>
    </div>
  );
};

export default MLModelPage;
