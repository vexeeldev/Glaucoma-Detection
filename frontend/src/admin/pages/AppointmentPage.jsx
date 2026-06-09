import { useState, useEffect } from "react";
import { Search, CalendarDays } from "lucide-react";
import axios from "axios";

import Badge from "../components/Badge";
import Modal from "../components/Modal";

// Base URL Backend Laravel kamu
const API_URL = "https://mollusklike-intactly-kennedi.ngrok-free.dev/api";

// SINKRONISASI BADGE: Disesuaikan dengan enum appointment_status di database ERD kamu
const getStatusBadge = (status) => {
    switch (status) {
        case "confirmed":
            return <Badge variant="confirmed">Confirmed</Badge>;
        case "pending_payment":
            return <Badge variant="default">Pending Payment</Badge>;
        case "pending_confirmation":
            return <Badge variant="pending">Pending Confirmation</Badge>;
        case "completed":
            return <Badge variant="active">Completed</Badge>;
        case "cancelled":
            return <Badge variant="inactive">Cancelled</Badge>;
        case "rejected":
            return <Badge variant="inactive">Rejected</Badge>;
        default:
            return <Badge variant="default">{status}</Badge>;
    }
};

const AppointmentPage = () => {
    // States untuk data API
    const [appointments, setAppointments] = useState([]);
    const [pagination, setPagination] = useState({
        current_page: 1,
        last_page: 1,
    });
    const [loading, setLoading] = useState(true);

    // States untuk Filter & Search
    const [search, setSearch] = useState("");
    const [status, setStatus] = useState("Semua Status"); // Menyimpan value tampilan filter
    const [date, setDate] = useState("");

    // States untuk Modal Detail
    const [activeModal, setActiveModal] = useState(null);
    const [detailData, setDetailData] = useState(null);
    const [loadingDetail, setLoadingDetail] = useState(false);

    // 1. FETCH LIST DATA TABLE (INDEX)
    const fetchAppointments = async (page = 1) => {
        setLoading(true);
        try {
            // SINKRONISASI FILTER: Mengirimkan parameter status yang cocok dengan enum backend
            const response = await axios.get(`${API_URL}/admin/appointment`, {
                params: {
                    page: page,
                    search: search,
                    status: status === "Semua Status" ? "" : status, // Value select sudah disesuaikan ke snake_case di bawah
                    date: date,
                },
            });

            if (response.data.success) {
                setAppointments(response.data.data);
                setPagination(response.data.pagination);
            }
        } catch (error) {
            console.error("Gagal memuat data appointments:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const delayDebounce = setTimeout(() => {
            fetchAppointments(1);
        }, 400); // Debounce 400ms biar ga boros hit query pas ngetik nama

        return () => clearTimeout(delayDebounce);
    }, [search, status, date]);

    // 2. FETCH DETAIL DATA MODAL (SHOW)
    const handleOpenDetail = async (apt) => {
        setActiveModal(apt);
        setLoadingDetail(true);
        setDetailData(null);
        try {
            const response = await axios.get(
                `${API_URL}/admin/appointment/${apt.id}`,
            );
            if (response.data.success) {
                setDetailData(response.data.data);
            }
        } catch (error) {
            console.error("Gagal memuat detail appointment:", error);
        } finally {
            setLoadingDetail(false);
        }
    };

    return (
        <div className="space-y-6">
            {/* Filters */}
            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-wrap gap-4 items-center">
                <div className="flex gap-2 items-center bg-gray-50 px-3 py-2 rounded-lg border border-gray-200">
                    <CalendarDays size={18} className="text-gray-400" />
                    <input
                        type="date"
                        value={date}
                        onChange={(e) => setDate(e.target.value)}
                        className="bg-transparent outline-none text-sm font-medium"
                    />
                </div>
                <div className="relative flex-1 min-w-[200px]">
                    <Search
                        className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
                        size={18}
                    />
                    <input
                        type="text"
                        placeholder="Cari nama pasien atau dokter..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 outline-none focus:border-blue-500"
                    />
                </div>

                {/* SINKRONISASI OPTION: Menggunakan value snake_case agar dibaca sempurna oleh query Laravel */}
                <select
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                    className="px-4 py-2 rounded-lg border border-gray-200 outline-none text-sm font-medium"
                >
                    <option value="Semua Status">Semua Status</option>
                    <option value="pending_payment">Pending Payment</option>
                    <option value="pending_confirmation">
                        Pending Confirmation
                    </option>
                    <option value="confirmed">Confirmed</option>
                    <option value="completed">Completed</option>
                    <option value="rejected">Rejected</option>
                    <option value="cancelled">Cancelled</option>
                </select>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
                        <tr>
                            <th className="px-6 py-4">No</th>
                            <th className="px-6 py-4">Pasien</th>
                            <th className="px-6 py-4">Dokter</th>
                            <th className="px-6 py-4">Waktu</th>
                            <th className="px-6 py-4 text-center">Status</th>
                            <th className="px-6 py-4 text-center">
                                Pembayaran
                            </th>
                            <th className="px-6 py-4 text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {loading ? (
                            <tr>
                                <td
                                    colSpan="7"
                                    className="px-6 py-8 text-center text-gray-400 font-medium"
                                >
                                    Memuat data dari database...
                                </td>
                            </tr>
                        ) : appointments.length === 0 ? (
                            <tr>
                                <td
                                    colSpan="7"
                                    className="px-6 py-8 text-center text-gray-400 font-medium"
                                >
                                    Tidak ada data appointment yang cocok.
                                </td>
                            </tr>
                        ) : (
                            appointments.map((apt, idx) => (
                                <tr key={apt.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 text-gray-500">
                                        {(pagination.current_page - 1) *
                                            pagination.per_page +
                                            (idx + 1)}
                                    </td>
                                    <td className="px-6 py-4 font-bold text-gray-800">
                                        {apt.patient}
                                    </td>
                                    <td className="px-6 py-4 text-gray-600">
                                        {apt.doctor}
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="text-sm font-bold text-gray-800">
                                            {apt.date}
                                        </div>
                                        <div className="text-xs text-gray-400">
                                            {apt.time}
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        {getStatusBadge(apt.status)}
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <span
                                            className={`text-[10px] font-black uppercase ${
                                                apt.payment === "paid" ||
                                                apt.payment === "completed"
                                                    ? "text-green-600"
                                                    : "text-gray-400"
                                            }`}
                                        >
                                            ● {apt.payment}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <button
                                            onClick={() =>
                                                handleOpenDetail(apt)
                                            }
                                            className="text-blue-600 hover:underline font-bold text-sm"
                                        >
                                            Lihat Detail
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>

                {/* Pagination Controls */}
                {pagination.last_page > 1 && (
                    <div className="bg-gray-50 px-6 py-3 border-t flex items-center justify-between gap-2">
                        <span className="text-sm text-gray-500">
                            Menampilkan total{" "}
                            <strong>{pagination.total}</strong> data
                        </span>
                        <div className="flex gap-2">
                            <button
                                disabled={pagination.current_page === 1}
                                onClick={() =>
                                    fetchAppointments(
                                        pagination.current_page - 1,
                                    )
                                }
                                className="px-3 py-1 text-sm font-medium border rounded bg-white hover:bg-gray-50 disabled:opacity-50"
                            >
                                Prev
                            </button>
                            <button
                                disabled={
                                    pagination.current_page ===
                                    pagination.last_page
                                }
                                onClick={() =>
                                    fetchAppointments(
                                        pagination.current_page + 1,
                                    )
                                }
                                className="px-3 py-1 text-sm font-medium border rounded bg-white hover:bg-gray-50 disabled:opacity-50"
                            >
                                Next
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {/* Detail Modal */}
            <Modal
                isOpen={!!activeModal}
                onClose={() => {
                    setActiveModal(null);
                    setDetailData(null);
                }}
                title="Detail Appointment"
            >
                {loadingDetail ? (
                    <div className="text-center py-8 text-sm font-medium text-gray-400">
                        Mengambil info rekam medis lengkap...
                    </div>
                ) : detailData ? (
                    <div className="space-y-6">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="bg-gray-50 p-4 rounded-xl border">
                                <p className="text-xs text-gray-400 uppercase font-bold mb-1">
                                    Informasi Pasien
                                </p>
                                <p className="font-bold text-gray-800">
                                    {detailData.patient?.name}
                                </p>
                                <p className="text-xs text-gray-500 mb-1">
                                    Kontak: {detailData.patient?.phone ?? "-"}
                                </p>
                                <p className="text-sm text-gray-600 bg-white p-2 rounded border mt-2">
                                    <span className="font-bold block text-xs uppercase text-gray-400">
                                        Keluhan Pasien:
                                    </span>
                                    {detailData.appointment?.patient_complaint}
                                </p>
                            </div>
                            <div className="bg-gray-50 p-4 rounded-xl border">
                                <p className="text-xs text-gray-400 uppercase font-bold mb-1">
                                    Informasi Dokter
                                </p>
                                <p className="font-bold text-gray-800">
                                    {detailData.doctor?.name}
                                </p>
                                <p className="text-xs text-gray-400 font-mono">
                                    No. Izin:{" "}
                                    {detailData.doctor?.license_number ?? "-"}
                                </p>
                                <p className="text-sm text-gray-500 mt-2">
                                    {detailData.doctor?.clinic_location}
                                </p>
                            </div>
                        </div>

                        {/* INTEGRASI HASIL AI GLAUCOSCAN */}
                        {detailData.examination?.id && (
                            <div className="p-4 border border-purple-100 bg-purple-50/50 rounded-xl space-y-3">
                                <h4 className="text-sm font-bold text-purple-900 flex items-center gap-2">
                                    🧬 Hasil Pemeriksaan & Analisis AI
                                    GlaucoScan
                                </h4>
                                <div className="grid grid-cols-3 gap-4 items-center">
                                    <div className="col-span-1">
                                        {detailData.fundus_images?.[0]
                                            ?.image_url ? (
                                            <img
                                                src={
                                                    detailData.fundus_images[0]
                                                        .image_url
                                                }
                                                alt="Fundus Mata"
                                                className="w-full h-24 object-cover rounded-lg border shadow-sm"
                                            />
                                        ) : (
                                            <div className="w-full h-24 bg-gray-200 rounded-lg flex items-center justify-center text-[10px] text-gray-400 text-center p-1">
                                                Foto retina tidak tersedia
                                            </div>
                                        )}
                                    </div>
                                    <div className="col-span-2 space-y-1 text-sm text-gray-700">
                                        <p>
                                            <strong>Kode Periksa:</strong>{" "}
                                            {detailData.examination
                                                ?.examination_code ??
                                                `EXM-${detailData.id}`}
                                        </p>
                                        <p>
                                            <strong>Prediksi AI:</strong>{" "}
                                            <span
                                                className={`font-black ${detailData.analysis_results?.[0]?.prediction?.toLowerCase() === "glaucoma" ? "text-red-600" : "text-green-600"}`}
                                            >
                                                {detailData.analysis_results?.[0]?.prediction?.toUpperCase() ??
                                                    "BELUM DIANALISIS"}
                                            </span>
                                        </p>
                                        <p>
                                            <strong>Skor Akurasi AI:</strong>{" "}
                                            <span className="font-mono bg-purple-100 px-1.5 py-0.5 rounded text-purple-800 font-bold">
                                                {detailData
                                                    .analysis_results?.[0]
                                                    ?.confidence_score
                                                    ? `${(parseFloat(detailData.analysis_results[0].confidence_score) <= 1.0 ? parseFloat(detailData.analysis_results[0].confidence_score) * 100 : parseFloat(detailData.analysis_results[0].confidence_score)).toFixed(1)}%`
                                                    : "0.0%"}
                                            </span>
                                        </p>
                                    </div>
                                </div>
                                {detailData.examination?.recommendation && (
                                    <p className="text-xs text-purple-700 italic border-t border-purple-100 pt-2 mt-1">
                                        *Rekomendasi AI:{" "}
                                        {detailData.examination.recommendation}
                                    </p>
                                )}
                            </div>
                        )}

                        <div>
                            <p className="text-sm font-bold mb-3">
                                Timeline Status
                            </p>
                            <div className="space-y-4">
                                <div className="flex gap-3">
                                    <div className="w-8 h-8 rounded-full flex items-center justify-center shrink-0 bg-green-100 text-green-600 font-bold">
                                        1
                                    </div>
                                    <div>
                                        <p className="text-sm font-bold">
                                            Booking Dibuat
                                        </p>
                                        <p className="text-xs text-gray-400">
                                            {detailData.appointment
                                                ?.created_at_formatted ??
                                                "Selesai"}
                                        </p>
                                    </div>
                                </div>
                                <div className="flex gap-3">
                                    <div
                                        className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 font-bold ${detailData.payment?.payment_status === "paid" || detailData.payment?.payment_status === "completed" ? "bg-green-100 text-green-600" : "bg-gray-100 text-gray-400"}`}
                                    >
                                        2
                                    </div>
                                    <div>
                                        <p className="text-sm font-bold">
                                            Status Pembayaran
                                        </p>
                                        <p className="text-xs text-gray-400">
                                            Metode:{" "}
                                            {detailData.payment?.payment_method}{" "}
                                            (
                                            {
                                                detailData.payment
                                                    ?.paid_at_formatted
                                            }
                                            )
                                        </p>
                                    </div>
                                </div>
                                <div className="flex gap-3">
                                    <div
                                        className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 font-bold ${detailData.appointment?.status === "completed" ? "bg-green-100 text-green-600" : "bg-blue-100 text-blue-600"}`}
                                    >
                                        3
                                    </div>
                                    <div>
                                        <p className="text-sm font-bold">
                                            Status Kunjungan Klinik
                                        </p>
                                        <p className="text-xs text-blue-500 font-semibold uppercase">
                                            Status saat ini:{" "}
                                            {detailData.appointment?.status}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="p-4 border border-blue-100 bg-blue-50 rounded-xl">
                            <h4 className="text-sm font-bold text-blue-800 mb-2">
                                Informasi Pembayaran
                            </h4>
                            <div className="flex justify-between text-sm mb-1">
                                <span className="text-blue-600">
                                    ID Invoice
                                </span>
                                <span className="font-mono font-bold">
                                    {detailData.payment?.invoice_number}
                                </span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-blue-600">
                                    Nominal Tarif
                                </span>
                                <span className="font-bold text-blue-900">
                                    Rp{" "}
                                    {parseFloat(
                                        detailData.payment?.amount ?? 0,
                                    ).toLocaleString("id-ID")}
                                </span>
                            </div>
                        </div>
                    </div>
                ) : null}
            </Modal>
        </div>
    );
};

export default AppointmentPage;
