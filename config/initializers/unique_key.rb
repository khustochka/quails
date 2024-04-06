# frozen_string_literal: true

# This is a unique key that is refreshed after every deploy and restart of the app.
# It can be used in cache keys that need to be invalidated on deploy/restart.

Quails.config.unique_key = SecureRandom.hex(16)
