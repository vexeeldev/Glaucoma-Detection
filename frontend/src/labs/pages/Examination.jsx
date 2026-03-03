import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft, ChevronRight, CheckCircle, AlertCircle, Clock,
  Calendar, User, Info, FileText, Upload, Search, Download,
  Eye, Loader2,
} from 'lucide-react';
import {
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { COLORS } from '../data/constants';

const pieDataMap = {
  NORMAL: [{ name: 'Normal', value: 92 }, { name: 'Glaukoma', value: 8 }],
  GLAUKOMA: [{ name: 'Normal', value: 15 }, { name: 'Glaukoma', value: 85 }],
};

const Examination = () => {
  const navigate = useNavigate();
  const [examStep, setExamStep] = useState(1);
  const [mlLoading, setMlLoading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [selectedResult, setSelectedResult] = useState('NORMAL');

  const handleUpload = () => {
    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      setUploadProgress(progress);
      if (progress >= 100) {
        clearInterval(interval);
        setExamStep(3);
        setMlLoading(true);
        setTimeout(() => setMlLoading(false), 3000);
      }
    }, 200);
  };

  const pieData = pieDataMap[selectedResult];

  return (
    <div className="max-w-4xl mx-auto animate-in slide-in-from-bottom-4 duration-500">
      {/* Header */}
      <div className="mb-8 flex items-center gap-4">
        <button onClick={() => navigate('/dashboard')} className="p-2 hover:bg-gray-100 rounded-full">
          <ArrowLeft size={24} />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Alur Deteksi AI</h1>
          <p className="text-gray-500 text-sm">Pemeriksaan Pasien ID #3392</p>
        </div>
      </div>

      {/* Stepper Header */}
      <div className="flex items-center justify-between mb-12 relative px-10">
        <div className="absolute top-1/2 left-0 w-full h-1 bg-gray-200 -translate-y-1/2 -z-10"></div>
        <div
          className="absolute top-1/2 left-0 h-1 bg-blue-600 -translate-y-1/2 -z-10 transition-all duration-500"
          style={{ width: `${(examStep - 1) * 50}%` }}
        ></div>
        {[1, 2, 3].map((s) => (
          <div key={s} className="flex flex-col items-center gap-3">
            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-lg transition-all shadow-lg ${
                examStep >= s ? 'bg-blue-600 text-white scale-110' : 'bg-white text-gray-400 border-2 border-gray-200'
              }`}
            >
              {examStep > s ? <CheckCircle size={24} /> : s}
            </div>
            <span className={`text-sm font-semibold ${examStep >= s ? 'text-blue-600' : 'text-gray-400'}`}>
              {s === 1 ? 'Info Pasien' : s === 2 ? 'Upload Gambar' : 'Hasil Deteksi'}
            </span>
          </div>
        ))}
      </div>

      {/* Step 1: Info Pasien */}
      {examStep === 1 && (
        <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
            <div className="space-y-6">
              <div>
                <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Data Personal</h3>
                <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                  <div className="flex justify-between">
                    <span className="text-gray-500">Nama Lengkap</span>
                    <span className="font-bold">Andi Wijaya</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Usia / Gender</span>
                    <span className="font-bold">35 Th / Laki-laki</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">ID Medis</span>
                    <span className="font-bold text-blue-600">#PX-2025-009</span>
                  </div>
                </div>
              </div>
              <div>
                <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Informasi Janji</h3>
                <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                  <div className="flex items-center gap-3">
                    <Calendar size={18} className="text-blue-500" />
                    <span className="font-medium text-gray-700">Senin, 3 Maret 2025</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <Clock size={18} className="text-blue-500" />
                    <span className="font-medium text-gray-700">09:00 WIB</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <User size={18} className="text-blue-500" />
                    <span className="font-medium text-gray-700">dr. Budi Santoso</span>
                  </div>
                </div>
              </div>
            </div>
            <div>
              <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Keluhan Utama</h3>
              <div className="p-6 bg-blue-50 text-blue-800 rounded-3xl min-h-[160px] italic relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-10">
                  <FileText size={80} />
                </div>
                "Mata sering terasa kabur saat malam hari, terkadang melihat lingkaran pelangi di sekitar lampu jalan.
                Akhir-akhir ini sering sakit kepala di bagian depan."
              </div>
              <div className="mt-6 flex items-start gap-3 text-sm text-gray-500 p-4 border border-dashed border-gray-200 rounded-2xl">
                <Info size={20} className="text-orange-400 shrink-0" />
                Pasien memiliki riwayat tekanan darah tinggi (Hipertensi) sejak 2 tahun lalu.
              </div>
            </div>
          </div>
          <button
            onClick={() => setExamStep(2)}
            className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3"
          >
            Mulai Pemeriksaan <ChevronRight size={20} />
          </button>
        </div>
      )}

      {/* Step 2: Upload */}
      {examStep === 2 && (
        <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
          <div className="mb-10">
            <label className="block text-sm font-bold text-gray-700 mb-4">Upload Foto Retina (Fundus)</label>
            <div className="border-2 border-dashed border-gray-200 rounded-3xl p-12 text-center hover:border-blue-400 hover:bg-blue-50/50 transition-all cursor-pointer group">
              <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                <Upload size={32} className="text-blue-600" />
              </div>
              <p className="text-lg font-bold text-gray-900 mb-1">Pilih gambar atau tarik ke sini</p>
              <p className="text-sm text-gray-400">Dukung file JPG, PNG, atau TIFF (Maks. 10MB)</p>
              <div className="mt-6 grid grid-cols-3 gap-4 max-w-sm mx-auto">
                <div className="h-20 bg-gray-100 rounded-xl relative overflow-hidden flex items-center justify-center">
                  <img
                    src="https://picsum.photos/seed/eye1/200"
                    className="object-cover w-full h-full opacity-50"
                    alt="Preview"
                  />
                  <span className="absolute text-[10px] bg-black/60 text-white px-2 py-0.5 rounded-full font-bold">
                    PREVIEW
                  </span>
                </div>
                <div className="h-20 border-2 border-dashed border-gray-200 rounded-xl flex items-center justify-center text-gray-300">
                  <Upload size={16} />
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-3">Sisi Mata</label>
                <div className="grid grid-cols-3 gap-3">
                  {['Kiri', 'Kanan', 'Keduanya'].map((opt) => (
                    <button
                      key={opt}
                      className={`py-3 px-4 rounded-xl text-sm font-semibold border-2 transition-all ${
                        opt === 'Kiri'
                          ? 'border-blue-600 bg-blue-50 text-blue-600'
                          : 'border-gray-100 text-gray-500 hover:border-gray-200'
                      }`}
                    >
                      {opt}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-3">Model Kamera / Alat</label>
                <input
                  type="text"
                  placeholder="Contoh: Topcon TRC-NW8"
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
                  defaultValue="Canon CR-2 AF"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-3">Catatan Pengambilan (Opsional)</label>
              <textarea
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none h-[126px]"
                placeholder="Misal: Cahaya redup karena pupil tidak melebar maksimal"
              ></textarea>
            </div>
          </div>

          {uploadProgress > 0 && (
            <div className="mb-6">
              <div className="flex justify-between text-xs font-bold text-blue-600 mb-2">
                <span>MENGUPLOAD DATA KE CLOUD...</span>
                <span>{uploadProgress}%</span>
              </div>
              <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className="h-full bg-blue-600 transition-all duration-300"
                  style={{ width: `${uploadProgress}%` }}
                ></div>
              </div>
            </div>
          )}

          <button
            onClick={handleUpload}
            disabled={uploadProgress > 0}
            className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3 disabled:opacity-50"
          >
            Upload & Analisis Sekarang <Search size={20} />
          </button>
        </div>
      )}

      {/* Step 3: Hasil */}
      {examStep === 3 && (
        <div className="animate-in fade-in zoom-in-95 duration-700">
          {mlLoading ? (
            <div className="bg-white p-20 rounded-3xl shadow-sm border border-gray-100 flex flex-col items-center justify-center text-center">
              <div className="relative mb-8">
                <div className="w-24 h-24 border-8 border-blue-50 border-t-blue-600 rounded-full animate-spin"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <Eye className="text-blue-200" size={32} />
                </div>
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">Model sedang menganalisis...</h2>
              <p className="text-gray-500 max-w-sm">
                Sistem kami sedang memproses segmentasi cakram optik dan menghitung perbandingan cup-to-disc.
              </p>
            </div>
          ) : (
            <div className="space-y-6">
              {/* Demo Toggle */}
              <div className="flex bg-gray-200 p-1 rounded-2xl w-fit mx-auto shadow-inner">
                <button
                  onClick={() => setSelectedResult('NORMAL')}
                  className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${
                    selectedResult === 'NORMAL' ? 'bg-white shadow-md text-green-600' : 'text-gray-500'
                  }`}
                >
                  Demo: NORMAL
                </button>
                <button
                  onClick={() => setSelectedResult('GLAUKOMA')}
                  className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${
                    selectedResult === 'GLAUKOMA' ? 'bg-white shadow-md text-red-600' : 'text-gray-500'
                  }`}
                >
                  Demo: GLAUKOMA
                </button>
              </div>

              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <div className="flex flex-col md:flex-row gap-8 items-center mb-10">
                  <div
                    className={`p-8 rounded-[40px] flex flex-col items-center justify-center min-w-[240px] shadow-lg shadow-gray-100 border-2 ${
                      selectedResult === 'NORMAL' ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'
                    }`}
                  >
                    <p className="text-xs font-black uppercase tracking-widest text-gray-400 mb-2">Hasil Prediksi AI</p>
                    <h2
                      className={`text-4xl font-black mb-1 ${
                        selectedResult === 'NORMAL' ? 'text-green-700' : 'text-red-700'
                      }`}
                    >
                      {selectedResult}
                    </h2>
                    <div
                      className={`flex items-center gap-1 font-bold ${
                        selectedResult === 'NORMAL' ? 'text-green-600' : 'text-red-600'
                      }`}
                    >
                      {selectedResult === 'NORMAL' ? <CheckCircle size={18} /> : <AlertCircle size={18} />}
                      {selectedResult === 'NORMAL' ? 'Kesehatan Baik' : 'Tanda Glaukoma'}
                    </div>
                  </div>

                  <div className="flex-1 w-full">
                    <div className="flex justify-between mb-2 items-end">
                      <div>
                        <p className="text-sm font-bold text-gray-500">Tingkat Kepercayaan (Confidence)</p>
                        <p className="text-3xl font-black text-gray-900">
                          {selectedResult === 'NORMAL' ? '92' : '85'}%
                        </p>
                      </div>
                      <span className="text-xs font-bold text-gray-400 bg-gray-50 px-3 py-1 rounded-full border border-gray-100">
                        v4.2 PRO MODEL
                      </span>
                    </div>
                    <div className="h-4 bg-gray-100 rounded-full overflow-hidden mb-4">
                      <div
                        className={`h-full transition-all duration-1000 ${
                          selectedResult === 'NORMAL' ? 'bg-green-500' : 'bg-red-500'
                        }`}
                        style={{ width: selectedResult === 'NORMAL' ? '92%' : '85%' }}
                      ></div>
                    </div>
                    <p className="text-xs text-gray-400 italic">
                      Waktu pemrosesan:{' '}
                      <span className="text-gray-900 font-semibold">1.24 detik</span> pada server GPU-Edge.
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  {/* Pie Chart */}
                  <div>
                    <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                      <Info size={16} className="text-blue-500" /> Distribusi Probabilitas
                    </h3>
                    <div className="h-64">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie data={pieData} innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
                            {pieData.map((entry, index) => (
                              <Cell
                                key={`cell-${index}`}
                                fill={index === 0 ? COLORS.normal.hex : COLORS.glaucoma.hex}
                              />
                            ))}
                          </Pie>
                          <Tooltip />
                          <Legend verticalAlign="bottom" height={36} />
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  </div>

                  {/* Visualisasi */}
                  <div>
                    <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                      <Eye size={16} className="text-blue-500" /> Visualisasi Fitur AI
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-2">
                        <div className="aspect-square bg-gray-100 rounded-2xl overflow-hidden border border-gray-100">
                          <img
                            src="https://picsum.photos/seed/retina/400"
                            className="object-cover w-full h-full"
                            alt="Retina"
                          />
                        </div>
                        <p className="text-[10px] text-center font-bold text-gray-400 uppercase tracking-tighter">
                          Foto Retina Orisinal
                        </p>
                      </div>
                      <div className="space-y-2">
                        <div className="aspect-square bg-gray-100 rounded-2xl overflow-hidden border border-gray-100 relative">
                          <img
                            src="https://picsum.photos/seed/heatmap/400"
                            className="object-cover w-full h-full opacity-60 contrast-150"
                            alt="Heatmap"
                          />
                          <div className="absolute inset-0 bg-gradient-to-tr from-blue-500/30 to-red-500/50 mix-blend-overlay"></div>
                        </div>
                        <p className="text-[10px] text-center font-bold text-gray-400 uppercase tracking-tighter">
                          Heatmap (Grad-CAM)
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-4">
                <button className="flex-1 py-4 bg-white border-2 border-gray-100 rounded-2xl font-bold text-gray-600 hover:bg-gray-50 flex items-center justify-center gap-2 transition-all">
                  <Download size={20} /> Download PDF
                </button>
                <button
                  onClick={() => navigate('/dashboard')}
                  className="flex-[2] py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all"
                >
                  Selesai & Simpan Rekam Medis
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Examination;