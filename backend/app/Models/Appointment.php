<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    protected $table = 'appointments';

    protected $fillable = [
        'patient_id',
        'doctor_id',
        'appointment_date',
        'appointment_time',
        'appointment_status',
        'patient_complaint',
        'doctor_notes',
        'rejection_reason',
        'confirmed_by',
        'confirmed_at'
    ];

    // --- TAMBAHKAN INI BIAR NAMA PASIEN BISA MUNCUL ---
    public function patient()
    {
        return $this->belongsTo(Patient::class, 'patient_id');
    }

    // Relasi ke Examination
    public function examination()
    {
        return $this->hasOne(Examination::class);
    }

    public function doctor()
    {
        return $this->belongsTo(User::class, 'doctor_id');
    }
      public function analysis()
    {
        // Asumsi di tabel analysis_results ada kolom appointment_id
        return $this->hasOne(AnalysisResult::class, 'appointment_id');
    }
}