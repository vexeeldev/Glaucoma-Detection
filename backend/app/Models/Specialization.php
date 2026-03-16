<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Specialization extends Model
{
    protected $fillable = ['name', 'description'];

    public function doctors() {
        return $this->hasMany(Doctor::class);
    }
}