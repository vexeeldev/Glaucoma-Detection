<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->isAdmin();
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $currentUser, User $targetUser): bool
    {
        return $currentUser->isAdmin() || $currentUser->id === $targetUser->id;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return true; // Register bebas, tapi nanti dibatasi di controller
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $currentUser, User $targetUser): bool
    {
        return $currentUser->isAdmin() || $currentUser->id === $targetUser->id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $currentUser, User $targetUser): bool
    {
        // Admin bisa delete, tapi tidak bisa delete diri sendiri
        return $currentUser->isAdmin() && $currentUser->id !== $targetUser->id;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, User $targetUser): bool
    {
        return $user->isAdmin();
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, User $targetUser): bool
    {
        return $user->isAdmin();
    }

    /**
     * Determine whether the user can change role (khusus admin).
     */
    public function changeRole(User $currentUser, User $targetUser): bool
    {
        return $currentUser->isAdmin() && $currentUser->id !== $targetUser->id;
    }

    /**
     * Determine whether the user can toggle active status.
     */
    public function toggleActive(User $currentUser, User $targetUser): bool
    {
        return $currentUser->isAdmin() && $currentUser->id !== $targetUser->id;
    }
}