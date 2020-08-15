if (ERRBIT_CONFIGURED) {
    const Notifier = require('@airbrake/browser')

    const railsEnv = process.env.NODE_ENV || "development"

    const airbrake = new Notifier({
        projectId: 1,
        projectKey: process.env.errbit_api_key,
        environment: railsEnv,
        host: "https://" + process.env.errbit_host
    });
}
