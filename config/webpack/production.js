const environment = require('./environment')

const path = require('path')
const context = "../.."

// prevent exposing full path:
// https://github.com/webpack/webpack/issues/3603
environment.config.output.devtoolModuleFilenameTemplate = function(info) {
        const rel = path.relative(context, info.absoluteResourcePath)
        return `webpack:///${rel}`
}

module.exports = environment.toWebpackConfig()
