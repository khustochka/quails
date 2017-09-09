/* eslint-disable import/prefer-default-export */

import { SAVE_CARD } from '../constants/logBookConstants';

export const saveCard = (new_card_props) => ({
  type: SAVE_CARD,
  new_card_props,
});
