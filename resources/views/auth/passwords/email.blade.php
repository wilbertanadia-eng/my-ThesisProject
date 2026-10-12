@extends('layouts.app')

@section('title', 'Reset Password')
@section('page-title', 'Reset Password')

@section('content')
<div class="max-w-md mx-auto">
    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-6">
        @if (session('status'))
            <div class="mb-4 p-3 bg-green-100 border border-green-400 text-green-700 rounded">
                {{ session('status') }}
            </div>
        @endif

        <form method="POST" action="{{ route('password.email') }}">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                       class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-500">
                @error('email')
                    <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex justify-end">
                <button type="submit"
                        class="bg-primary-600 hover:bg-gold-500 text-white font-semibold py-2 px-4 rounded-lg transition">
                    Send Password Reset Link
                </button>
            </div>
        </form>
    </div>
</div>
@endsection