import { Microscope } from 'lucide-react';

/**
 * ExaminationPage
 * Placeholder — fungsionalitas mirip AppointmentPage namun fokus pada data medis.
 */
const ExaminationPage = () => (
  <div className="text-center p-20 bg-white rounded-2xl border border-dashed border-gray-300">
    <Microscope size={64} className="mx-auto text-gray-200 mb-4" />
    <h3 className="text-xl font-bold text-gray-400">Halaman Manajemen Pemeriksaan</h3>
    <p className="text-gray-400">
      Modul ini memiliki fungsionalitas serupa dengan appointment namun fokus pada data medis.
    </p>
  </div>
);

export default ExaminationPage;
