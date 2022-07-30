// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';
import  "ilyabirman-likely/release/likely.css";

import '@fortawesome/fontawesome-free/css/all.css';
import './src/css/_banner.scss'

// TODO: do not load likely in IE <10. IE9 does not support classList
document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import './src/js/airbrake-js-setup';
import './src/js/post_expand';

import VideoResize from "./src/js/video-resize"
VideoResize.init()
