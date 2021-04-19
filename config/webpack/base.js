const { webpackConfig, merge } = require('@rails/webpacker')

const webpack = require("webpack")

const definePlugin = new webpack.DefinePlugin({
    "process.env.AIRBRAKE_API_KEY": JSON.stringify(process.env.AIRBRAKE_API_KEY),
    "process.env.AIRBRAKE_HOST": JSON.stringify(process.env.AIRBRAKE_HOST),
    ERRBIT_CONFIGURED: !!process.env.AIRBRAKE_API_KEY && !!process.env.AIRBRAKE_HOST
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
