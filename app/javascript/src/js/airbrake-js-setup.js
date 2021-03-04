if (ERRBIT_CONFIGURED) {
    const Airbrake = require('@airbrake/browser')

    const railsEnv = process.env.NODE_ENV || "development"

    const airbrake = new Airbrake.Notifier({
        projectId: 1,
        projectKey: process.env.errbit_api_key,
        environment: railsEnv,
        host: "https://" + process.env.errbit_host,
        remoteConfig: false,
        performanceStats: false,
        queryStats: false,
        queueStats: false
    });
}
