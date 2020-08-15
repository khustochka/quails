const { environment } = require('@rails/webpacker')

const Dotenv = require('dotenv-webpack');

const nodeEnv = process.env.RAILS_ENV || process.env.NODE_ENV || "development"

environment.plugins.prepend('Dotenv',
    // Dotenv by default reads only .env file.
    // Replacing this with .env.{environment}, because this is where the errbit vars are
    new Dotenv({path: "./.env." + nodeEnv})
)

module.exports = environment
