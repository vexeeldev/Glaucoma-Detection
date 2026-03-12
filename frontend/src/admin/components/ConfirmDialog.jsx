import { AlertCircle } from 'lucide-react';
import Modal from './Modal';

/**
 * ConfirmDialog
 * @param {boolean}  isOpen
 * @param {function} onClose
 * @param {function} onConfirm
 * @param {'delete'|'status'} type  - controls colour + copy
 */
const ConfirmDialog = ({ isOpen, onClose, onConfirm, type }) => {
  const isDelete = type === 'delete';

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={isDelete ? 'Konfirmasi Hapus' : 'Konfirmasi Status'}
      footer={
        <>
          <button
            onClick={onClose}
            className="px-4 py-2 text-gray-500 font-semibold"
          >
            Batal
          </button>
          <button
            onClick={() => {
              onConfirm?.();
              onClose();
            }}
            className={`px-4 py-2 text-white font-semibold rounded-lg ${
              isDelete ? 'bg-red-600' : 'bg-orange-600'
            }`}
          >
            Ya, Lanjutkan
          </button>
        </>
      }
    >
      <div className="text-center p-4">
        <AlertCircle
          size={48}
          className={`mx-auto mb-4 ${isDelete ? 'text-red-500' : 'text-orange-500'}`}
        />
        <p className="text-gray-600">
          {isDelete
            ? 'Apakah Anda yakin ingin menghapus user ini? Data yang sudah dihapus tidak dapat dikembalikan.'
            : 'Apakah Anda yakin ingin mengubah status aktif user ini?'}
        </p>
      </div>
    </Modal>
  );
};

export default ConfirmDialog;
