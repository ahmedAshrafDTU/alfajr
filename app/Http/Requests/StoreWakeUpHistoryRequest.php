<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWakeUpHistoryRequest extends FormRequest
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
            'date'               => 'required|date|date_format:Y-m-d|before_or_equal:today',
            'wake_up_time'       => 'required|date_format:H:i',
            'status'             => 'required|in:on_time,late,missed',
            'fajr_prayer_status' => 'required|in:jamaah,home,missed',
            'notes'              => 'nullable|string|max:1000',
        ];
    }
}
