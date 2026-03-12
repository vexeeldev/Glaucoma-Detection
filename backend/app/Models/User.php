<?php

namespace App\Models;

use App\Models\{Doctor, Admin, Notification, ActivityLog, FundusImage};
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    
    use HasFactory, Notifiable, HasApiTokens, SoftDeletes;
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',          
        'role',           
        'is_active',     
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
    
    public function patient()
    {
        return $this->hasOne(Patient::class);
    }

    public function doctor()
    {
        return $this->hasOne(Doctor::class);
    }

    public function admin()
    {
        return $this->hasOne(Admin::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function activityLogs()
    {
        return $this->hasMany(ActivityLog::class);
    }

    public function uploadedImages()
    {
        return $this->hasMany(FundusImage::class, 'uploaded_by');
    }


    public function isPatient(): bool
    {
        return $this->role === 'patient';
    }

    public function isDoctor(): bool
    {
        return $this->role === 'doctor';
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function getProfileAttribute()
    {
        return match($this->role) {
            'patient' => $this->patient,
            'doctor' => $this->doctor,
            'admin' => $this->admin,
            default => null
        };
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOfRole($query, $role)
    {
        return $query->where('role', $role);
    }
}