import { useState } from 'react';
import { Search } from 'lucide-react';

import Modal from '../components/Modal';
import { ACTIVITY_LOGS_DATA } from '../data/dummy';

const MODULE_COLORS = {
  Auth:        'bg-blue-100 text-blue-700',
  Examination: 'bg-emerald-100 text-emerald-700',
  ML:          'bg-purple-100 text-purple-700',
  Appointment: 'bg-orange-100 text-orange-700',
  Admin:       'bg-gray-100 text-gray-700',
  User:        'bg-rose-100 text-rose-700',
};

const ModuleBadge = ({ module }) => (
  <span
    className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
      MODULE_COLORS[module] || 'bg-gray-100 text-gray-700'
    }`}
  >
    {module}
  </span>
);

const ActivityLogPage = () => {
  const [selectedLog, setSelectedLog] = useState(null);

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-wrap gap-4 items-center">
        <div className="relative flex-1 min-w-[300px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Cari nama user..."
            className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 outline-none focus:border-blue-500"
          />
        </div>
        <select className="px-4 py-2 rounded-lg border border-gray-200 outline-none">
          <option>Semua Modul</option>
          <option>Auth</option>
          <option>Appointment</option>
        </select>
        <select className="px-4 py-2 rounded-lg border border-gray-200 outline-none">
          <option>Semua Aksi</option>
          <option>Create</option>
          <option>Delete</option>
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
            <tr>
              <th className="px-6 py-4">Waktu</th>
              <th className="px-6 py-4">User</th>
              <th className="px-6 py-4">Modul</th>
              <th className="px-6 py-4">Aksi</th>
              <th className="px-6 py-4">Deskripsi</th>
              <th className="px-6 py-4">IP</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {ACTIVITY_LOGS_DATA.map((log) => (
              <tr
                key={log.id}
                className="hover:bg-gray-50 cursor-pointer"
                onClick={() => setSelectedLog(log)}
              >
                <td className="px-6 py-4 text-sm text-gray-400">{log.time}</td>
                <td className="px-6 py-4 font-bold text-gray-800 text-sm">{log.user}</td>
                <td className="px-6 py-4">
                  <ModuleBadge module={log.module} />
                </td>
                <td className="px-6 py-4">
                  <span className="text-xs font-bold">{log.action}</span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-500">{log.desc}</td>
                <td className="px-6 py-4 text-[10px] font-mono text-gray-400">{log.ip}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="p-4 text-center border-t">
          <button className="text-blue-600 font-bold text-sm">Muat Lebih Banyak</button>
        </div>
      </div>

      {/* Detail modal */}
      <Modal
        isOpen={!!selectedLog}
        onClose={() => setSelectedLog(null)}
        title="Detail Log Aktivitas"
      >
        {selectedLog && (
          <div className="space-y-4">
            <div className="bg-gray-900 text-green-400 p-6 rounded-xl font-mono text-sm">
              <p className="mb-2">{'{'}</p>
              <p className="ml-4">"id": "{selectedLog.id}",</p>
              <p className="ml-4">"timestamp": "2023-10-24T14:30:00Z",</p>
              <p className="ml-4">"user": "{selectedLog.user}",</p>
              <p className="ml-4">"action": "{selectedLog.action}",</p>
              <p className="ml-4">"ip_address": "{selectedLog.ip}",</p>
              <p className="ml-4">"user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...",</p>
              <p className="ml-4">"old_data": null,</p>
              <p className="ml-4">
                {"\"new_data\": { \"status\": \"active\", \"updated_at\": \"...\" }"}
              </p>
              <p>{'}'}</p>
            </div>
            <p className="text-sm text-gray-500 italic">
              Data log ini tersimpan secara permanen untuk kebutuhan audit sistem GlaucoScan.
            </p>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default ActivityLogPage;
