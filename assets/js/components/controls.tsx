import { h, Component } from 'preact';
import { state_change } from '../api/Rounds';

/**
 * The game state.
 */
type State = "in_progress" | "completed" | "closed";

interface ControlsProps {
  state: null | State
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
   * @param type    State to update the round to.
   * @param correct String formatted as "0:00.00"
   */
  sendMessage(type: State, correct?: string) {
    state_change(type, correct ? {correct} : null)
  }

  render(props: ControlsProps, state: {}) {
    return (
      <div class="btn-group" role="group" aria-label="Moderator Controls">
        <button
          type="button"
          class="btn btn-success"
          onClick={this.sendMessage.bind(this, "in_progress", null)}
          disabled={props.state !== "closed"}>
          Start
        </button>
        <button
          type="button"
          class="btn btn-danger"
          onClick={this.sendMessage.bind(this, "completed", null)}
          disabled={props.state !== "in_progress"}>
          Stop
        </button>
        <button
          type="button"
          class="btn btn-primary"
          onClick={() => this.sendMessage("closed", prompt("What was the correct time?"))}
          disabled={props.state !== "completed"}>
          Call Winner
        </button>
      </div>
    );
  }
}
