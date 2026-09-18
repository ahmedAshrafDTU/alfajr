<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateWakeUpHistoryRequest extends FormRequest
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
            'wake_up_time'       => 'sometimes|required|date_format:H:i',
            'status'             => 'sometimes|required|in:on_time,late,missed',
            'fajr_prayer_status' => 'sometimes|required|in:jamaah,home,missed',
            'notes'              => 'nullable|string|max:1000',
        ];
    }
}
