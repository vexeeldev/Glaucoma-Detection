<?php

namespace App\Http\Controllers\ML;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MachineController extends Controller
{
    public function predict(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        try {
            $file = $request->file('image');
            $response = Http::attach(
                'file', 
                file_get_contents($file->getRealPath()),
                $file->getClientOriginalName()
            )->post('http://localhost:5000/predict');
            if ($response->successful()) {
                $result = $response->json();
                return response()->json($result);
            }

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghubungi server AI'
            ], 500);

        } catch (\Exception $e) {
            Log::error("Predict Error: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan pada sistem'
            ], 500);
        }
    }
}