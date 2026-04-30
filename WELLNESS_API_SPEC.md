# Wellness Insights API Specification

This document describes the API contract for the **Wellness Insights** feature. The backend implements an Anthropic (Claude) wrapper that accepts psycho-physiological data and returns personalized suggestions for emotional and physical stability.

---

## Quick Start (CURL Examples)

### 1. Obtain an access token

```bash
curl -X POST http://localhost:5001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

Save the `access_token` from the response and set:

```bash
export TOKEN="your-access-token-here"
```

### 2. Call Wellness Insights (full request)

```bash
curl -X POST http://localhost:5001/api/v1/wellness/insights \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "physiological_data": {
      "heart_rate_bpm": 78,
      "heart_rate_variability_ms": 42,
      "sleep_hours": 6,
      "sleep_quality": 65,
      "steps_count": 4500,
      "stress_level": 6.5,
      "respiratory_rate": 16,
      "active_minutes": 25,
      "collected_at": "2025-03-07T10:30:00.000Z"
    },
    "additional_context": "Had a stressful meeting this morning"
  }'
```

### 3. Minimal request

```bash
curl -X POST http://localhost:5001/api/v1/wellness/insights \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "physiological_data": {
      "heart_rate_bpm": 72,
      "stress_level": 4
    }
  }'
```

---

## Endpoint

```
POST /api/v1/wellness/insights
```

**Authentication:** Bearer token (required, same as other ZenSpace API endpoints)

**Content-Type:** `application/json`

---

## Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `physiological_data` | object | Yes | Apple Watch / health metrics |
| `additional_context` | string | No | Optional user-provided context (e.g. "feeling anxious today") |

### physiological_data object

| Field | Type | Description |
|-------|------|-------------|
| `heart_rate_bpm` | number | Heart rate in beats per minute |
| `heart_rate_variability_ms` | number | HRV in milliseconds |
| `sleep_hours` | number | Hours of sleep |
| `sleep_quality` | number | Sleep quality score (1-100) |
| `steps_count` | number | Step count |
| `stress_level` | number | Stress level (0-10 scale) |
| `respiratory_rate` | number | Breaths per minute |
| `active_minutes` | number | Active/exercise minutes |
| `collected_at` | string | ISO 8601 datetime when data was collected |

### Example Request

```json
{
  "physiological_data": {
    "heart_rate_bpm": 78,
    "heart_rate_variability_ms": 42,
    "sleep_hours": 6,
    "sleep_quality": 65,
    "steps_count": 4500,
    "stress_level": 6.5,
    "respiratory_rate": 16,
    "active_minutes": 25,
    "collected_at": "2025-03-07T10:30:00.000Z"
  },
  "additional_context": "Had a stressful meeting this morning"
}
```

---

## Response Format

The API should return a success response with a `data` object containing a list of suggestions. The Flutter app expects one of these structures:

### Option A (preferred)
```json
{
  "success": true,
  "data": {
    "suggestions": [
      {
        "id": "uuid-or-unique-id",
        "title": "Take a breath break",
        "description": "Your heart rate and stress indicators suggest...",
        "category": "emotional",
        "priority": 1,
        "action_step": "Find a quiet spot and practice 3 cycles of 4-7-8 breathing",
        "duration": "2 min"
      }
    ]
  },
  "message": "Insights generated successfully"
}
```

### Option B (direct array)
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "title": "...",
      "description": "...",
      "category": "physical",
      "priority": 2,
      "action_step": "...",
      "duration": "10 min"
    }
  ]
}
```

### Suggestion object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `title` | string | Yes | Short, actionable title |
| `description` | string | Yes | Longer explanation (can also use `content`) |
| `category` | string | No | One of: `emotional`, `physical`, `sleep`, `stress`, `general` |
| `priority` | number | No | 1-5 (1 = highest priority) |
| `action_step` | string | No | Concrete action the user can take |
| `duration` | string | No | Estimated time (e.g. "5 min", "10 min") |

---

## Anthropic Prompt Guidelines

The backend should construct a prompt for Claude that:

1. **Summarizes** the physiological data in natural language
2. **Identifies** potential stress/mood indicators (e.g. elevated HR, low HRV, poor sleep)
3. **Generates 3-5 personalized suggestions** for:
   - Emotional stability (breathing, mindfulness, reframing)
   - Physical stability (movement, hydration, rest)
   - Sleep improvement (if relevant)
   - Stress reduction techniques

4. **Outputs** in a structured JSON format matching the response spec above

Example prompt structure (pseudo):
```
You are a wellness coach. Given the following physiological data from an Apple Watch:
- Heart rate: {heart_rate_bpm} bpm
- HRV: {heart_rate_variability_ms} ms
- Sleep: {sleep_hours}h, quality {sleep_quality}%
- Steps: {steps_count}
- Stress level: {stress_level}/10
- Additional context: {additional_context}

Provide 3-5 personalized, actionable suggestions to improve emotional and physical stability.
Return JSON: { "suggestions": [ { "id", "title", "description", "category", "priority", "action_step", "duration" }, ... ] }
```

---

## Error Response

```json
{
  "success": false,
  "error": {
    "code": "WELLNESS_GENERATION_FAILED",
    "message": "Unable to generate insights at this time",
    "details": {}
  }
}
```

---

## Base URL

Configure in the Flutter app via `ApiConstants.baseUrl` (currently `http://localhost:5001` for dev). Ensure CORS and auth are configured for the wellness endpoint.
