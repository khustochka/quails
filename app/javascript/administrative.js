import "./channels";

import './src/admin/ebird-importer';
import './src/admin/ebird-transitions';
import './src/admin/instant-search';
import './src/admin/suggest-combo';
import './src/admin/observation-form';
import './src/admin/cards';
import './src/admin/flickr-search';
import './src/admin/obs-selector';
import './src/admin/image-form';
import './src/admin/wiki-fields';
import './src/admin/motorless';
import './src/admin/post-form';
import './src/admin/observation-move';
import './src/admin/image-flickr';
import './src/admin/loci-order';

// jQuery is only used on map-related pages
import jquery from 'jquery';
window.jQuery = jquery;
window.$ = jquery;
