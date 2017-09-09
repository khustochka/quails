// Simple example of a React "smart" component

import { connect } from 'react-redux';
import Card from '../components/Card';
import * as actions from '../actions/cardActionCreators';

// Which part of the Redux global state does our component want to receive as props?
//const mapStateToProps = (state) => ({ name: state.name });
const mapStateToProps = (state) => (state);

const CardContainer = connect(mapStateToProps, actions)(Card);

// Don't forget to actually use connect!
// Note that we don't export Logbook, but the redux "connected" version of it.
// See https://github.com/reactjs/react-redux/blob/master/docs/api.md#examples
export default CardContainer
