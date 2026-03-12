<?php

namespace App\Http\Controllers\ML;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Appointment;
use App\Models\Examination;
use App\Models\FundusImage;
use App\Models\AnalysisResult;
use Illuminate\Support\Facades\DB;

class MachineController extends Controller
{
    public function predict(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:5120',
            'appointment_id' => 'required|exists:appointments,id',
        ]);

        DB::beginTransaction();

        try {
            $file = $request->file('image');
            $appointment = Appointment::findOrFail($request->appointment_id);

            // 1. Kirim ke Flask AI
            $response = Http::attach(
                'file', 
                file_get_contents($file->getRealPath()),
                $file->getClientOriginalName()
            )->post('http://localhost:5000/predict');

            if (!$response->successful()) {
                throw new \Exception("Gagal menghubungi server AI (Flask)");
            }

            $mlData = $response->json();
            $dataResult = $mlData['data'];

            // 2. Simpan file fisik
            $filename = time() . '_' . $file->getClientOriginalName();
            $path = $file->storeAs('fundus_images', $filename, 'public');

            // 3. Simpan/Update EXAMINATIONS (Menggunakan variabel $examination)
            // Pakai updateOrCreate supaya tidak error Unique Violation di appointment_id
            $examination = Examination::updateOrCreate(
                ['appointment_id' => $appointment->id],
                [
                    'patient_id'       => $appointment->patient_id,
                    'doctor_id'        => $appointment->doctor_id,
                    'examination_code' => 'EXM-' . strtoupper(uniqid()),
                    'examination_date' => now()->toDateString(),
                    'examination_time' => now()->toTimeString(),
                    'status'           => 'completed',
                    'doctor_diagnosis' => $dataResult['medical_advice'],
                ]
            );

            // 4. Simpan ke FUNDUS_IMAGES
            $fundusImage = FundusImage::create([
                'examination_id'    => $examination->id, // Variabel $examination sudah ada di atas
                'uploaded_by'       => $appointment->doctor_id,
                'original_filename' => $file->getClientOriginalName(),
                'stored_filename'   => $filename,
                'file_path'         => $path,
                'file_url'          => asset('storage/' . $path),
                'file_format'       => $file->getClientOriginalExtension(),
                'file_size_bytes'   => $file->getSize(),
                'is_valid'          => true,
                'uploaded_at'       => now(),
            ]);

            // 5. Simpan ke ANALYSIS_RESULTS
            AnalysisResult::create([
                'examination_id'       => $examination->id,
                'fundus_image_id'      => $fundusImage->id,
                'model_version_id'     => 1, // PASTIKAN sudah INSERT INTO ml_model_versions ID 1
                'prediction'           => $dataResult['analysis']['is_glaucoma'] ? 'glaucoma' : 'normal',
                'confidence_score'     => $dataResult['confidence_score'],
                'glaucoma_probability' => $dataResult['analysis']['is_glaucoma'] ? $dataResult['confidence_score'] : (1 - $dataResult['confidence_score']),
                'normal_probability'   => !$dataResult['analysis']['is_glaucoma'] ? $dataResult['confidence_score'] : (1 - $dataResult['confidence_score']),
                'raw_output'           => $mlData,
                'status'               => 'completed',
                'processing_time_ms'   => $dataResult['analysis']['inference_time_sec'] * 1000,
                'analyzed_at'          => now(),
            ]);

            DB::commit();

            return response()->json([
                'status' => 'success',
                'data' => $dataResult
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Predict Error: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}