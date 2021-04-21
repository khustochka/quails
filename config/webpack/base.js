const { webpackConfig, merge } = require('@rails/webpacker')

// Optional?
const cssConfig = {
    resolve: {
        extensions: ['.css']
    }
}

module.exports = merge(webpackConfig, cssConfig);
