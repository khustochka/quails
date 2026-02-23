// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Rails from '@rails/ujs';
Rails.start();

// import './src/setup/airbrake-js-setup';
import './src/setup/honeybadger-js-setup';
import './src/visitor/tooltips';
import './src/visitor/search';
