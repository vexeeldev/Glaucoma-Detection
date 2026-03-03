const Badge = ({ variant, children }) => {
  const styles = {
    glaukoma: 'bg-[#FFEBEE] text-[#C62828]',
    normal: 'bg-[#E8F5E9] text-[#2E7D32]',
    pending: 'bg-[#FFF3E0] text-[#E65100]',
    confirmed: 'bg-[#E1F5FE] text-[#0277BD]',
    default: 'bg-[#F5F5F5] text-[#616161]',
    active: 'bg-green-100 text-green-700',
    inactive: 'bg-red-100 text-red-700',
    role_admin: 'bg-purple-100 text-purple-700',
    role_dokter: 'bg-emerald-100 text-emerald-700',
    role_pasien: 'bg-blue-100 text-blue-700',
  };

  return (
    <span
      className={`px-2 py-1 rounded-full text-xs font-semibold uppercase tracking-wide ${
        styles[variant.toLowerCase()] || styles.default
      }`}
    >
      {children}
    </span>
  );
};

export default Badge;
