/**
 * Table
 * Thin wrapper so every page uses a consistent table shell.
 *
 * @param {string[]}  columns   - array of column header labels
 * @param {ReactNode} children  - <tbody> rows
 */
const Table = ({ columns, children }) => (
  <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <table className="w-full text-left">
      <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
        <tr>
          {columns.map((col, idx) => (
            <th key={idx} className="px-6 py-4">
              {col}
            </th>
          ))}
        </tr>
      </thead>
      <tbody className="divide-y divide-gray-100">{children}</tbody>
    </table>
  </div>
);

export default Table;
