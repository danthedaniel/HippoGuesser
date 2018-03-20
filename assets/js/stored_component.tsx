import { h, Component } from 'preact';
import storage from './storage';

export default abstract class StoredComponent<P, S> extends Component<P, S> {
  constructor(props, default_state: S) {
    super(props);
    storage.registerDefault(this.constructor.name, default_state);
    this.state = storage.getState(this.constructor.name);
  }

  componentDidUpdate() {
    storage.setState(this.constructor.name, this.state);
  }

  /**
   * Reset the component's state to its default value.
   */
  defaultState() {
    const newState: S = storage.resetState(this.constructor.name);
    this.setState(newState);
  }
}
