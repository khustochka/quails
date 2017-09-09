import { combineReducers } from 'redux';
import { SAVE_CARD } from '../constants/logBookConstants';

const card = (state = '', action) => {
  switch (action.type) {
    case SAVE_CARD:
      return action.text;
    default:
      return state;
  }
};

const cardReducer = combineReducers({ card });

export default cardReducer;
