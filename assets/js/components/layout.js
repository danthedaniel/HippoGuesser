// import socket from '../socket';

import { h, Component } from 'preact';
import TwitchVideoEmbed from './twitch/embed.js';
import Guesses from './guesses.js';
import Guesser from './guesser.js';
import Controls from './controls.js';
import Navbar from './navbar.js';

const cookies = (() => {
  let cookie_obj = {};
  document.cookie
    .split("; ")
    .map(cookie => cookie.split("="))
    .forEach(pair => {
      cookie_obj[pair[0]] = pair[1];
    });
  return cookie_obj;
})();

export default class Layout extends Component {
  constructor(props) {
    super(props);
    this.state = {
      guesses: [
        {user: "teaearlgraycold", time: "0:40.99"},
        {user: "teaearlgraycold", time: "0:41.00"},
        {user: "teaearlgraycold", time: "0:39.64"}
      ],
      username: cookies["username"],
      moderator: true,
      can_submit: true,
      input: {
        guess: ""
      }
    };
  }

  submitGuess() {
    let newState = Object.assign({}, this.state);
    newState.guesses.push({user: newState.username, time: this.state.input.guess});
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
            <Navbar active="Guess!" username={state.username} />
          </div>
        </div>
        <div class="row">
          <div class="col-xs-12 col-md-12 col-lg-8">
            { /* <TwitchVideoEmbed channel="summoningsalt" /> */ }
          </div>
          <div class="col-xs-12 col-md-12 col-lg-4">
            <div class="row">
              <div class="col">
                <Guesser
                  submit={this.submitGuess.bind(this)}
                  update={this.setInput.bind(this, "guess")}
                  value={state.input.guess}
                  disabled={!this.state.can_submit} />
                { state.moderator && <Controls state="ready" /> }
                <Guesses guesses={state.guesses} />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
