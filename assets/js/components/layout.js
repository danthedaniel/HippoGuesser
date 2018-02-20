import { h, Component } from 'preact';
import TwitchVideoEmbed from './twitch/embed.js';
import Guesses from './guesses.js';
import Guesser from './guesser.js';
import Controls from './controls.js';
import Navbar from './navbar.js';
import {Socket} from "phoenix";

const cookies = document
  .cookie
  .split("; ")
  .map(cookie => cookie.split("="))
  .reduce((acc, x) => Object.assign(acc, {[x[0]]: x[1]}), {});

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
      game_state: null,
      input: {
        guess: ""
      }
    };
    this.socketConnect();
  }

  socketConnect() {
    this.socket = new Socket("/socket");
    this.socket.connect();

    this.channel = this.socket.channel("room:lobby");
    this.channel.join()
      .receive("ok", msg => this.gameState(msg.state))
      .receive("error", msg => console.log("Unable to join", msg));
    this.channel.on("start", msg => this.gameState("in_progress"));
    this.channel.on("stop", msg => this.gameState("completed"));
    this.channel.on("winner", msg => this.gameState("closed"));
  }

  gameState(game_state) {
    let newState = Object.assign({}, this.state);
    newState.game_state = game_state;
    this.setState(newState);
  }

  submitGuess() {
    let newState = Object.assign({}, this.state);
    const newGuess = {
      user: this.state.username,
      time: this.state.input.guess
    };
    newState.guesses.push(newGuess);
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
            { /*<TwitchVideoEmbed channel="summoningsalt" />*/ }
          </div>
          <div class="col-xs-12 col-md-12 col-lg-4">
            <div class="row">
              <div class="col">
                { state.username && <Guesser
                  submit={this.submitGuess.bind(this)}
                  update={this.setInput.bind(this, "guess")}
                  value={state.input.guess}
                  disabled={!this.state.can_submit} /> }
                { state.username && state.moderator && <Controls
                    state={state.game_state}
                    channel={this.channel} /> }
                <Guesses guesses={state.guesses} />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
