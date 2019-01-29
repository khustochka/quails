const environment = require('./environment')

const path = require('path')
const context = "../.."

// prevent exposing full path:
// https://github.com/webpack/webpack/issues/3603
environment.config.output.devtoolModuleFilenameTemplate = function(info) {
        const rel = path.relative(context, info.absoluteResourcePath)
        return `webpack:///${rel}`
}

// Enable source map.
// Will be default in the next Rails.
environment.config.merge({devtool: 'source-map'})

module.exports = environment.toWebpackConfig()
