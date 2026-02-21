import "./channels";

import './src/admin/ebird-importer';
import './src/admin/ebird-transitions';
import './src/admin/instant-search';
import './src/admin/suggest-combo';
import './src/admin/observation-form';

import { initTaxonSuggestField } from './src/admin/taxa_autosuggest';
window.Quails = window.Quails || {};
window.Quails.features = window.Quails.features || {};
window.Quails.features.taxaAutosuggest = { initTaxonSuggestField };

// Keypress
import {keypress} from "keypress.js";
window.keypress = keypress;
