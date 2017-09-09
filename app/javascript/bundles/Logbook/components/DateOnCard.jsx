import PropTypes from 'prop-types';
import React from 'react';

const DateOnCard = ({observ_date}) => ({

      // Just a demo of a richer function

      label() {
        return "Date:"
      },

      render() {
        return (
            <div>
              <dt>{this.label()}</dt>
              <dd>{observ_date}</dd>
            </div>
        )
      }

    }
);

DateOnCard.propTypes = {};

export default DateOnCard;
