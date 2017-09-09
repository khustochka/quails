import { createStore } from 'redux';
import cardReducer from '../reducers/cardReducer';

const configureStore = (railsProps) => (
  createStore(cardReducer, railsProps)
);

export default configureStore;
