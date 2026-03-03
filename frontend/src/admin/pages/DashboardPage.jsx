import {
  Users,
  Stethoscope,
  Calendar,
  AlertCircle,
  TrendingUp,
  ArrowRight,
  Eye,
} from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts';

import StatCard from '../components/StatCard';
import Badge from '../components/Badge';
import { MONTHLY_DATA, PIE_DATA, RECENT_EXAMS } from '../data/dummy';

const DashboardPage = () => (
  <div className="space-y-8 animate-in fade-in duration-500">
    {/* KPI row */}
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <StatCard title="Total Pasien"          value="128" icon={Users}       colorClass="bg-blue-600"   trend="+12% bulan ini" />
      <StatCard title="Total Dokter"           value="12"  icon={Stethoscope} colorClass="bg-emerald-600" />
      <StatCard title="Pemeriksaan Hari Ini"   value="24"  icon={Calendar}    colorClass="bg-orange-500" trend="+5 hari ini" />
      <StatCard title="Terdeteksi Glaukoma"    value="8"   icon={AlertCircle} colorClass="bg-red-600" />
    </div>

    {/* Secondary stats */}
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <p className="text-sm text-gray-500 mb-1">Appointment Menunggu</p>
        <h3 className="text-2xl font-bold">5</h3>
      </div>
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <p className="text-sm text-gray-500 mb-1">Rata-rata Confidence</p>
        <h3 className="text-2xl font-bold text-blue-600">89.4%</h3>
      </div>
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <p className="text-sm text-gray-500 mb-1">Model ML Aktif</p>
        <h3 className="text-2xl font-bold text-purple-600">v2.1.0</h3>
      </div>
    </div>

    {/* Charts */}
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
          <TrendingUp className="text-blue-600" size={20} /> Pemeriksaan per Bulan
        </h3>
        <div className="h-[300px]">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={MONTHLY_DATA}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="name" axisLine={false} tickLine={false} />
              <YAxis axisLine={false} tickLine={false} />
              <Tooltip cursor={{ fill: '#f8fafc' }} />
              <Legend iconType="circle" />
              <Bar dataKey="Glaukoma" fill="#EF5350" radius={[4, 4, 0, 0]} />
              <Bar dataKey="Normal"   fill="#42A5F5" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
        <h3 className="text-lg font-bold mb-6">Distribusi Hasil Deteksi</h3>
        <div className="h-[300px] flex items-center justify-center">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={PIE_DATA}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={100}
                paddingAngle={5}
                dataKey="value"
              >
                <Cell fill="#EF5350" />
                <Cell fill="#42A5F5" />
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>

    {/* Recent exams table */}
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div className="p-6 border-b flex justify-between items-center">
        <h3 className="text-lg font-bold">Pemeriksaan Terbaru</h3>
        <button className="text-blue-600 text-sm font-semibold hover:underline flex items-center gap-1">
          Lihat Semua <ArrowRight size={14} />
        </button>
      </div>
      <table className="w-full text-left">
        <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
          <tr>
            <th className="px-6 py-4">Pasien</th>
            <th className="px-6 py-4">Dokter</th>
            <th className="px-6 py-4">Tanggal</th>
            <th className="px-6 py-4 text-center">Hasil</th>
            <th className="px-6 py-4">Confidence</th>
            <th className="px-6 py-4 text-right">Aksi</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {RECENT_EXAMS.map((exam) => (
            <tr key={exam.id} className="hover:bg-gray-50 transition-colors">
              <td className="px-6 py-4 font-medium text-gray-800">{exam.patient}</td>
              <td className="px-6 py-4 text-gray-600">{exam.doctor}</td>
              <td className="px-6 py-4 text-gray-500 text-sm">{exam.date}</td>
              <td className="px-6 py-4 text-center">
                <Badge variant={exam.result}>{exam.result}</Badge>
              </td>
              <td className="px-6 py-4">
                <div className="flex items-center gap-2">
                  <div className="w-full bg-gray-100 h-1.5 rounded-full overflow-hidden max-w-[60px]">
                    <div className="bg-blue-500 h-full" style={{ width: exam.confidence }} />
                  </div>
                  <span className="text-sm text-gray-600">{exam.confidence}</span>
                </div>
              </td>
              <td className="px-6 py-4 text-right">
                <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                  <Eye size={18} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  </div>
);

export default DashboardPage;
