import { ChevronLeft, ChevronRight } from 'lucide-react';

/**
 * Pagination
 * @param {number}   currentPage
 * @param {number}   totalPages
 * @param {function} onPageChange
 * @param {string}   info        - e.g. "Menampilkan 10 dari 128 user"
 */
const Pagination = ({ currentPage = 1, totalPages = 1, onPageChange, info }) => {
  const pages = Array.from({ length: totalPages }, (_, i) => i + 1);

  return (
    <div className="p-4 border-t flex justify-between items-center text-sm text-gray-500">
      {info && <p>{info}</p>}
      <div className="flex gap-2">
        <button
          onClick={() => onPageChange?.(currentPage - 1)}
          disabled={currentPage === 1}
          className="px-3 py-1 rounded border border-gray-200 hover:bg-gray-50 disabled:opacity-40"
        >
          <ChevronLeft size={16} />
        </button>

        {pages.map((page) => (
          <button
            key={page}
            onClick={() => onPageChange?.(page)}
            className={`px-3 py-1 rounded border ${
              page === currentPage
                ? 'bg-blue-600 text-white font-bold border-blue-600'
                : 'border-gray-200 hover:bg-gray-50'
            }`}
          >
            {page}
          </button>
        ))}

        <button
          onClick={() => onPageChange?.(currentPage + 1)}
          disabled={currentPage === totalPages}
          className="px-3 py-1 rounded border border-gray-200 hover:bg-gray-50 disabled:opacity-40"
        >
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  );
};

export default Pagination;
