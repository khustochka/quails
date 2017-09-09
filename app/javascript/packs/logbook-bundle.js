import ReactOnRails from 'react-on-rails';

import LogbookApp from '../bundles/Logbook/startup/LogbookApp';

// This is how react_on_rails can see the Logbook in the browser.
ReactOnRails.register({
  LogbookApp,
});
