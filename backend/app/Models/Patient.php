<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Patient extends Model
{
    use HasFactory;

    // Nama tabel di database
    protected $table = 'patients';

    // Kolom yang boleh diisi (mass assignable)
    protected $fillable = [
        'user_id',
        'date_of_birth',
        'gender',
        'address',
        'city',
        'phone_number',
        'blood_type',
        'medical_history'
    ];

    /**
     * Relasi ke model User (One-to-One)
     * Setiap Patient adalah seorang User
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relasi ke Appointments
     * Satu pasien bisa punya banyak janji temu
     */
    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    /**
     * Relasi ke Examinations
     * Satu pasien bisa punya banyak hasil pemeriksaan
     */
    public function examinations()
    {
        return $this->hasMany(Examination::class);
    }
}