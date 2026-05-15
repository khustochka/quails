# TODO

## Audit visitor-facing post URL generation for distinct UK/RU URLs

Background: `default_public_post_path` (in `app/helpers/posts_helper.rb`)
drops the locale prefix for any cyrillic post (uk and ru both map to no
prefix). This was correct when only one cyrillic translation could exist
for a given post core — the controller's fallback logic served whichever
cyrillic translation existed under `/YYYY/MM/slug`.

Post-core extraction allows **both** UK and RU translations of the same
post to coexist. With both present, `default_public_post_path` for an RU
post returns the same URL as for its UK sibling — and that URL serves the
UK version. This means visitor-facing links to RU posts in some places
silently lead to the UK translation instead.

`localized_public_post_path` (also in `posts_helper.rb`) does the right
thing: UK → no prefix, RU → `/ru/...`, EN → `/en/...`. It's currently used
only by the admin posts index and the post-form sibling panel.

### Call sites to consider switching to `localized_public_post_path`

Most consequential (search-engine and feed-reader-visible):

- `app/views/feeds/sitemap.xml.haml`
- `app/views/feeds/blog.xml.builder`
- `app/views/feeds/instant_articles.xml.builder`
- `app/views/feeds/_article.html.haml` (rel=canonical)
- `app/views/feeds/_post.html.haml` (add-comment anchor)
- `app/views/posts/show.html.haml` (`@canonical`)

Comment-related (mostly correct under either helper, but ru-post comment
emails currently link to UK URL):

- `app/controllers/comments_controller.rb` (redirect after create)
- `app/views/comment_mailer/notify_admin.html.haml`
- `app/views/comment_mailer/notify_parent_author.html.haml`
- `app/views/comments/index.html.haml` (admin)

Wiki-link formatter — needs more thought:

- `app/formatters/format_strategy/site.rb` — `{{#post|slug}}` inside a
  post body. Pre-fix behavior keeps readers in the *current* locale even
  when linking to a sibling that only exists in another lang (fallback
  handles it). Switching to `localized_public_post_path` would yank the
  reader into the linked post's lang, which may or may not be desirable.
  Decide before changing.

### When to do this

Defer until at least one post has both UK and RU translations in
production. Currently no post does, so the bug is latent.
