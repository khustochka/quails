// These libraries do not work in IE7/8. When included into application.js they fail and prevent all
// the rest of JS to work (e.g. search autosuggest). I extracted them to a separate file so that their failure
// will not interfere with other scripts.

import Turbolinks from 'turbolinks';
import Likely from 'ilyabirman-likely';
require("ilyabirman-likely/release/likely.css");

Turbolinks.start();

document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import '../src/js/airbrake-js-setup.js.erb';
