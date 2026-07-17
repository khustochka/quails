# Papercuts

Small frictions hit while working — retried tool calls, undocumented setup steps, flaky commands, stale caches, misleading errors, non-obvious gotchas. Append an entry as you hit them (see AGENTS.md → "Log papercuts"). One or two sentences each: what you were doing → what got in the way (a guess at cause/fix is a bonus). Do not add issues that you have fixed or are fixing.

- `bin/rails test` uses the `:good_job` queue adapter (not `:test`), so `assert_enqueued_with` / `assert_enqueued_jobs` are unavailable and fail with a confusing `undefined method` error. Assert on `GoodJob::Job.where(job_class: "…")` instead. A note in AGENTS.md would save the detour.

- `lib/quails.rb`, `lib/quails/env.rb` and `lib/core_ext/*` are `require`d during boot from `config/application.rb`, i.e. before minitest forks its parallel workers — and a worker never re-executes an already-loaded file, so coverage records 0% however well they are tested. They are `skip`ped in `test_helper.rb` for that reason. Moving the requires is not an option (`config/environments/*.rb` needs `Quails.env` while configuring); a real fix would have to start tracking before boot, e.g. `Coverage.setup` in a `-r` preload.

- No ENV-stubbing helper exists for tests. `Quails::Env` reads `QUAILS_ENV` at construction but `DYNO`/`PWD` on every call, so testing it needs a hand-rolled save/replace/restore-in-`ensure` helper (see `test/unit/libraries/env_test.rb`). A shared `with_env` test helper (or the `climate_control` gem) would remove the footgun — my first attempt restored ENV before the lazy reads happened and silently failed.

- Route helper names silently collide across locale scopes: `resources :photos, as: "images"` (unlocalized, for CRUD) claimed `images_path`, while the localized `images#index` inside `scope "(:locale)"` was declared anonymously and got no helper at all. Calling `images_path` in a view looked right but generated the unlocalized `POST /photos` path, so locale prefixes were dropped with no error — and `images_url(locale: :en)` silently ignored the `locale:` option. Worth auditing other `as:`-renamed resources that shadow a localized route of the same name.
