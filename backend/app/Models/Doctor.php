<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Doctor extends Model
{
    protected $guarded = []; // Biar bisa input semua kolom

    // Relasi ke akun User
    public function user() {
        return $this->belongsTo(User::class);
    }

    // Relasi ke master data spesialisasi
    public function specialization() {
        return $this->belongsTo(Specialization::class);
    }

    // Relasi ke jadwal rutin
    public function schedules() {
        return $this->hasMany(Schedule::class);
    }
}
