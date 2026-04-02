// import * as ActiveStorage from "activestorage";
// import "../utils/direct_uploads.js"
//
// ActiveStorage.start();

import Likely from 'ilyabirman-likely';

document.addEventListener('DOMContentLoaded', function () {Likely.initiate()});

import './src/visitor/post-expand';

import './src/visitor/video-expand';

import Comments from './src/visitor/comments';
Comments.init();
