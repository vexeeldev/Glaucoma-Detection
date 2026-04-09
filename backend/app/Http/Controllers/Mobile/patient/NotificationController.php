<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    /**
     * Ambil semua notifikasi milik user yang sedang login
     */
    public function index()
    {
        $notifications = DB::table('notifications')
            ->where('user_id', auth()->id()) // Proteksi Auth
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Notifikasi berhasil diambil',
            'data' => $notifications
        ]);
    }

    /**
     * Ambil jumlah notifikasi yang belum dibaca (untuk badge icon lonceng)
     */
    public function unreadCount()
    {
        $count = DB::table('notifications')
            ->where('user_id', auth()->id())
            ->where('is_read', false)
            ->count();

        return response()->json([
            'status' => 'success',
            'unread_count' => $count
        ]);
    }

    /**
     * Tandai satu notifikasi sebagai sudah dibaca
     */
    public function markAsRead($id)
    {
        $notification = DB::table('notifications')
            ->where('id', $id)
            ->where('user_id', auth()->id()) // Pastikan milik user ybs
            ->first();

        if (!$notification) {
            return response()->json(['message' => 'Notifikasi tidak ditemukan'], 404);
        }

        DB::table('notifications')
            ->where('id', $id)
            ->update([
                'is_read' => true,
                'updated_at' => now()
            ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Notifikasi ditandai telah dibaca'
        ]);
    }

    /**
     * Tandai SEMUA notifikasi sebagai sudah dibaca
     */
    public function markAllAsRead()
    {
        DB::table('notifications')
            ->where('user_id', auth()->id())
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'updated_at' => now()
            ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Semua notifikasi telah ditandai dibaca'
        ]);
    }

    /**
     * Hapus satu notifikasi tertentu
     */
    public function destroy($id)
    {
        $deleted = DB::table('notifications')
            ->where('id', $id)
            ->where('user_id', auth()->id())
            ->delete();

        if (!$deleted) {
            return response()->json(['message' => 'Gagal menghapus atau data tidak ditemukan'], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Notifikasi berhasil dihapus'
        ]);
    }

    /**
     * Hapus seluruh riwayat notifikasi (Clear Inbox)
     */
    public function clearAll()
    {
        DB::table('notifications')
            ->where('user_id', auth()->id())
            ->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Seluruh riwayat notifikasi telah dibersihkan'
        ]);
    }
}