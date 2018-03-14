import { h, Component } from 'preact';

declare var fetch: (url: string, options: any) => Promise<any>;

interface ControlsProps {
  state: null | "in_progress" | "completed" | "closed"
}

export default class Controls extends Component<ControlsProps, {}> {
  constructor(props) {
    super(props);
  }

  sendMessage(type: string, correct_value: undefined | string) {
    let url = `/api/rounds/current/change/${type}`;
    if (correct_value) {
      url += `?correct=${correct_value}`;
    }
    fetch(url,
      {
        method: "PATCH",
        credentials: "same-origin"
      })
      .catch(error => console.error("Error:", error))
      .then(response => console.log("Success:", response));
  }

  render(props: ControlsProps, state: {}) {
    return (
      <div class="btn-group" role="group" aria-label="Moderator Controls">
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
