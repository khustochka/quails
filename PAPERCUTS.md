# Papercuts

Small frictions hit while working — retried tool calls, undocumented setup steps, flaky commands, stale caches, misleading errors, non-obvious gotchas. Append an entry as you hit them (see AGENTS.md → "Log papercuts"). One or two sentences each: what you were doing → what got in the way (a guess at cause/fix is a bonus).

- Route helper names silently collide across locale scopes: `resources :photos, as: "images"` (unlocalized, for CRUD) claimed `images_path`, while the localized `images#index` inside `scope "(:locale)"` was declared anonymously and got no helper at all. Calling `images_path` in a view looked right but generated the unlocalized `POST /photos` path, so locale prefixes were dropped with no error — and `images_url(locale: :en)` silently ignored the `locale:` option. Worth auditing other `as:`-renamed resources that shadow a localized route of the same name.
