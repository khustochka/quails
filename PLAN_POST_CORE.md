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

This plan keeps the destination the same but breaks the work into smaller,
independently shippable steps so we don't have one mega-PR again.

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

Each phase is one PR. **Preserve the existing structure as long as
possible** — every phase up to the final sweep should leave the old
columns, associations, methods, and routes in place so that a phase can be
reverted by toggling readers back, without a destructive schema rollback.
Deletions (columns, models, routes, UI) happen only in the final phase,
once the new path has been live and stable.

Concretely:

- **No `DROP COLUMN` migrations before Phase 6.** Phases 2 and 4 add new
  columns and switch readers/writers, but the old columns
  (`posts.slug`, `posts.topic`, …, `cards.post_id`, `canonical_for_observations`,
  etc.) stay populated by dual-write until Phase 6.
- **No model method or route deletions before Phase 6.** Old methods
  (`canonical_sibling`, `promote_to_canonical!`,
  `localized_versions` in its current shape, `clone_attrs_for_sibling`,
  the `promote_to_canonical` route) remain alongside their replacements.
  Mark them `# DEPRECATED: remove in Phase 6` so the sweep is mechanical.
- **No "Make Canonical" UI removal before Phase 6.** Hide it from the
  admin form if it becomes confusing, but the route/action stays.
- **Dual-write in both directions.** When Phase 2 adds
  `cards.post_core_id`, also keep writing `cards.post_id` (and vice versa
  for any writer that touches one column, set the other). Same for the
  attributes mirrored between `posts` and `post_cores` in Phase 1.
- **Each phase ships behind verifiable invariants.** Add tests that assert
  `post.slug == post.post_core.slug`, `card.post_id` and
  `card.post_core_id` resolve to the same thing, etc. Keep these
  invariants until Phase 6.

If a phase needs to be rolled back, the revert is: revert the code
commit. The data is still consistent because the old columns/associations
were never abandoned.

### Phase 1 — Introduce `PostCore`, backfill, dual-write (no behavior change)

- Migration: create `post_cores`, populate from `posts` (one row per distinct
  slug, taking attributes from the canonical post for that slug to break
  ties — not the first-created post like the prior attempt; canonical is the
  authoritative source now).
- Migration: add `posts.post_core_id` (nullable initially), backfill, then
  `null: false`.
- `Post belongs_to :post_core` (do **not** delegate slug yet — both columns
  live in parallel).
- Add a model-level invariant test that `post.slug == post.post_core.slug`,
  `post.topic == post.post_core.topic`, etc., for every fixture/factory.
- Update `Post`'s after-save to mirror writes to `post_core` for now (and
  vice versa) — temporary dual-write so we can land this without breaking
  anything else. Audit which attributes are even writable per-post in
  practice; `topic`/`cover_image_slug`/`legacy_slug` are rarely changed.
- Ship and bake. No reader changes.

### Phase 2 — Add `post_core_id` to cards/observations; dual-write

This is the most invasive change and deserves its own PR. **Additive
only** — `post_id` stays.

- Migration: add `cards.post_core_id` and `observations.post_core_id`
  (nullable initially), backfill from the canonical post's
  `post_core_id`:
  `cards.post_core_id = posts.post_core_id WHERE posts.id = cards.post_id`.
  Then `null: false` once backfill is verified.
- `Card` and `Observation` `belongs_to :post_core` *in addition to*
  `belongs_to :post`. Both stay live.
- Dual-write: any writer that sets `card.post_id = post.id` also sets
  `card.post_core_id = post.post_core_id`, and vice versa (callback). The
  old "must be canonical" validation stays in place so that `post_id`
  remains pointing at the canonical translation.
- **Readers stay on `post_id` for now.** `Post#cards`/`Post#observations`
  /`Post#species`/`Post#images`/`Post#lifer_species_ids` are unchanged.
  This phase just establishes and proves the new column.
- Add an invariant test: for every card/observation,
  `post_core_id == post.post_core_id`.
- **Do not** drop `posts.canonical_for_observations` or
  `cards.post_id`/`observations.post_id` here — that's Phase 6.
- **Watch out**: `Card.post_id_changed?` callbacks and any uniqueness
  constraints referencing `post_id` — they keep working untouched.

### Phase 3 — Switch readers to `post_core` (old columns stay)

- Audit every reader of `post.slug`, `post.topic`, `post.cover_image_slug`,
  `post.legacy_slug`, `post.lj_data`, `post.publish_to_facebook`, and
  every reader of `card.post_id` / `observation.post_id`:
  - Controllers: `posts_controller#show` (slug lookup → join post_cores);
    `feeds_controller` (already partially in prior attempt).
  - Formatters: `format_strategy/base.rb` `Post.find_by(slug:)` →
    `PostCore.find_by(slug:)` + pick a translation for the current locale.
    `format_strategy/live_journal.rb` / `site.rb` iterate `@posts` keyed by
    slug — verify the key is still meaningful.
  - Views: `_other_lang_notice`, `_other_lang_expand`, `form.html.haml`,
    posts list partials, sitemap/feed templates.
  - Models: `Post#cards`/`Post#observations`/`Post#species`/`Post#images`/
    `Post#lifer_species_ids` switch from
    `WHERE cards.post_id = observation_post.id` to
    `WHERE cards.post_core_id = post_core_id`. The `observation_post`
    indirection disappears at the call site, but the method stays
    (returns `self` or `canonical_sibling`) and is marked deprecated.
- Switch `Post` to `delegate :slug, :topic, ... to: :post_core` for
  *reads*. Writes still go to both via the dual-write callback from
  Phase 1; the underlying columns on `posts` are not yet removed.
- Update `to_param` / URL helpers: `to_url_params` uses `slug_was`; this has
  to become `post_core.slug_was`.
- Update `Post.localized_versions` / `Post.localized_for` / `Post.for_locale`
  / `Post.year` / `Post.month` to query via `post_core` association
  (`PostCore` becomes the natural query root for "find the post for slug X
  in locale Y"). Keep the old method signatures so callers don't change.
- Update factories so building a `Post` either accepts an existing core or
  builds one; factory for "two siblings sharing a slug" becomes
  `create(:post_core, ...)` then `create(:post, post_core:, lang: ...)`
  twice. Keep existing factories for compatibility where reasonable.
- **Do not delete** `canonical_for_observations?`, `canonical_sibling`,
  `promote_to_canonical!`, `observation_post`, etc. They still work and
  are still exercised by their existing tests.
- Tests, rubocop, haml-lint.

### Phase 4 — Reserved (formerly "drop redundant columns")

Column drops are deferred to Phase 6. Use this slot for any post-Phase-3
read-path cleanup that doesn't require schema changes — for example,
inlining `observation_post` callers, simplifying `Post#cards` once the
join is via `post_core`, etc. Old methods stay in place; this is just
where their call sites get rewired.

If nothing remains, skip this phase entirely.

### Phase 4.5 — Admin posts index (built against pre-refactor schema)

Today there is no general admin index for posts — only `/posts/hidden`
(drafts) and `/posts/facebook`. Building one now, *before* the form
refactor, gives us:

1. An admin landing page for posts independent of the refactor.
2. A place to force the design decisions phase 5 needs (filters, sort,
   how translations are surfaced).
3. A view that swaps cleanly to `PostCore` as the query root in phase 5
   without the template changing much.

Shape: one row per slug (= per future `PostCore`), with per-language chips:

```
slug             | date       | topic | translations         | status
-----------------+------------+-------+----------------------+--------
my-spring-trip   | 2026-04-10 | OBSR  | [UK ✓] [EN ✓] [+RU]  | OPEN/OPEN
shout-20260301-… | 2026-03-01 | NEWS  | [UK ✓] [+EN] [+RU]   | OPEN
```

- Existing `[UK ✓]` chip links to that translation's edit page.
- `[+EN]` chip creates a new sibling translation (today: clone-by-slug;
  after phase 5: create-under-core).
- Filters: topic, status, lang present/missing, year/month, FB-publishable.
  `/hidden` and `/facebook` become filter presets — keep their URLs as
  redirects to the filtered index.
- Implementation against current schema: group `Post` by `slug` in the
  controller (`Post.group_by(&:slug)` after an ordered fetch, or a window-
  function query). It's throwaway grouping code; in phase 5 it becomes
  `PostCore.includes(:posts).order(...)`.
- Route: `GET /posts` for admin (the current root `/` is the public blog).
  Be careful — `resources :posts` may already define this; check
  `config/routes.rb`.

### Phase 5 — Form & UI cleanup

The prior attempt punted on this and the plan explicitly avoids a single
combined form. Two-step flow:

- **Step 1: create a `PostCore`.** Dedicated `post_cores#new` form with
  core fields only (slug, topic, cover_image_slug, publish_to_facebook).
  On save, redirect to step 2.
- **Step 2: create a `Post` (translation) from a core.** Existing
  `posts#new`, but it now requires `post_core_id` (or finds the core via
  slug). Form contains only per-translation fields (title, body, face_date,
  lang, status). The core's slug/topic/etc. are shown read-only at the top
  with a link to edit the core separately.
- Edit:
  - `post_cores#edit` — edits shared attributes only.
  - `posts#edit` — edits the translation only; shows the core summary +
    "Edit shared fields" link + chips to other existing translations + a
    "Create translation in X" button (a new `Post` under the same core).
- Admin index from phase 4.5 becomes the entry point for everything: each
  row links to the core (slug header), each chip links to its translation,
  `+LANG` chip starts step 2 with the core preselected.
- The two-step flow is added *alongside* the existing single-form flow.
  The existing form keeps working until Phase 6. Hide the "Make Canonical"
  button from the form once the new flow is in place, but leave the route
  and action live.
- `clone_attrs_for_sibling` stays — the new "Create translation" button
  uses `post_core_id` instead, but the old code path remains as a
  fallback.

### Phase 6 — Final sweep (the only destructive phase)

Run only after the new path has been live and stable, and after a final
audit confirms no readers/writers touch the deprecated columns or methods.

- Schema:
  - Drop `posts.slug`, `posts.legacy_slug`, `posts.topic`,
    `posts.cover_image_slug`, `posts.lj_data`, `posts.publish_to_facebook`
    and their indexes.
  - Drop `posts.canonical_for_observations` and its partial index.
  - Drop `cards.post_id` and `observations.post_id` and their FKs/indexes.
- Models:
  - Remove dual-write callbacks from Phase 1 and Phase 2.
  - Remove `Card#post_must_be_canonical` / `Observation#post_must_be_canonical`.
  - Remove `Post#canonical_for_observations?`, `canonical_sibling`,
    `promote_to_canonical!`, `promote_sibling_if_canonical`,
    `only_one_canonical_per_slug`, `observation_post`,
    `clone_attrs_for_sibling`. Inline any remaining callers.
  - Remove the temporary `belongs_to :post` on `Card`/`Observation` if it
    has no remaining readers.
- Routes/UI:
  - Remove `POST /posts/:id/promote_to_canonical` route and the
    controller action.
  - Remove the single-form create flow if Phase 5's two-step flow has
    fully replaced it. (Or keep the unified `edit` for a translation
    and only retire `new`.)
  - Remove `_other_lang_*` partials that are superseded, if any.
- Tests: delete tests that exercised the removed methods/routes.
- Docs: update CLAUDE.md / AGENTS.md notes on Post / multilingual
  structure.

This is the only commit that is hard to revert. Everything before it
should be revertable by code-only rollback.

## Risks & open questions

1. **Slug ownership during transition.** Phase 1 dual-writes both ways.
   What happens if someone edits the slug on the non-canonical sibling?
   Either disallow editing slug on non-canonical until phase 3, or accept
   that a slug edit on any sibling rewrites the shared core (which is
   actually the correct end-state semantics — fine to enable early).
2. **`legacy_slug` uniqueness.** Currently `unique where legacy_slug IS NOT
   NULL` on `posts`. After the move, this is on `post_cores`. Verify no
   sibling pair currently has different `legacy_slug` values (data check
   before phase 1 migration).
3. **`publish_to_facebook`.** Today this is per-post-row. Is it actually
   per-language or per-piece-of-writing? If we publish only one translation
   to Facebook, this stays on `posts`, not `post_cores`. Decide before
   phase 1: it's listed under `post_cores` in the prior attempt but that
   may be wrong.
4. **`commented_at`.** Per-post (comments are per-translation). Stays on
   `posts`. Already correct.
5. **`status`.** Per-post (a translation can be `PRIV` while its sibling is
   `OPEN`). Stays on `posts`. Already correct.
6. **Cache keys.** `Post#cache_key` mixes `id` and `updated_at`. After the
   slug moves, `post_core.updated_at` is a new dimension — bumping core
   should bust caches for all translations. Easy to handle but worth a
   line in the cache_key.
7. **Feed URLs / canonical link tags.** Make sure the cross-language
   canonical `<link rel="canonical">` still resolves; the `_other_lang_*`
   partials currently rely on `localized_versions` keyed by `lang`.
8. **`Post.year` / `Post.month` / `Post.years`.** These query
   `posts.face_date` — still per-post, no change beyond the join for slug.

## Suggested order of execution

1. Land phase 1 (dual-write) — small, mechanical, low risk.
2. **Pause** to confirm production data is consistent (no slug drift across
   siblings, `legacy_slug` not divergent, `publish_to_facebook` not
   divergent — or decide it stays on `posts`).
3. Land phase 2 (cards/observations → post_core) — biggest payoff, removes
   the canonical machinery.
4. Land phase 3 (readers) and phase 4 (drop columns) together or back to
   back.
5. Land phase 4.5 (admin index) — can also slip earlier as a standalone
   change against today's schema if useful sooner. The grouping logic is
   throwaway either way.
6. Phase 5 (UI two-step flow) — design first, code second.
7. Phase 6 — sweep.

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
