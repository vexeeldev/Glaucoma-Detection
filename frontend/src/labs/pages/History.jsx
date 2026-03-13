import { useState, useEffect } from 'react';
import axios from '../../utils/axios'; 
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import * as XLSX from 'xlsx';
import {
  Search, Calendar, Filter, FileText, Download, LogOut, Eye as EyeIcon,
} from 'lucide-react';

// --- MODAL DETAIL ---
const HistoryDetailModal = ({ data, onClose }) => {
  const resultStr = data.result ? data.result.toUpperCase() : "NORMAL";
  const isGlaucoma = resultStr.includes('GLAUCOMA') || resultStr.includes('GLAUKOMA');
  
  // Logika Skor: Jika Normal, balikkan (100 - conf)
  const rawScore = Number(data.conf) || 0;
  const displayScore = isGlaucoma ? rawScore : (100 - rawScore);

  // --- FUNGSI GENERATE PDF (MEDICAL STANDARD) ---
  const generatePDF = async () => {
    const doc = new jsPDF();
    const dateStr = data.display_date || data.date;

    // Helper: Convert URL ke Base64
    const getBase64Image = (url) => {
      return new Promise((resolve, reject) => {
        const img = new Image();
        img.crossOrigin = "Anonymous"; // WAJIB DI ATAS SRC
        img.src = url; 
        
        img.onload = () => {
          const canvas = document.createElement("canvas");
          canvas.width = img.width;
          canvas.height = img.height;
          const ctx = canvas.getContext("2d");
          ctx.drawImage(img, 0, 0);
          resolve(canvas.toDataURL("image/jpeg"));
        };
        img.onerror = (e) => reject(e);
      });
    };

    try {
      // 1. Header
      doc.setFont("helvetica", "bold");
      doc.setFontSize(18);
      doc.setTextColor(44, 62, 80);
      doc.text("MEDICAL EXAMINATION REPORT", 105, 20, { align: "center" });
      
      doc.setFontSize(9);
      doc.setFont("helvetica", "normal");
      doc.setTextColor(127, 140, 141);
      doc.text("GlaucoScan AI Diagnostic System v1.0", 105, 25, { align: "center" });
      doc.line(20, 30, 190, 30);

      // 2. Info Pasien
      autoTable(doc, {
        startY: 35,
        theme: 'plain',
        styles: { fontSize: 9, cellPadding: 1 },
        columnStyles: { 0: { fontStyle: 'bold', width: 35 }, 2: { fontStyle: 'bold', width: 35 } },
        body: [
          ['Patient Name', `: ${data.name}`, 'Date of Exam', `: ${dateStr}`],
          ['Examination ID', `: #${data.id}`, 'Physician', `: ${data.doctor}`],
          ['Eye Side', `: ${data.eye}`, 'Method', ': AI Fundus Analysis']
        ],
      });

      // 3. Diagnostic Summary
      const currentY = doc.lastAutoTable.finalY + 15;
      doc.setFontSize(11);
      doc.setFont("helvetica", "bold");
      doc.setTextColor(44, 62, 80);
      doc.text("DIAGNOSTIC SUMMARY", 20, currentY);

      autoTable(doc, {
        startY: currentY + 5,
        headStyles: { fillColor: [245, 247, 250], textColor: [44, 62, 80], fontStyle: 'bold' },
        bodyStyles: { fontSize: 12 },
        head: [['Parameter', 'Analysis Result']],
        body: [
          ['Classification', { 
              content: resultStr, 
              styles: { textColor: isGlaucoma ? [200, 0, 0] : [0, 150, 0], fontStyle: 'bold' } 
          }],
          ['Confidence Level', `${displayScore.toFixed(2)}%`]
        ],
      });

      // 4. Imaging Data
      const imageY = doc.lastAutoTable.finalY + 15;
      doc.setFontSize(11);
      doc.text("IMAGING DATA", 20, imageY);

      const baseUrl = "http://localhost:8000/api/proxy-image?path=fundus_images/";
      const fundusUrl = data.image_url ? `${baseUrl}${data.image_url.split('/').pop()}` : null;
      const heatmapUrl = data.heatmap_url ? `${baseUrl}${data.heatmap_url.split('/').pop()}` : null;

      if (fundusUrl) {
        try {
          const imgData = await getBase64Image(fundusUrl);
          doc.addImage(imgData, 'JPEG', 20, imageY + 5, 80, 50);
          doc.setFontSize(8);
          doc.text("Fig 1: Fundus Photograph", 20, imageY + 60);
        } catch (e) { doc.text("[Fundus image load failed]", 20, imageY + 25); }
      }

      if (heatmapUrl) {
        try {
          const heatData = await getBase64Image(heatmapUrl);
          doc.addImage(heatData, 'JPEG', 110, imageY + 5, 80, 50);
          doc.setFontSize(8);
          doc.text("Fig 2: AI Localization (Heatmap)", 110, imageY + 60);
        } catch (e) { doc.text("[Heatmap load failed]", 110, imageY + 25); }
      }

      // 5. Clinical Notes
      const notesY = imageY + 75;
      doc.setFontSize(11);
      doc.setFont("helvetica", "bold");
      doc.text("CLINICAL NOTES & ADVICE", 20, notesY);
      
      doc.setFontSize(10);
      doc.setFont("helvetica", "normal");
      const advice = data.advice || "No specific clinical notes provided. Regular follow-up is recommended.";
      doc.text(doc.splitTextToSize(advice, 170), 20, notesY + 8);

      // 6. Footer
      doc.setFontSize(8);
      doc.setTextColor(150);
      doc.text("This is a computer-generated report by GlaucoScan AI.", 20, 280);
      doc.text(`Page 1/1`, 190, 280, { align: "right" });

      doc.save(`Report_${data.name.replace(/\s+/g, '_')}.pdf`);

    } catch (error) {
      console.error(error);
      alert("Gagal memproses PDF. Cek koneksi server!");
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-blue-900/60 backdrop-blur-sm" onClick={onClose}></div>
      <div className="bg-white w-full max-w-4xl rounded-[32px] shadow-2xl relative overflow-hidden flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-300">
        
        {/* Header */}
        <div className="p-8 border-b border-gray-100 flex justify-between items-center">
          <div>
            <p className="text-xs font-black text-blue-600 uppercase tracking-widest mb-1">Arsip Medis #{data.id}</p>
            <h2 className="text-2xl font-bold text-gray-900">{data.name}</h2>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full text-gray-400">
            <LogOut className="rotate-180" size={24} />
          </button>
        </div>

        {/* Body */}
        <div className="p-8 overflow-y-auto flex-1 bg-gray-50/50">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 space-y-8">
              <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                <h3 className="font-bold text-gray-900 mb-6 flex items-center gap-2">
                  <EyeIcon size={20} className="text-blue-600" /> Hasil Analisis AI
                </h3>
                <div className="flex gap-6 items-center mb-8">
                  <div className={`p-6 rounded-2xl text-center min-w-[160px] ${isGlaucoma ? 'bg-red-50 text-red-700 border border-red-100' : 'bg-green-50 text-green-700 border border-green-100'}`}>
                    <p className="text-[10px] font-black uppercase mb-1 opacity-50">Status</p>
                    <span className="text-2xl font-black">{resultStr}</span>
                  </div>
                  <div className="flex-1">
                    <div className="flex justify-between mb-2">
                      <span className="text-sm font-bold text-gray-500">Confidence Score</span>
                      <span className="text-sm font-black text-gray-900">{displayScore.toFixed(1)}%</span>
                    </div>
                    <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                      <div className={`h-full transition-all duration-1000 ${isGlaucoma ? 'bg-red-500' : 'bg-green-500'}`} style={{ width: `${displayScore}%` }}></div>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2 text-center">
                    <img src={data.image_url ? `http://localhost:8000/storage/fundus_images/${data.image_url.split('/').pop()}` : "https://picsum.photos/400"} className="w-full aspect-video object-cover rounded-2xl border" alt="Fundus" />
                    <p className="text-[10px] font-bold text-gray-400 uppercase">Foto Fundus</p>
                  </div>
                  <div className="space-y-2 text-center">
                    <img src={data.heatmap_url ? `http://localhost:8000/storage/fundus_images/${data.heatmap_url.split('/').pop()}` : "https://picsum.photos/400"} className="w-full aspect-video object-cover rounded-2xl border" alt="Heatmap" />
                    <p className="text-[10px] font-bold text-gray-400 uppercase">Heatmap</p>
                  </div>
                </div>
              </div>

              <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FileText size={20} className="text-blue-600" /> Diagnosis Dokter
                </h3>
                <p className="p-5 bg-blue-50/50 border border-blue-100 rounded-2xl text-blue-900 italic text-sm leading-relaxed">
                  "{data.advice || "Analisis AI menunjukkan kondisi retina saat ini."}"
                </p>
              </div>
            </div>

            <div className="space-y-6">
              <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">Info Pasien</h3>
                <div className="space-y-4">
                  <div><p className="text-[10px] text-gray-400 font-bold uppercase">Nama</p><p className="font-bold text-gray-900">{data.name}</p></div>
                  <div><p className="text-[10px] text-gray-400 font-bold uppercase">Tanggal</p><p className="font-bold text-gray-900">{data.display_date || data.date}</p></div>
                  <div><p className="text-[10px] text-gray-400 font-bold uppercase">Mata</p><p className="font-bold text-gray-900">{data.eye}</p></div>
                  <div><p className="text-[10px] text-gray-400 font-bold uppercase">Dokter</p><p className="font-bold text-gray-900">{data.doctor}</p></div>
                </div>
              </div>
              <button onClick={generatePDF} className="w-full py-4 bg-green-600 text-white rounded-2xl font-bold shadow-lg flex items-center justify-center gap-2 hover:bg-green-700 transition-all">
                <Download size={20} /> Download PDF Report
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// --- MAIN COMPONENT ---
const History = () => {
  const [selectedHistory, setSelectedHistory] = useState(null);
  const [historyList, setHistoryList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterResult, setFilterResult] = useState('Semua');
  const [filterDate, setFilterDate] = useState('');

  useEffect(() => {
    const fetchHistory = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/labs/history', {
          params: { search: searchTerm, result: filterResult, date: filterDate }
        });
        setHistoryList(response.data);
      } catch (error) { console.error(error); }
      finally { setLoading(false); }
    };
    const delay = setTimeout(fetchHistory, 500);
    return () => clearTimeout(delay);
  }, [searchTerm, filterResult, filterDate]);

  const exportExcel = () => {
    const ws = XLSX.utils.json_to_sheet(historyList);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "History");
    XLSX.writeFile(wb, `History_Export.xlsx`);
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-end mb-8">
        <div><h1 className="text-2xl font-bold text-gray-900">Riwayat Pemeriksaan</h1><p className="text-gray-500">Arsip data medis AI</p></div>
        <button onClick={exportExcel} className="bg-green-600 text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:bg-green-700 transition-all shadow-lg">
          <FileText size={18} /> Export Excel
        </button>
      </div>

      <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-6 border-b border-gray-50 flex flex-wrap gap-4 items-center">
          <div className="relative flex-1 min-w-[300px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input className="w-full pl-12 pr-4 py-2.5 rounded-xl border outline-none focus:ring-2 focus:ring-blue-500" placeholder="Cari nama pasien..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
          </div>
          <input type="date" className="border rounded-xl px-4 py-2.5 text-sm" value={filterDate} onChange={(e) => setFilterDate(e.target.value)} />
          <select className="border rounded-xl px-4 py-2.5 text-sm outline-none" value={filterResult} onChange={(e) => setFilterResult(e.target.value)}>
            <option value="Semua">Semua Status</option>
            <option value="NORMAL">Normal</option>
            <option value="GLAUCOMA">Glaucoma</option>
          </select>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
            <div className="p-20 text-center text-gray-400 animate-pulse italic font-bold">Sinkronisasi Data...</div>
          ) : (
            <table className="w-full text-left">
              <thead className="bg-gray-50 text-xs uppercase text-gray-400 font-bold">
                <tr>
                  <th className="px-6 py-4 text-center">No</th>
                  <th className="px-6 py-4">Pasien</th>
                  <th className="px-6 py-4">Tanggal</th>
                  <th className="px-6 py-4">Mata</th>
                  <th className="px-6 py-4">Hasil AI</th>
                  <th className="px-6 py-4">Confidence</th>
                  <th className="px-6 py-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {historyList.map((item, i) => {
                  const res = item.result?.toUpperCase() || "NORMAL";
                  const isG = res.includes('GLAU');
                  const score = isG ? Number(item.conf) : (100 - Number(item.conf));
                  return (
                    <tr key={item.id} className="hover:bg-blue-50/30 transition-all group">
                      <td className="px-6 py-4 text-center text-gray-400 font-bold">{i + 1}</td>
                      <td className="px-6 py-4 font-bold text-gray-900">{item.name}</td>
                      <td className="px-6 py-4 text-sm">{item.display_date || item.date}</td>
                      <td className="px-6 py-4 text-sm font-semibold">{item.eye}</td>
                      <td className="px-6 py-4">
                        <span className={`px-3 py-1 rounded-full text-[10px] font-black tracking-widest ${isG ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}`}>{res}</span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <div className="w-16 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                            <div className={`h-full ${isG ? 'bg-red-500' : 'bg-green-500'}`} style={{ width: `${score}%` }}></div>
                          </div>
                          <span className="text-xs font-bold text-gray-700">{score.toFixed(1)}%</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button onClick={() => setSelectedHistory(item)} className="bg-white border-2 border-gray-100 text-gray-600 px-3 py-1.5 rounded-xl text-xs font-bold hover:border-blue-500 hover:text-blue-500 transition-all">Detail</button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>
      {selectedHistory && <HistoryDetailModal data={selectedHistory} onClose={() => setSelectedHistory(null)} />}
    </div>
  );
};

export default History;