<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWakeUpHistoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'date' => ['required', 'date'],
            'wake_up_time' => ['nullable', 'date_format:H:i:s'],
            'status' => ['required', 'in:on_time,late,missed'],
            'fajr_prayer_status' => ['required', 'in:jamaah,home,missed'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
