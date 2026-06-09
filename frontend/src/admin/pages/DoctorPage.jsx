import { useEffect, useState } from "react";
import axios from "axios";
import { Plus } from "lucide-react";

import Badge from "../components/Badge";
import Modal from "../components/Modal";

const API_URL = "https://mollusklike-intactly-kennedi.ngrok-free.dev/api";

const initialForm = {
    name: "",
    email: "",
    phone: "",
    password: "rsmata123",
    specialization_id: "",
    license_number: "",
    experience_years: "",
    consultation_fee: "",
    bio: "",
};

const dayMap = {
    monday: "Senin",
    tuesday: "Selasa",
    wednesday: "Rabu",
    thursday: "Kamis",
    friday: "Jumat",
    saturday: "Sabtu",
    sunday: "Minggu",
};

const DoctorPage = () => {
    const headers = {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
        Accept: "application/json",
    };

    const [tab, setTab] = useState("list");

    const [doctors, setDoctors] = useState([]);
    const [schedules, setSchedules] = useState([]);

    const [selectedDoctor, setSelectedDoctor] = useState("");

    const [loadingDoctors, setLoadingDoctors] = useState(false);
    const [loadingSchedules, setLoadingSchedules] = useState(false);

    const [showAddModal, setShowAddModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);

    const [editDoctorId, setEditDoctorId] = useState(null);

    // ✅ FORM TERPISAH
    const [addForm, setAddForm] = useState(initialForm);
    const [editForm, setEditForm] = useState(initialForm);

    // FETCH DATA

    const fetchDoctors = async () => {
        try {
            setLoadingDoctors(true);

            const response = await axios.get(
                `${API_URL}/labs/management/doctors`,
                { headers },
            );

            setDoctors(response.data.data || []);
        } catch (error) {
            console.log(error);
        } finally {
            setLoadingDoctors(false);
        }
    };

    const fetchSchedules = async (doctorId) => {
        try {
            setLoadingSchedules(true);

            const response = await axios.get(
                `${API_URL}/labs/management/doctors/${doctorId}/schedules`,
                { headers },
            );

            setSchedules(response.data.data || []);
        } catch (error) {
            console.log(error);
        } finally {
            setLoadingSchedules(false);
        }
    };

    // HANDLE CHANGE

    const handleAddChange = (e) => {
        setAddForm({
            ...addForm,
            [e.target.name]: e.target.value,
        });
    };

    const handleEditChange = (e) => {
        setEditForm({
            ...editForm,
            [e.target.name]: e.target.value,
        });
    };

    // RESET FORM
    const resetAddForm = () => {
        setAddForm(initialForm);
    };

    const resetEditForm = () => {
        setEditForm(initialForm);
    };

    // STORE
    const handleStoreDoctor = async () => {
        try {
            await axios.post(`${API_URL}/labs/management/doctors`, addForm, {
                headers,
            });

            alert("Dokter berhasil ditambahkan");

            setShowAddModal(false);

            resetAddForm();

            fetchDoctors();
        } catch (error) {
            console.log(error);

            alert(error?.response?.data?.message || "Gagal menambahkan dokter");
        }
    };

    // =========================================================
    // EDIT
    // =========================================================

    const handleEditClick = (doctor) => {
        setEditDoctorId(doctor.id);

        setEditForm({
            name: doctor.name || "",
            email: doctor.email || "",
            phone: doctor.phone || "",
            password: "",
            specialization_id: doctor.specialization_id || "",
            license_number: doctor.license || "",
            experience_years: doctor.experience_years || "",
            consultation_fee: doctor.consultation_fee || "",
            bio: doctor.bio || "",
        });

        setShowEditModal(true);
    };

    const handleUpdateDoctor = async () => {
        try {
            await axios.put(
                `${API_URL}/labs/management/doctors/${editDoctorId}`,
                editForm,
                { headers },
            );

            alert("Dokter berhasil diupdate");

            setShowEditModal(false);

            resetEditForm();

            setEditDoctorId(null);

            fetchDoctors();
        } catch (error) {
            console.log(error);

            alert(error?.response?.data?.message || "Gagal update dokter");
        }
    };

    // =========================================================
    // DELETE
    // =========================================================

    const handleDeleteDoctor = async (doctorId) => {
        const confirmDelete = confirm("Yakin ingin menghapus dokter ini?");

        if (!confirmDelete) return;

        try {
            await axios.delete(
                `${API_URL}/labs/management/doctors/${doctorId}`,
                { headers },
            );

            alert("Dokter berhasil dihapus");

            fetchDoctors();
        } catch (error) {
            console.log(error);

            alert("Gagal menghapus dokter");
        }
    };

    // =========================================================
    // EFFECT
    // =========================================================

    useEffect(() => {
        fetchDoctors();
    }, []);

    useEffect(() => {
        if (tab === "schedule" && selectedDoctor) {
            fetchSchedules(selectedDoctor);
        }
    }, [tab, selectedDoctor]);

    // =========================================================
    // RENDER
    // =========================================================

    return (
        <div className="space-y-6">
            {/* TAB */}

            <div className="flex border-b border-gray-200">
                {["list", "schedule"].map((t) => (
                    <button
                        key={t}
                        onClick={() => setTab(t)}
                        className={`px-8 py-4 font-bold transition-all border-b-2 ${
                            tab === t
                                ? "border-blue-600 text-blue-600"
                                : "border-transparent text-gray-400 hover:text-gray-600"
                        }`}
                    >
                        {t === "list" ? "Daftar Dokter" : "Jadwal Praktik"}
                    </button>
                ))}
            </div>

            {/* LIST */}

            {tab === "list" && (
                <div>
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-xl font-bold text-gray-800">
                            Total Dokter: {doctors.length}
                        </h3>

                        <button
                            onClick={() => {
                                resetAddForm();
                                setShowAddModal(true);
                            }}
                            className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700"
                        >
                            <Plus size={20} />
                            Tambah Dokter
                        </button>
                    </div>

                    {loadingDoctors ? (
                        <div className="text-center py-10">Loading...</div>
                    ) : (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {doctors.map((doc) => (
                                <div
                                    key={doc.id}
                                    className="bg-white p-6 rounded-xl shadow-sm border border-gray-100"
                                >
                                    <div className="w-24 h-24 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-3xl font-bold mx-auto mb-4">
                                        {doc.name?.charAt(0)}
                                    </div>

                                    <h4 className="font-bold text-lg text-center text-gray-800">
                                        {doc.name}
                                    </h4>

                                    <p className="text-blue-600 text-sm text-center mb-4">
                                        {doc.specialization}
                                    </p>

                                    <div className="space-y-2 text-sm text-gray-600">
                                        <div className="flex justify-between">
                                            <span>Lisensi</span>
                                            <span>{doc.license}</span>
                                        </div>

                                        <div className="flex justify-between">
                                            <span>Pengalaman</span>
                                            <span>{doc.exp}</span>
                                        </div>

                                        <div className="flex justify-between">
                                            <span>Biaya</span>
                                            <span>{doc.fee}</span>
                                        </div>
                                    </div>

                                    <div className="flex gap-2 mt-6">
                                        <button
                                            onClick={() => handleEditClick(doc)}
                                            className="flex-1 py-2 border border-blue-600 text-blue-600 rounded-lg hover:bg-blue-50"
                                        >
                                            Edit
                                        </button>

                                        <button
                                            onClick={() => {
                                                setSelectedDoctor(doc.id);
                                                setTab("schedule");
                                            }}
                                            className="flex-1 py-2 bg-gray-100 rounded-lg hover:bg-gray-200"
                                        >
                                            Jadwal
                                        </button>
                                    </div>

                                    <button
                                        onClick={() =>
                                            handleDeleteDoctor(doc.id)
                                        }
                                        className="w-full mt-3 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100"
                                    >
                                        Hapus
                                    </button>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            )}

            {/* SCHEDULE */}

            {tab === "schedule" && (
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="mb-6">
                        <select
                            value={selectedDoctor}
                            onChange={(e) => {
                                setSelectedDoctor(e.target.value);
                            }}
                            className="px-4 py-2 rounded-lg border border-gray-200 min-w-[300px] outline-none"
                        >
                            <option value="">Pilih Dokter</option>

                            {doctors.map((doc) => (
                                <option key={doc.id} value={doc.id}>
                                    {doc.name}
                                </option>
                            ))}
                        </select>
                    </div>

                    <table className="w-full text-left">
                        <thead className="bg-gray-50 text-gray-500 text-xs uppercase">
                            <tr>
                                <th className="px-6 py-4">Hari</th>
                                <th className="px-6 py-4">Jam Mulai</th>
                                <th className="px-6 py-4">Jam Selesai</th>
                                <th className="px-6 py-4">Kuota</th>
                                <th className="px-6 py-4">Status</th>
                            </tr>
                        </thead>

                        <tbody>
                            {loadingSchedules ? (
                                <tr>
                                    <td
                                        colSpan="5"
                                        className="text-center py-6"
                                    >
                                        Loading...
                                    </td>
                                </tr>
                            ) : schedules.length > 0 ? (
                                schedules.map((schedule) => (
                                    <tr key={schedule.id} className="border-b">
                                        <td className="px-6 py-4 font-semibold">
                                            {dayMap[schedule.day_of_week]}
                                        </td>

                                        <td className="px-6 py-4">
                                            {schedule.start_time}
                                        </td>

                                        <td className="px-6 py-4">
                                            {schedule.end_time}
                                        </td>

                                        <td className="px-6 py-4">
                                            {schedule.max_patients} Pasien
                                        </td>

                                        <td className="px-6 py-4">
                                            <Badge
                                                variant={
                                                    schedule.is_available
                                                        ? "active"
                                                        : "inactive"
                                                }
                                            >
                                                {schedule.is_available
                                                    ? "Buka"
                                                    : "Tutup"}
                                            </Badge>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td
                                        colSpan="5"
                                        className="text-center py-6 text-gray-500"
                                    >
                                        Jadwal belum tersedia
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            )}

            {/* ADD MODAL */}

            <Modal
                isOpen={showAddModal}
                onClose={() => {
                    setShowAddModal(false);
                    resetAddForm();
                }}
                title="Tambah Dokter Baru"
                footer={
                    <>
                        <button
                            onClick={() => {
                                setShowAddModal(false);
                                resetAddForm();
                            }}
                            className="px-4 py-2 text-gray-500"
                        >
                            Batal
                        </button>

                        <button
                            onClick={handleStoreDoctor}
                            className="px-6 py-2 bg-blue-600 text-white rounded-lg"
                        >
                            Simpan Dokter
                        </button>
                    </>
                }
            >
                <DoctorForm form={addForm} handleChange={handleAddChange} />
            </Modal>

            {/* EDIT MODAL */}

            <Modal
                isOpen={showEditModal}
                onClose={() => {
                    setShowEditModal(false);
                    resetEditForm();
                    setEditDoctorId(null);
                }}
                title="Edit Dokter"
                footer={
                    <>
                        <button
                            onClick={() => {
                                setShowEditModal(false);
                                resetEditForm();
                                setEditDoctorId(null);
                            }}
                            className="px-4 py-2 text-gray-500"
                        >
                            Batal
                        </button>

                        <button
                            onClick={handleUpdateDoctor}
                            className="px-6 py-2 bg-blue-600 text-white rounded-lg"
                        >
                            Update Dokter
                        </button>
                    </>
                }
            >
                <DoctorForm form={editForm} handleChange={handleEditChange} />
            </Modal>
        </div>
    );
};

const DoctorForm = ({ form, handleChange }) => {
    return (
        <div className="grid grid-cols-2 gap-4">
            <input
                name="name"
                value={form.name}
                onChange={handleChange}
                placeholder="Nama"
                className="border p-2 rounded"
            />

            <input
                name="email"
                value={form.email}
                onChange={handleChange}
                placeholder="Email"
                className="border p-2 rounded"
            />

            <input
                name="phone"
                value={form.phone}
                onChange={handleChange}
                placeholder="Phone"
                className="border p-2 rounded"
            />

            <input
                name="license_number"
                value={form.license_number}
                onChange={handleChange}
                placeholder="License Number"
                className="border p-2 rounded"
            />

            <input
                name="experience_years"
                value={form.experience_years}
                onChange={handleChange}
                placeholder="Experience"
                type="number"
                className="border p-2 rounded"
            />

            <input
                name="consultation_fee"
                value={form.consultation_fee}
                onChange={handleChange}
                placeholder="Consultation Fee"
                type="number"
                className="border p-2 rounded"
            />

            <input
                name="specialization_id"
                value={form.specialization_id}
                onChange={handleChange}
                placeholder="Specialization ID"
                className="border p-2 rounded"
            />

            <textarea
                name="bio"
                value={form.bio}
                onChange={handleChange}
                placeholder="Bio"
                className="border p-2 rounded col-span-2"
            />
        </div>
    );
};

export default DoctorPage;
