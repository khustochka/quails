// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';
require("ilyabirman-likely/release/likely.css");

// TODO: do not load likely in IE <10. IE9 does not support classList
document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import './src/js/airbrake-js-setup';

import VideoResize from "./src/js/video-resize"
VideoResize.init()
