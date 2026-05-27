import { useEffect, useState } from 'react';
import axios from 'axios';

import {
  Search,
  XCircle,
  CheckCircle,
} from 'lucide-react';

import Badge from '../components/Badge';
import ConfirmDialog from '../components/ConfirmDialog';
import Pagination from '../components/Pagination';

const UserPage = () => {

  const [users, setUsers] = useState([]);

  const [loading, setLoading] = useState(true);

  const [activeModal, setActiveModal] = useState(null);

  const [selectedUser, setSelectedUser] = useState(null);

  const [search, setSearch] = useState('');

  const [role, setRole] = useState('');

  const [status, setStatus] = useState('');

  const [currentPage, setCurrentPage] = useState(1);

  const [pagination, setPagination] = useState({});

  const token = localStorage.getItem('token');

  const fetchUsers = async () => {

    try {

      setLoading(true);

      const response = await axios.get(
        'http://localhost:8000/api/labs/management/users',
        {
          params: {
            search,
            role,
            status,
            page: currentPage,
            per_page: 10,
          },

          headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
          },
        }
      );

      setUsers(response.data.data);

      setPagination(response.data.pagination);

    } catch (error) {

      console.error('Gagal mengambil data user:', error);

    } finally {

      setLoading(false);

    }
  };

  useEffect(() => {

    fetchUsers();

  }, [search, role, status, currentPage]);

  const handleToggleStatus = async (id) => {

    try {

      await axios.patch(
        `http://localhost:8000/api/labs/management/users/${id}/status`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
          },
        }
      );

      fetchUsers();

      setActiveModal(null);

    } catch (error) {

      console.error('Gagal update status:', error);

    }
  };

  const handleDelete = async (id) => {

    try {

      await axios.delete(
        `http://localhost:8000/api/labs/management/users/${id}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
          },
        }
      );

      fetchUsers();

      setActiveModal(null);

    } catch (error) {

      console.error('Gagal hapus user:', error);

    }
  };

  const resetFilter = () => {

    setSearch('');

    setRole('');

    setStatus('');

    setCurrentPage(1);
  };

  return (
    <div className="space-y-6">

      {/* Filters */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-wrap gap-4 items-center justify-between">

        <div className="flex flex-1 gap-4 min-w-[300px]">

          <div className="relative flex-1">

            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
              size={18}
            />

            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari nama atau email..."
              className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 outline-none focus:border-blue-500"
            />

          </div>

          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="px-4 py-2 rounded-lg border border-gray-200 outline-none"
          >
            <option value="">Semua Role</option>
            <option value="patient">Pasien</option>
            <option value="doctor">Dokter</option>
          </select>

          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="px-4 py-2 rounded-lg border border-gray-200 outline-none"
          >
            <option value="">Semua Status</option>
            <option value="active">Aktif</option>
            <option value="nonactive">Nonaktif</option>
          </select>

        </div>

        <button
          onClick={resetFilter}
          className="text-blue-600 hover:text-blue-800 font-semibold px-4 py-2"
        >
          Reset Filter
        </button>

      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">

        <table className="w-full text-left">

          <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">

            <tr>
              <th className="px-6 py-4">No</th>
              <th className="px-6 py-4">Nama</th>
              <th className="px-6 py-4">Email</th>
              <th className="px-6 py-4">Role</th>
              <th className="px-6 py-4">No. HP</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4 text-right">Aksi</th>
            </tr>

          </thead>

          <tbody className="divide-y divide-gray-100">

            {loading ? (

              <tr>
                <td
                  colSpan="7"
                  className="text-center py-10 text-gray-500"
                >
                  Loading...
                </td>
              </tr>

            ) : users.length === 0 ? (

              <tr>
                <td
                  colSpan="7"
                  className="text-center py-10 text-gray-500"
                >
                  Data user kosong
                </td>
              </tr>

            ) : (

              users.map((user, idx) => (

                <tr
                  key={user.id}
                  className="hover:bg-gray-50 transition-colors"
                >

                  <td className="px-6 py-4 text-gray-500">
                    {idx + 1}
                  </td>

                  <td className="px-6 py-4 font-medium flex items-center gap-3">

                    <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-xs">
                      {user.name.charAt(0)}
                    </div>

                    {user.name}

                  </td>

                  <td className="px-6 py-4 text-gray-600">
                    {user.email}
                  </td>

                  <td className="px-6 py-4">

                    <Badge variant={`role_${user.role.toLowerCase()}`}>
                      {user.role}
                    </Badge>

                  </td>

                  <td className="px-6 py-4 text-gray-500">
                    {user.phone}
                  </td>

                  <td className="px-6 py-4">

                    <Badge
                      variant={
                        user.status === 'active'
                          ? 'active'
                          : 'inactive'
                      }
                    >
                      {user.status}
                    </Badge>

                  </td>

                  <td className="px-6 py-4 text-right space-x-2">

                    <button
                      onClick={() => {
                        setSelectedUser(user);
                        setActiveModal('status');
                      }}
                      className="text-orange-600 hover:bg-orange-50 p-2 rounded-lg transition-all"
                    >
                      {user.status === 'Aktif'
                        ? <XCircle size={18} />
                        : <CheckCircle size={18} />
                      }
                    </button>

                    <button
                      onClick={() => {
                        setSelectedUser(user);
                        setActiveModal('delete');
                      }}
                      className="text-red-600 hover:bg-red-50 p-2 rounded-lg transition-all"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <polyline points="3 6 5 6 21 6"/>
                        <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
                        <path d="M10 11v6"/>
                        <path d="M14 11v6"/>
                        <path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/>
                      </svg>
                    </button>

                  </td>

                </tr>

              ))

            )}

          </tbody>

        </table>

        <Pagination
          currentPage={pagination.current_page || 1}
          totalPages={pagination.last_page || 1}
          info={`Menampilkan ${pagination.from || 0} - ${pagination.to || 0} dari ${pagination.total || 0} user`}
          onPageChange={(page) => setCurrentPage(page)}
        />

      </div>

      {/* Confirm Dialog */}
      <ConfirmDialog
        isOpen={!!activeModal}
        onClose={() => setActiveModal(null)}
        type={activeModal}
        onConfirm={() => {

          if (activeModal === 'status') {

            handleToggleStatus(selectedUser.id);

          }

          if (activeModal === 'delete') {

            handleDelete(selectedUser.id);

          }

        }}
      />

    </div>
  );
};

export default UserPage;