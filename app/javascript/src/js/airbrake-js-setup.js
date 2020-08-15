import { Notifier } from '@airbrake/browser';

const api_key = process.env.errbit_api_key
const host = process.env.errbit_host
const railsEnv = process.env.NODE_ENV || "development"

if (api_key && host) {

    const airbrake = new Notifier({
        projectId: 1,
        projectKey: api_key,
        environment: railsEnv,
        host: "https://" + host
    });

}
