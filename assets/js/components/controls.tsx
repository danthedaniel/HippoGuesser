import { h, Component } from 'preact';
import api from '../api';

declare var fetch: (url: string, options: any) => Promise<any>;

interface ControlsProps {
  state: null | api.State
}

/**
 * Moderator/Admin controls.
 */
export default class Controls extends Component<ControlsProps, {}> {
  constructor(props) {
    super(props);
  }

  /**
   * Send a state change to the server.
   *
   * @param type          State to update the round to.
   * @param correct_value String formatted as "0:00.00"
   */
  changeState(type: api.State, correct_value?: string) {
    api.state_change(type, correct_value);
  }

  render(props: ControlsProps, state: {}) {
    return (
      <div class="btn-group" role="group" aria-label="Moderator Controls">
        <button
          type="button"
          class="btn btn-success"
          onClick={() => this.changeState("in_progress")}
          disabled={props.state !== "closed"}>
          Start
        </button>
        <button
          type="button"
          class="btn btn-danger"
          onClick={() => this.changeState("completed")}
          disabled={props.state !== "in_progress"}>
          Stop
        </button>
        <button
          type="button"
          class="btn btn-primary"
          onClick={() => this.changeState("closed", prompt("What was the correct time?"))}
          disabled={props.state !== "completed"}>
          Call Winner
        </button>
      </div>
    );
  }
}
