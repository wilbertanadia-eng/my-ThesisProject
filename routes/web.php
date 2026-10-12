<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LandingController;



Route::get('/', [LandingController::class, 'index']);

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});


Route::view('/help', 'pages.help')->name('help');
Route::view('/data-privacy-act', 'pages.data-privacy-act')->name('data-privacy-act');
Route::view('/terms-of-service', 'pages.terms-of-service')->name('terms-of-service');

require __DIR__.'/auth.php';
