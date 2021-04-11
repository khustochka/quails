const { webpackConfig, merge } = require('@rails/webpacker')

const webpack = require("webpack")

const definePlugin = new webpack.DefinePlugin({
    "process.env.errbit_api_key": JSON.stringify(process.env.errbit_api_key),
    "process.env.errbit_host": JSON.stringify(process.env.errbit_host),
    ERRBIT_CONFIGURED: !!process.env.errbit_api_key && !!process.env.errbit_host
})

// Optional?
const cssConfig = {
    resolve: {
        extensions: ['.css']
    }
}

module.exports = merge(webpackConfig, cssConfig, {
    plugins: [definePlugin],
});
