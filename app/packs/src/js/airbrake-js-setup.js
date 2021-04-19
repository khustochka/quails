// IMPORTANT NOTE: AIRBRAKE_API_KEY and host env vars need to be available at compile time.
// JS dotenv is unreliable (reads only one file). The solution is:
// to load dotenv in bin/webpack-dev-server and bin/webpack

if (ERRBIT_CONFIGURED) {
    const Airbrake = require('@airbrake/browser')

    const railsEnv = process.env.NODE_ENV || "development"

    const airbrake = new Airbrake.Notifier({
        projectId: 1,
        projectKey: process.env.AIRBRAKE_API_KEY,
        environment: railsEnv,
        host: "https://" + process.env.AIRBRAKE_HOST,
        remoteConfig: false,
        performanceStats: false,
        queryStats: false,
        queueStats: false
    });

    airbrake.addFilter((notice) => {
        if ((notice.errors[0].message === "Illegal invocation" || notice.errors[0].message === "Cannot read property 'value' of undefined")
            && notice.context.url.includes("?fbclid=")) {
            return null;
        }
        return notice;
    });
}
