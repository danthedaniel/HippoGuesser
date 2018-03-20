import { h, Component } from 'preact';
import api from '../api';

interface PropsType {
  state: null | api.State
}

/**
 * Moderator/Admin controls.
 */
export default class Controls extends Component<PropsType, {}> {
  constructor(props) {
    super(props);
  }

  changeState(type: api.State, correct_value?: string) {
    api.state_change(type, correct_value);
  }

  render(props: PropsType, state: {}) {
    switch (props.state) {
      case "closed":
        return <button
          class="btn btn-success btn-block mb-3"
          onClick={() => this.changeState("in_progress")}>
          Start
        </button>;
      case "in_progress":
        return <button
          class="btn btn-danger btn-block mb-3"
          onClick={() => this.changeState("completed")}>
          Stop
        </button>;
      case "completed":
        return <button
          class="btn btn-primary btn-block mb-3"
          onClick={() => this.changeState("closed", prompt("What was the correct time?"))}>
          Call Winner
        </button>;
      default:
        return <button
          class="btn btn-primary btn-block mb-3"
          disabled>
          Error
        </button>;
    }
  }
}
