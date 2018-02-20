import { h, Component } from 'preact';

export default class Controls extends Component {
  constructor(props) {
    super(props);
  }

  sendMessage(type, body) {
    this.props.channel.push(type, {body: body}, 5000)
      .receive("ok", (msg) => console.log("created message", msg))
      .receive("error", (reasons) => console.error("create failed", reasons))
      .receive("timeout", () => console.error("Networking issue..."));
  }

  render(props, state) {
    return (
      <div class="btn-group" role="group" aria-label="Basic example">
        <button
          type="button"
          class="btn btn-success"
          onClick={this.sendMessage.bind(this, "start", "")}
          disabled={props.state !== "closed"}>
          Start
        </button>
        <button
          type="button"
          class="btn btn-danger"
          onClick={this.sendMessage.bind(this, "stop", "")}
          disabled={props.state !== "in_progress"}>
          Stop
        </button>
        <button
          type="button"
          class="btn btn-primary"
          onClick={this.sendMessage.bind(this, "winner", "0:40.99")}
          disabled={props.state !== "completed"}>
          Get Winner
        </button>
      </div>
    );
  }
}
