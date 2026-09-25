# Birdnik integration

Birdnik is an external service that provides external checklists for import.
Quails calls it on `BIRDNIK_API_URL`; see `Birdnik::Client`.

All calls are asynchronous: the receiver acknowledges immediately and the result is pushed back
as a separate HTTP request. The review page (`/external_checklists`) receives results live over
ActionCable (`ExternalChecklistsChannel`).

## Authentication

- Quails → Birdnik: `Authorization: Bearer $BIRDNIK_API_TOKEN`.
- Birdnik → Quails: `Authorization: Bearer $API_TOKEN` (Quails' API token, configured in Birdnik).

## Preload

1. Quails → Birdnik: `POST {BIRDNIK_API_URL}/preloads`

   ```json
   {"callback_url": "https://quails.example/api/external_checklists"}
   ```

   Birdnik responds `202 Accepted` and starts collecting unsubmitted checklists.

2. Birdnik → Quails: `POST {callback_url}`

   ```json
   {"checklists": [
     {"external_id": "S123456789", "time": "23 Sep 2026 7:15 AM", "location": "Brovary",
      "county": "Brovarskyi", "state_prov": "Kyiv, UA"}
   ]}
   ```

   `checklists` may be empty. On failure Birdnik sends `{"error": "message"}` instead.

   Quails skips checklists already imported as cards and upserts the rest, keeping the review state
   (locus, status) of existing ones. Responds `{"upserted": N}`; `400` if neither key is present.

## Manual testing

`bin/mock_birdnik` runs a mock Birdnik on port 3100, matching `BIRDNIK_API_URL` in `.env.development`.
It accepts a preload and pushes a few fake checklists to the callback after 2 seconds
(`MOCK_BIRDNIK_ERROR=1` pushes an error instead).
