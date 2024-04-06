// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';

document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

// import './src/airbrake-js-setup';
import './src/honeybadger-js-setup';
import './src/post_expand';
import './src/tooltips'

import VideoResize from "./src/video-resize"
// Resize the video to these dimensions after it is started
VideoResize.init(853, 480)
