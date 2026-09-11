<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWirdRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'date' => ['required', 'date'],
            'quran_pages' => ['nullable', 'integer', 'min:0'],
            'dhikr_morning' => ['nullable', 'boolean'],
            'dhikr_evening' => ['nullable', 'boolean'],
            'sunnah_prayers' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
