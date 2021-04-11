process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const webpackConfig = require('./base')

// Check if it is still needed
// prevent exposing full path:
// https://github.com/webpack/webpack/issues/3603
// webpackConfig.config.output.devtoolModuleFilenameTemplate = function(info) {
//     const rel = path.relative(context, info.absoluteResourcePath)
//     return `webpack:///${rel}`
// }

module.exports = webpackConfig
