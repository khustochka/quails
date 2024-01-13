// ES module
import Honeybadger from '@honeybadger-io/js';

const honeybadgerMeta = document.querySelector("meta[name=honeybadger-api-key]"),
      apiKey = honeybadgerMeta && honeybadgerMeta.content;

if (apiKey) {
    Honeybadger.configure({
        apiKey: apiKey,
        environment: process.env.NODE_ENV || 'development'
    })
}
