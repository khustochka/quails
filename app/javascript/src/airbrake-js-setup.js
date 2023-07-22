import {Notifier} from '@airbrake/browser'

const airbrakeMeta = document.querySelector("meta[name=airbrake-config]"),
      airbrakeConfig = airbrakeMeta && airbrakeMeta.content.split(":") || [];

if (airbrakeConfig[0] && airbrakeConfig[1]) {

  // FIXME: This does not work currently, making railsEnv always development.
  const railsEnv = process.env.NODE_ENV || "development"

  const airbrake = new Notifier({
    projectId: airbrakeConfig[2] || 1,
    projectKey: airbrakeConfig[1],
    environment: railsEnv,
    host: "https://" + airbrakeConfig[0],
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
