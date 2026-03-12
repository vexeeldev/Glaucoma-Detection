<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnalysisResult extends Model
{
    use HasFactory;

    protected $table = 'analysis_results';

    protected $fillable = [
        'examination_id',
        'fundus_image_id',
        'model_version_id',
        'prediction',
        'confidence_score',
        'glaucoma_probability',
        'normal_probability',
        'heatmap_image_path',
        'raw_output',
        'status',
        'error_message',
        'processing_time_ms',
        'analyzed_at'
    ];

    // Cast raw_output karena di ERD tipenya JSON
    protected $casts = [
        'raw_output' => 'array',
        'analyzed_at' => 'datetime',
    ];
}