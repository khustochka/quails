# Plan: Extract `PostCore` from `Post`

Branch: `post-core-extraction`

## Why

Posts are translatable: today the `posts` table holds one row per language,
and rows are considered "siblings" if they share the same `slug`. This is
brittle:

- Slug changes must be propagated to every sibling by hand, or the link
  between translations silently breaks.
- One sibling per slug is artificially elected as `canonical_for_observations`
  to own `cards.post_id` / `observations.post_id`. We need promotion/demotion
  rituals (`promote_to_canonical!`, `promote_sibling_if_canonical`,
  `only_one_canonical_per_slug` validation, an explicit "Make Canonical"
  button).
- Shared metadata (`topic`, `cover_image_slug`, `lj_data`,
  `publish_to_facebook`, `legacy_slug`) is duplicated across sibling rows and
  can drift.

The cleaner shape is to split language-agnostic data into a `post_cores`
table, with `posts` becoming per-language translations belonging to a core:

```
post_cores (slug, legacy_slug, topic, cover_image_slug, lj_data,
            publish_to_facebook)
  └─ posts (post_core_id, lang, title, body, face_date, status,
            publish_to_facebook?, commented_at, ...)
       └─ comments
cards.post_core_id        ← (was cards.post_id pointing at canonical post)
observations.post_core_id ← (was observations.post_id pointing at canonical)
```

`cards` and `observations` then point at `post_cores` directly. The
"canonical" concept disappears.

## Prior attempt

There is an unfinished attempt on branch `multilingual-posts`, last commit
`d96e8b469 Extract PostCore from Post (migration 1 of 2)`. It is described as
"migration 1 of 2" — i.e. the author already saw the work needed two passes
and stopped after the first. We should treat it as a reference, not a base to
rebase on: it predates the canonical-for-observations machinery on `main` and
has diverged.

What that commit did:

- Added `post_cores` table with `slug`, `legacy_slug`, `topic`,
  `cover_image_slug`, `lj_data`, `publish_to_facebook` and a unique index on
  `slug`.
- Added `posts.post_core_id`, backfilled by joining on `posts.slug`.
- Made `Post` `belongs_to :post_core`; delegated the moved attributes; changed
  the uniqueness constraint from `[slug, lang]` to `[post_core_id, lang]`.
- Updated form to use `simple_fields_for :post_core` and
  `accepts_nested_attributes_for :post_core`.
- Updated controllers/feeds/formatters to look up posts by joining
  `post_cores`.
- **Did not** migrate `cards.post_id` / `observations.post_id` over to
  `post_core_id`. The "canonical" concept did not exist yet on that branch —
  it picked an `observation_post` at read time by preferring the cyrillic
  sibling, which is the same brittleness in a different shape.
- **Did not** drop the moved columns from `posts` (the "migration 2 of 2"
  it referred to).

What the author likely got overwhelmed by (and what we need to plan for):

1. `cards.post_id` / `observations.post_id` redirection — every place that
   reads or writes those columns has to change, including search/attach UI.
2. URL helpers and `to_param` — slug is now on `post_core`, so many lookups
   need a join. The prior attempt added joins in some places (controller,
   feeds) but missed others (e.g. `format_strategy/base.rb` still does
   `Post.find_by(slug:)`).
3. Form UX — the new/edit form is a single form mixing core attributes and
   per-language attributes. Creating the second translation needs to *find*
   the existing core (by slug), not create a duplicate.
4. Tests — factories had to change shape; many model/controller/system tests
   touch slug/post pairs.

This plan keeps the destination the same but addresses each pain point
head-on: cards/observations move to `post_core_id` in the same migration,
the form is split into a two-step flow, and `format_strategy/base.rb` is
in the explicit reader audit (Phase 2).

## Note on `legacy_slug`

`legacy_slug` is only set on 4 English posts (`birthday-lifers-en`,
`florida-2024-en`, `year-summary-2024-en`, `year-summary-2025-en`). All
four end in `-en`. It exists purely to support the redirect in
`posts_controller#show`:

```ruby
legacy_post = fallback.find_by!(legacy_slug: params[:id])
redirect_to public_post_path(legacy_post), status: :moved_permanently
```

It moves to `post_cores` along with the other core attributes, but:

- **Not exposed on the add/edit forms** (neither the core form nor the
  translation form). It's a one-time historical redirect column —
  read-only for the app, edited only via console/migration if ever
  needed again.
- **Redirect should only fire for the `-en` suffixed URL.** Today's
  lookup is `find_by!(legacy_slug: params[:id])` against whatever the
  user requested. Tighten it to only attempt the legacy lookup when
  `params[:id]` ends with `-en` (or, equivalently, only when the
  current locale is English). That avoids any chance of a future
  non-English slug colliding with the historical English-suffix
  redirect.

## End state

- `post_cores` table owns: `slug`, `legacy_slug`, `topic`,
  `cover_image_slug`, `lj_data`, `publish_to_facebook`, timestamps.
- `posts` table owns: `post_core_id`, `lang`, `title`, `body`, `face_date`,
  `status`, `commented_at`, `updated_at`.
- `cards.post_core_id` and `observations.post_core_id` replace their
  current `post_id`.
- `Post#canonical_for_observations`, `promote_to_canonical!`,
  `canonical_sibling`, `only_one_canonical_per_slug`,
  `promote_sibling_if_canonical`, and the "Make Canonical" action are all
  deleted.
- `Post.localized_versions` / `Post.localized_for` / `Post.for_locale`
  become trivial scopes on `PostCore` (`core.posts.find_by(lang:)`).
- The edit form lets you edit core attributes once, and switch between
  translations from a tab/picker. Creating a translation creates a new
  `Post` belonging to the same `PostCore`.

## Phased migration

Everything ships in **one deployment**. Phases below are an ordering for
the development work — they should land on the branch in order, but only
Phase 2 (end) and later are required to keep the test suite green;
Phases 1 and 2 are tightly coupled (schema change forces reader updates)
and may land together. No dual-write, no deprecation phase, no
incremental rollback story.

Working assumption: data consistency check (already done) shows that
`legacy_slug` is the only attribute that diverges across sibling posts,
and it diverges only because exactly one sibling in each pair has the
`-en` value. All other core attributes are already identical across
siblings. Backfill is straightforward.

Decisions baked into this plan (previously open questions):

- **`publish_to_facebook` belongs on `PostCore`.** It's per-post-of-writing,
  not per-translation — production data has it identical across siblings.
- **`status`, `commented_at`, `title`, `body`, `face_date`, `lang`** stay
  on `posts`. Per-translation.
- **`slug`, `legacy_slug`, `topic`, `cover_image_slug`, `lj_data`,
  `publish_to_facebook`** move to `post_cores`. `legacy_slug` is NOT
  exposed on any form (see note above).
- **No "Make Canonical" UI in the end state.** Canonicality goes away
  entirely; cards/observations point at `post_core` directly.
- **Two-step create flow.** New `post_core` first, then new `post` for it.
  No nested attributes.

### Phase 1 — Schema and models

Single migration:

- Create `post_cores` with `slug` (unique), `legacy_slug` (unique where
  not null), `topic`, `cover_image_slug`, `lj_data`, `publish_to_facebook`,
  timestamps.
- Populate from `posts`: one row per distinct slug, taking attributes from
  the canonical post for that slug. `legacy_slug` coalesced from whichever
  sibling has it set.
- Add `posts.post_core_id` (not null, backfilled).
- Add `cards.post_core_id` and `observations.post_core_id`, backfilled from
  `posts.post_core_id` via the existing `post_id` link.
- Drop the moved columns from `posts`: `slug`, `legacy_slug`, `topic`,
  `cover_image_slug`, `lj_data`, `publish_to_facebook`,
  `canonical_for_observations`, and their indexes.
- Drop `cards.post_id` and `observations.post_id` (and FKs/indexes).

Models:

- `PostCore`: validations for slug/legacy_slug/topic/cover_image_slug;
  `has_many :posts, :cards, :observations`; lifts `LJData` struct and
  `cover_image_slug` URL validation.
- `Post`: `belongs_to :post_core`, delegates `slug`/`topic`/etc. to it.
  Drop `canonical_for_observations?`, `canonical_sibling`,
  `promote_to_canonical!`, `promote_sibling_if_canonical`,
  `only_one_canonical_per_slug`, `observation_post`,
  `clone_attrs_for_sibling`, and the matching validations/callbacks.
  Drop the `cover_image_slug` URL validation (moved to core).
- `Card`, `Observation`: `belongs_to :post_core` instead of `:post`.
  Drop `post_must_be_canonical` validation.
- `Post#cards`, `#observations`, `#species`, `#images`,
  `#lifer_species_ids`: query via `post_core_id`, no `observation_post`
  indirection.
- `Post.localized_versions` / `Post.localized_for` / `Post.for_locale` /
  `Post.year` / `Post.month`: rewrite around `post_core` as the natural
  query root. Keep the method names so callers don't churn.
- `Post#cache_key`: include `post_core.updated_at` so core edits bust
  per-translation caches.
- `Post#to_url_params` / `to_param`: read slug via the core.

Tests:

- Update `test/factories/posts.rb`; add `test/factories/post_cores.rb`.
  Factory builds a fresh `post_core` by default; tests for "two siblings
  sharing a slug" create the core once and two posts on it.
- Drop tests that exercised the canonical-promotion machinery (and the
  related controller action — see Phase 3).

### Phase 2 — Readers and URL paths

Anywhere code reads `post.slug` / `post.topic` / `card.post_id` etc.,
make sure it now resolves through `post_core`. Most of this is automatic
via delegation; the explicit lookups are:

- `posts_controller#show`: slug lookup becomes
  `PostCore.find_by(slug: …)` + pick translation. **Legacy slug lookup
  guarded to only fire when `params[:id]` ends with `-en`** (see note
  above).
- `formatters/format_strategy/base.rb`:
  `Post.find_by(slug:)` → `PostCore.find_by(slug:)` and resolve a
  translation for the current locale.
- `formatters/format_strategy/site.rb`, `live_journal.rb`: verify the
  `@posts` slug-keyed hash still makes sense.
- `feeds_controller`: any slug-based queries.
- `_other_lang_notice`, `_other_lang_expand`, `posts/show`, posts list
  partials, sitemap/feed templates: rendering still works (delegation
  makes most of this transparent).
- `lifelist/base.rb`: `preload_posts` rewrites — fetch `PostCore` records
  by `post_core_id`, pick a localized sibling per core.

### Phase 3 — Admin posts index

New admin landing page at `GET /posts` (admin only — public blog lives on
`/`).

Shape: one row per `PostCore` with per-language chips.

```
slug             | date       | topic | translations         | status
-----------------+------------+-------+----------------------+--------
my-spring-trip   | 2026-04-10 | OBSR  | [UK ✓] [EN ✓] [+RU]  | OPEN/OPEN
shout-20260301-… | 2026-03-01 | NEWS  | [UK ✓] [+EN] [+RU]   | OPEN
```

- `[LANG ✓]` chip links to the translation's edit page.
- `[+LANG]` chip starts step 2 of the create flow (Phase 4) for the
  chosen core + lang.
- Filters: topic, status, lang-present/lang-missing, year/month,
  FB-publishable.
- `/posts/hidden` and `/posts/facebook` redirect to the filtered index.
- Controller: `PostCore.includes(:posts).order(face_date_via_join: :desc)`
  — date sort comes from a join against `posts`. A SQL `MAX(face_date)`
  or `EXISTS` clause for filters.
- Remove the `promote_to_canonical` route and `posts#promote_to_canonical`
  action — covered here because the admin form no longer has that button.

### Phase 4 — Two-step create / edit flow

- **Step 1 — `post_cores#new` / `#create`.** Core-only fields: slug,
  topic, cover_image_slug, publish_to_facebook. (`legacy_slug` not
  exposed.) On save, redirect to step 2.
- **Step 2 — `posts#new` / `#create`.** Requires `post_core_id` (link
  from step 1 or from the index's `[+LANG]` chip). Per-translation fields
  only: title, body, face_date, lang, status.
- **`post_cores#edit`.** Edits shared attributes. Listed alongside its
  translations.
- **`posts#edit`.** Per-translation only. Shows a core summary at top
  with an "Edit shared fields" link and chips to other translations or
  `[+LANG]` to create one.
- The unified form (`posts/form.html.haml`) gets split into
  `post_cores/_form.html.haml` and `posts/_form.html.haml`. The shared
  "attach cards" section stays under `post_cores/show` (or the edit page,
  since cards belong to the core now).
- `clone_attrs_for_sibling` deleted — `[+LANG]` link just carries
  `post_core_id`.
- Tests for both create paths; system test for the index → core → new
  translation flow.

### Phase 5 — Sweep

- Drop any remaining `# DEPRECATED` markers that snuck in.
- Update CLAUDE.md / AGENTS.md notes about post structure.
- Ensure `db/schema.rb` is regenerated and committed.
- Final `bin/rails test:all` + `rubocop` + `haml-lint`.

## Risks remaining

1. **Cache invalidation.** `Post#cache_key` must include
   `post_core.updated_at`; otherwise fragment caches won't bust when a
   slug or cover image changes via the core form. Add a test for this.
2. **Feed canonical link tags.** The `<link rel="canonical">` for
   cross-language siblings used to rely on slug equality. After the move,
   it should resolve via the shared `post_core`. Verify in feed
   templates.
3. **`post_core_id` exposure in params.** Mass-assignment whitelists need
   to allow `post_core_id` on `Post` (for the step-2 create), but the
   step-1 → step-2 transition should not let an arbitrary user
   re-parent an existing post by editing the param. Guard at the
   controller level: `post_core_id` only writable on `posts#new`/`create`,
   not on `update`.
4. **Routes for `/posts`.** The current `resources :posts` exposes the
   admin actions. Adding an admin index at `GET /posts` may conflict —
   check `config/routes.rb` for a constraint like
   `administrative only: …`.

## Files most likely to need attention (reference)

Models: `app/models/post.rb`, `app/models/card.rb`,
`app/models/observation.rb`, `app/models/lifelist/base.rb`,
`app/models/comment.rb`.

Controllers: `app/controllers/posts_controller.rb`,
`app/controllers/blog_controller.rb`, `app/controllers/species_controller.rb`,
`app/controllers/feeds_controller.rb`, `app/controllers/cards_controller.rb`.

Views: `app/views/posts/*` (especially `form.html.haml`, `show.html.haml`,
`_other_lang_*`), `app/views/lifelist/stats.html.haml`,
`app/views/media/_long_details.html.haml`.

Formatters: `app/formatters/format_strategy/base.rb`,
`app/formatters/format_strategy/live_journal.rb`,
`app/formatters/format_strategy/site.rb`.

Tests: `test/models/post_test.rb`, `test/controllers/posts_controller_test.rb`,
`test/factories/posts.rb` (will need `post_cores.rb`), system tests under
`test/system/`.

Schema: `db/schema.rb` lines around `create_table "posts"`.
