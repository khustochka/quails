const { environment } = require('@rails/webpacker')

const railsEnv = process.env.RAILS_ENV || process.env.NODE_ENV || "development"

const webpack = require("webpack")
require('dotenv').config({ path: "./.env." + railsEnv })
// Note dotenv JS only reads .env.<railsEnv> file, this is where you should put errbit config vars

environment.plugins.prepend('Define',
    new webpack.DefinePlugin({
      "process.env.errbit_api_key": JSON.stringify(process.env.errbit_api_key),
      "process.env.errbit_host": JSON.stringify(process.env.errbit_host),
      ERRBIT_CONFIGURED: !!process.env.errbit_api_key && !!process.env.errbit_host
    })
)

environment.splitChunks()

module.exports = environment
