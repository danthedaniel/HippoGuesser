import { h, Component } from 'preact';

export default class Controls extends Component {
  constructor(props) {
    super(props);
  }

  sendMessage(type, correct_value) {
    let url;
    if (correct_value) {
      url = `/api/rounds/current/change/${type}?correct=${correct_value}`;
    } else {
      url = `/api/rounds/current/change/${type}`;
    }
    fetch(url,
      {
        method: "PATCH",
        credentials: "same-origin"
      })
      .catch(error => console.error("Error:", error))
      .then(response => console.log("Success:", response));
  }

  render(props, state) {
    return (
      <div class="btn-group" role="group" aria-label="Basic example">
        <button
          type="button"
          class="btn btn-success"
          onClick={this.sendMessage.bind(this, "in_progress")}
          disabled={props.state !== "closed"}>
          Start
        </button>
        <button
          type="button"
          class="btn btn-danger"
          onClick={this.sendMessage.bind(this, "completed")}
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
