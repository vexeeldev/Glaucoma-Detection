const StatCard = ({ title, value, icon: Icon, colorClass, trend }) => (
  <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
    <div className={`p-4 rounded-lg ${colorClass}`}>
      <Icon size={24} className="text-white" />
    </div>
    <div>
      <p className="text-sm text-gray-500 font-medium">{title}</p>
      <div className="flex items-baseline gap-2">
        <h3 className="text-2xl font-bold text-gray-800">{value}</h3>
        {trend && <span className="text-xs text-green-500 font-bold">{trend}</span>}
      </div>
    </div>
  </div>
);

export default StatCard;
