# Papercuts

Small frictions hit while working — retried tool calls, undocumented setup steps, flaky commands, stale caches, misleading errors, non-obvious gotchas. Append an entry as you hit them (see AGENTS.md → "Log papercuts"). One or two sentences each: what you were doing → what got in the way (a guess at cause/fix is a bonus).

- `Locus#cache_parent_loci` (app/models/locus.rb) is private and has no callers anywhere — its comment says "Use when necessary", so it seems to be a console-only maintenance method. It shows up as uncovered and can't be reached from application code; either make it a documented rake task or delete it.

- `bin/rails test` uses the `:good_job` queue adapter (not `:test`), so `assert_enqueued_with` / `assert_enqueued_jobs` are unavailable and fail with a confusing `undefined method` error. Assert on `GoodJob::Job.where(job_class: "…")` instead. A note in AGENTS.md would save the detour.

- Coverage under-reports files loaded before SimpleCov starts. `lib/quails.rb`, `lib/quails/env.rb` and `lib/core_ext/*` are required from `config/application.rb`, so their definition lines execute before tracking begins and they report as 0% even when well tested — `env_test.rb` alone shows `lib/quails/env.rb` at 26/28 in a single-process run, but the full parallel suite reports 0/28. The `Rails.application.eager_load!` line already commented out in `test_helper.rb` is aimed at this. Real coverage of `lib/` is therefore better than the report suggests; don't chase those zeros with tests that already exist.

- `test/helpers/species_helper_test.rb` (and possibly other helper test files) is an empty stub — `class SpeciesHelperTest < ActionView::TestCase; end` with no tests. It looks like coverage exists when it doesn't. Worth either filling in or deleting so the gap is visible.

- No ENV-stubbing helper exists for tests. `Quails::Env` reads `QUAILS_ENV` at construction but `DYNO`/`PWD` on every call, so testing it needs a hand-rolled save/replace/restore-in-`ensure` helper (see `test/unit/libraries/env_test.rb`). A shared `with_env` test helper (or the `climate_control` gem) would remove the footgun — my first attempt restored ENV before the lazy reads happened and silently failed.

- Route helper names silently collide across locale scopes: `resources :photos, as: "images"` (unlocalized, for CRUD) claimed `images_path`, while the localized `images#index` inside `scope "(:locale)"` was declared anonymously and got no helper at all. Calling `images_path` in a view looked right but generated the unlocalized `POST /photos` path, so locale prefixes were dropped with no error — and `images_url(locale: :en)` silently ignored the `locale:` option. Worth auditing other `as:`-renamed resources that shadow a localized route of the same name.
