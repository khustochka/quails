// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

// This would not work with esbuild. Just require all channels one by one, when/if we have any.
// const channels = require.context('.', true, /_channel\.js$/)
// channels.keys().forEach(channels)
