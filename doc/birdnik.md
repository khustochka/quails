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

   `checklists` is the complete list of unsubmitted checklists, possibly empty. On failure Birdnik sends
   `{"error": "message"}` instead.

   Quails skips checklists already imported as cards and upserts the rest, keeping the review state
   (locus, status) of existing ones. Pending checklists missing from the list are removed. Responds `{"upserted": N}`; `400` if neither key is present.

## Import

1. Quails → Birdnik: `POST {BIRDNIK_API_URL}/fetches`

   ```json
   {"external_ids": ["S123456789", "S123456790"],
    "callback_url": "https://quails.example/api/external_checklists/import"}
   ```

   Sent when checklists with a selected locus are imported from the review page; they are marked
   `requested`. Birdnik responds `202 Accepted` and fetches the checklists one by one.

2. Birdnik → Quails: `POST {callback_url}`, one request per checklist.

   ```json
   {"external_id": "S123456789",
    "checklist": {
      "observ_date": "2026-09-19", "start_time": "07:05", "protocol": "Traveling",
      "duration_minutes": 95, "distance_kms": 3.2, "area_acres": null, "observers": 2,
      "notes": "Checklist comments", "complete": true,
      "observations": [
        {"name": "Mallard", "species_code": "mallar3", "count": "12", "comments": "", "obs_id": "OBS123"}
      ]}}
   ```

   Values are as shown on the eBird checklist page: `protocol` is the eBird protocol name, `observers` is the
   party size, `count` is `"X"` when not counted, `start_time` is null when not recorded. `distance_kms` is in
   kilometers. If the checklist cannot be fetched, Birdnik sends `{"external_id": "…", "error": "message"}`.

   Quails creates a card at the locus selected for the checklist and marks it imported, or marks it failed
   with the error. Responds `{"status": "imported"}`, or `422` with `{"status": "failed", "error": "…"}`;
   `404` for an unknown `external_id`, `409` if already imported.
