<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BypassNgrokWarning
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // 1. Suntik header bypass ke request yang masuk dari Flutter/React
        $request->headers->set('ngrok-skip-browser-warning', 'true');

        $response = $next($request);

        // 2. Suntik juga header bypass ke response yang dibalikin ke client
        if (method_exists($response, 'header')) {
            $response->header('ngrok-skip-browser-warning', 'true');
        } elseif (isset($response->headers)) {
            $response->headers->set('ngrok-skip-browser-warning', 'true');
        }

        return $response;
    }
}