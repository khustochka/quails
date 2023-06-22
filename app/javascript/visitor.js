// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';

document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import './src/airbrake-js-setup';
import './src/post_expand';
import './src/tooltips'

import VideoResize from "./src/video-resize"
VideoResize.init()
