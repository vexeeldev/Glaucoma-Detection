<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Examination extends Model
{
    use HasFactory;

    protected $table = 'examinations';

    protected $fillable = [
        'appointment_id',
        'patient_id',
        'doctor_id',
        'examination_code',
        'examination_date',
        'examination_time',
        'status',
        'clinical_notes',
        'doctor_diagnosis',
        'recommendation'
    ];

    // Relasi ke hasil analisis ML
    public function analysisResults()
    {
        return $this->hasMany(AnalysisResult::class);
    }

    // Relasi ke file gambar fundus
    public function fundusImages()
    {
        return $this->hasMany(FundusImage::class);
    }
}