// import socket from '../socket';

import { h, Component } from 'preact';
import TwitchVideoEmbed from './twitch/embed.js';
import Guesses from './guesses.js';
import Guesser from './guesser.js';
import Controls from './controls.js';

export default class Layout extends Component {
  constructor(props) {
    super(props);
    this.state = {
      guesses: [
        {user: "teaearlgraycold", time: "0:40.99"},
        {user: "teaearlgraycold", time: "0:41.00"},
        {user: "teaearlgraycold", time: "0:39.64"}
      ],
      user: "teaearlgraycold",
      moderator: true,
      can_submit: true,
      input: {
        guess: ""
      }
    };
  }

  submitGuess() {
    let newState = Object.assign({}, this.state);
    newState.guesses.push({user: newState.user, time: this.state.input.guess});
    newState.input.guess = "";
    newState.can_submit = false;
    this.setState(newState);
  }

  setInput(key, value) {
    let newState = Object.assign({}, this.state);
    newState.input[key] = value;
    this.setState(newState);
  }

  render(props, state) {
    return (
      <div class="container">
        <div class="row">
          <div class="col">
            <div class="jumbotron">
              <h1 class="display-4">Hippo Time Guesser</h1>
              <p class="lead">
                Guess how long it will take Salt to take down King Hippo.
              </p>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-8">
            { /* <TwitchVideoEmbed channel="summoningsalt" /> */ }
          </div>
          <div class="col-4">
            <div class="row">
              <div class="col">
                <Guesser
                  submit={this.submitGuess.bind(this)}
                  update={this.setInput.bind(this, "guess")}
                  value={state.input.guess}
                  disabled={!this.state.can_submit} />
                { state.moderator && <Controls state="ready" /> }
                <Guesses data={state.guesses} />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
