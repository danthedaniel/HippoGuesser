import { h, Component } from 'preact';
import TwitchVideoEmbed from '../components/twitch/embed';
import Flash from '../components/flash';
import Guesses, { Guess } from '../components/guesses';
import Guesser from '../components/guesser';
import Controls from '../components/controls';
import { Socket } from 'phoenix';

declare var fetch: (url: string, options: any) => Promise<any>;

interface SocketMsg {
  guesses: Guess[],
  state: "in_progress" | "completed" | "closed",
  winner: string,
  correct: string
}

interface Channel {
  join: () => any,
  leave: () => any,
  on: (event: string, callback: (frame: Guess | SocketMsg) => any) => undefined
}

interface Socket {
  connect: () => undefined,
  disconnect: () => undefined,
  channel: (channel: string) => Channel
}

interface GuessProps {
  flash: Flash,
  username: string,
  moderator: boolean
}

interface GuessState {
  guesses: Guess[],
  can_submit: boolean,
  game_state: null | "in_progress" | "completed" | "closed",
  correct: null | string,
  input: {
    guess: string
  }
}

export default class GuessView extends Component<GuessProps, GuessState> {
  channel: Channel;
  socket: Socket;

  constructor(props) {
    super(props);
    this.state = {
      guesses: [],
      can_submit: false,
      game_state: null,
      correct: null,
      input: {
        guess: ""
      }
    };
  }

  componentDidMount() {
    this.connectSocket();
  }

  componentWillUnmount() {
    this.channel.leave();
    this.socket.disconnect();
  }

  getSubmitStatus() {
    fetch("/api/can_submit",
      {
        method: "GET",
        credentials: "same-origin"
      })
      .catch(error => console.error("Error:", error))
      .then(response => response.json())
      .then(response => {
        let newState = Object.assign({}, this.state);
        newState.can_submit = response.can_submit;
        this.setState(newState);
      });
  }

  connectSocket() {
    this.socket = new Socket("/socket");
    this.socket.connect();

    this.channel = this.socket.channel("room:lobby");
    this.channel.join()
      .receive("ok", msg => this.gameState(msg))
      .receive("error", msg => this.props.flash.danger("Could not connect to guess channel."));
    this.channel.on("state", this.gameState.bind(this));
    this.channel.on("guess", this.gameGuess.bind(this));
  }

  gameGuess(guess: Guess) {
    let newState = Object.assign({}, this.state);
    newState.guesses.push(guess);
    this.setState(newState);
  }

  gameState(msg: SocketMsg) {
    let newState = Object.assign({}, this.state);
    newState.game_state = msg.state;
    if (msg.guesses) {
      newState.guesses = msg.guesses;
    }
    if (msg.winner) {
      this.props.flash.success(`${msg.winner} has guessed correctly with ${msg.correct}!`);
    }
    if (msg.correct) {
      newState.correct = msg.correct;
    }
    if (msg.state === "in_progress") {
      this.getSubmitStatus();
      newState.correct = null;
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

  render(props: GuessProps, state: GuessState) {
    return (
      <div>
        <div class="row">
          <div class="col-xs-12 col-md-12 col-lg-8">
            <TwitchVideoEmbed channel="summoningsalt" />
          </div>
          <div class="col-xs-12 col-md-12 col-lg-4">
            <div class="row">
              <div class="col">
                { !props.username &&
                  <div class="alert alert-info" role="alert">
                    Please log in to participate.
                  </div> }
                { props.username && <Guesser
                  submit={this.submitGuess.bind(this)}
                  update={this.setInput.bind(this, "guess")}
                  value={state.input.guess}
                  flash={props.flash}
                  disabled={!this.state.can_submit} /> }
                { props.username && props.moderator && <Controls
                    state={state.game_state} /> }
                <Guesses guesses={state.guesses} correct={state.correct} />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
