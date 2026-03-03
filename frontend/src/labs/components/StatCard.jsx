const StatCard = ({ title, value, color, icon: Icon }) => (
  <div className="bg-white p-6 rounded-3xl shadow-sm flex items-center gap-5 border border-gray-100">
    <div className={`${color} p-4 rounded-2xl text-white shadow-lg`}>
      <Icon size={28} className={title === 'Sedang Diproses ML' ? 'animate-spin' : ''} />
    </div>
    <div>
      <p className="text-gray-500 text-sm font-medium">{title}</p>
      <p className="text-3xl font-bold text-gray-900">{value}</p>
    </div>
  </div>
);

export default StatCard;