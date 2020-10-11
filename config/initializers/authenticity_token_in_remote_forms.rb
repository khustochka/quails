# frozen_string_literal: true

# This setting makes remote forms work with JavaScript off.
# It is false by default to make remote forms work when cached.

Rails.application.config.action_view.embed_authenticity_token_in_remote_forms = true
