import { h, Component } from 'preact';
import Flash from './flash';

const invalid_message = "Time is invalid - must be formatted as 0:00.00";

interface GuesserProps {
  submit: () => any,
  update: (value: string) => any,
  value: string,
  flash: Flash,
  disabled: boolean
}

export default class Guesser extends Component<GuesserProps, {}> {
  constructor(props) {
    super(props);
  }

  handleGuessKeyDown(event: KeyboardEvent) {
    if (event.key === "Enter") {
      if (/^\d+:\d\d.\d\d$/.test(this.props.value)) {
        this.props.submit();
      } else {
        this.props.flash.danger(invalid_message);
      }
    }
  }

  handleSubmitClick(event: MouseEvent) {
    if (/^\d+:\d\d.\d\d$/.test(this.props.value)) {
      this.props.submit();
    } else {
      this.props.flash.danger(invalid_message);
    }
  }

  handleInput(event) {
    const value = event.target.value;
    if (/^(\d+(:(\d(\d(\.(\d(\d)?)?)?)?)?)?)?$/.test(value)) {
      this.props.update(value);
    } else {
      this.props.update(this.props.value);
    }
  }

  render(props: GuesserProps, state: {}) {
    return (
      <div class="input-group mb-3">
        <div class="input-group-prepend">
          <span class="input-group-text" id="basic-addon1">Time:</span>
        </div>
        <input
          type="text"
          class="form-control"
          placeholder="0:00.00"
          pattern="^\d+:\d\d.\d\d$"
          value={props.value}
          disabled={props.disabled}
          onInput={this.handleInput.bind(this)}
          onKeyPress={this.handleGuessKeyDown.bind(this)}
          aria-label="guess" />
        <input
          type="button"
          class="btn btn-primary"
          disabled={props.disabled}
          onClick={this.handleSubmitClick.bind(this)}
          value="Submit" />
      </div>
    );
  }
}
