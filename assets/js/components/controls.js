import { h, Component } from 'preact';

export default class Controls extends Component {
  constructor(props) {
    super(props);
  }

  render(props, state) {
    return (
      <div class="btn-group" role="group" aria-label="Basic example">
        <button
          type="button"
          class="btn btn-success"
          disabled={props.state !== "ready"}>
          Start
        </button>
        <button
          type="button"
          class="btn btn-danger"
          disabled={props.state !== "in_progress"}>
          Stop
        </button>
        <button
          type="button"
          class="btn
          btn-primary"
          disabled={props.state !== "closed"}>
          Get Winners
        </button>
      </div>
    );
  }
}
