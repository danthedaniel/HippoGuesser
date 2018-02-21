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
      guesses: [],
      username: cookies["username"],
      moderator: cookies["roll"] === "mod" || cookies["role"] === "admin",
      can_submit: true,
      game_state: null,
      input: {
        guess: ""
      }
    };
  }

  componentDidMount() {
    this.socketConnect();
  }

  componentWillUnmount() {
    this.socket.disconnect();
    this.channel.leave();
  }

  socketConnect() {
    this.socket = new Socket("/socket");
    this.socket.connect();

    this.channel = this.socket.channel("room:lobby");
    this.channel.join()
      .receive("ok", msg => this.gameState(msg.state, msg.guesses))
      .receive("error", msg => console.log("Unable to join", msg));
    this.channel.on("state", msg => this.gameState(msg.state, msg.guesses));
    this.channel.on("guess", this.gameGuess.bind(this));
  }

  gameGuess(guess) {
    let newState = Object.assign({}, this.state);
    newState.guesses.push(guess);
    this.setState(newState);
  }

  gameState(game_state, guesses) {
    let newState = Object.assign({}, this.state);
    newState.game_state = game_state;
    if (guesses) {
      newState.guesses = guesses;
    }
    this.setState(newState);
  }

  submitGuess() {
    const value = this.state.input.guess;
    fetch(`/api/rounds/current/guess?value=${value}`,
      {
        method: "POST",
        credentials: "same-origin"
      })
      .catch(error => console.error("Error:", error))
      .then(response => {
        let newState = Object.assign({}, this.state);
        newState.input.guess = "";
        newState.can_submit = false;
        this.setState(newState);
      });
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
