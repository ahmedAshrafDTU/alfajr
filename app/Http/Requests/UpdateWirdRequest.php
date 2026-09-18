<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateWirdRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
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
            'quran_pages'    => 'nullable|integer|min:0',
            'dhikr_morning'  => 'nullable|boolean',
            'dhikr_evening'  => 'nullable|boolean',
            'sunnah_prayers' => 'nullable|integer|min:0|max:12',
        ];
    }
}
