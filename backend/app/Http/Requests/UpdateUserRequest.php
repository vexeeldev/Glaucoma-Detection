<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class UpdateUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();
        $targetUser = $this->route('user'); 
        
        if (!$targetUser) {
            return true;
        }
        
        return $user->can('update', $targetUser);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $rules = [
            'name' => ['sometimes', 'string', 'max:100'],
            'phone' => ['sometimes', 'string', 'max:20'],
        ];

        // if new pass
        if ($this->has('new_password')) {
            $rules['current_password'] = ['required', 'string'];
            $rules['new_password'] = ['required', 'confirmed', Password::min(8)];
        }

        // Only admin can update role & status
        if ($this->user()?->isAdmin()) {
            $rules['role'] = ['sometimes', 'string', 'in:patient,doctor,admin'];
            $rules['is_active'] = ['sometimes', 'boolean'];
        }

        return $rules;
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'current_password.required' => 'Password required',
            'new_password.required' => 'New password required',
            'new_password.min' => 'New password min. 8 characters',
            'new_password.confirmed' => 'Confirm new password is not matches',
        ];
    }
}