<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FundusImage extends Model
{
    use HasFactory;

    protected $table = 'fundus_images';

    protected $fillable = [
        'examination_id',
        'uploaded_by',
        'original_filename',
        'stored_filename',
        'file_path',
        'file_url',
        'file_format',
        'file_size_bytes',
        'is_valid',
        'uploaded_at'
    ];

    public function examination()
    {
        return $this->belongsTo(Examination::class);
    }
}