// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';

document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import './src/visitor/post_expand';

import VideoResize from "./src/visitor/video-resize"
// Resize the video to these dimensions after it is started
VideoResize.init(853, 480)

import Comments from './src/visitor/comments';
Comments.init();
