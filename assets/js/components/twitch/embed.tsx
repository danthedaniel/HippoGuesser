import { h, Component } from 'preact';
import 'twitch-embed';

declare var Twitch;

interface TwitchEmbedOptions {
  theme: string,
  chat: string,
  channel: string
}

interface EmbedProps {
  channel: string
}

interface EmbedState {
  id: null | string
}

export default class TwitchVideoEmbed extends Component<EmbedProps, EmbedState> {
  player: any;

  constructor(props) {
    super(props);
    this.player = null;
    this.state = {
      id: null
    };
  }

  componentWillMount() {
    this.setPlayer();
  }

  componentDidMount() {
    this.setPlayer();
  }

  componentDidUpdate() {
    this.setPlayer();
  }

  componentWillReceiveProps(nextProps: EmbedProps) {
    this.setPlayer();
  }

  setPlayer() {
    if (!this.state.id) {
      const id = `twitch-${this.props.channel}`;
      const options: TwitchEmbedOptions = {
        theme: "dark",
        chat: "default",
        channel: this.props.channel
      };
      this.setState({id});
      setTimeout(() => {
        this.player = new Twitch.Player(id, options)
      }, 200);
    }
  }

  render(props: EmbedProps, state: EmbedState) {
    return (
      <div id={state.id || ''} className="twitch-video-embed"></div>
    );
  }
}
