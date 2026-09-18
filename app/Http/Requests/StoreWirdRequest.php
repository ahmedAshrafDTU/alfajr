<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWirdRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'date'           => 'required|date|date_format:Y-m-d|before_or_equal:today',
            'quran_pages'    => 'nullable|integer|min:0',
            'dhikr_morning'  => 'nullable|boolean',
            'dhikr_evening'  => 'nullable|boolean',
            'sunnah_prayers' => 'nullable|integer|min:0|max:12',
        ];
    }
}
