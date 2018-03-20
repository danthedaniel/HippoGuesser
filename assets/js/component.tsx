import { h, Component } from 'preact';
import storage from './storage';

export default abstract class StateComponent<P, S> extends Component<P, S> {
  constructor(props) {
    super(props);
    this.state = storage.getState(this.constructor.name);
  }

  componentDidUpdate() {
    storage.setState(this.constructor.name, this.state);
  }

  defaultState() {
    const newState: S = storage.resetState(this.constructor.name);
    this.setState(newState);
  }
}
