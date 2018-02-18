import { h, Component } from 'preact';
import 'twitch-embed';

export default class TwitchVideoEmbed extends Component {
  constructor(props) {
    super(props);
    this.player = null;
    this.state = {
      id: null
    };
  }

  componentWillMount() {
    this.setId();
  }

  componentDidMount() {
    this.setPlayer();
  }

  componentDidUpdate() {
    this.setPlayer();
  }

  componentWillReceiveProps(nextProps) {
    this.setId();
    this.setPlayer();
  }

  setId() {
    if (!this.state.id) {
      if (this.props.channel) {
        this.channel = true;
        this.setState({
          id: `twitch-${this.props.channel}`
        });
      }
    }
  }

  setPlayer() {
    if (!this.player) {
      let options = {
        width: "100%",
        height: "500px",
        theme: "dark",
        chat: "default"
      };
      if (this.channel) {
        options.channel = this.props.channel;
      }
      if (typeof window !== 'undefined' && window.Twitch) {
        this.player = new window.Twitch.Player(this.state.id, options);
      }
    }
  }

  render(props, state) {
    return (
      <div id={state.id || ''} className="twitch-video-embed"></div>
    );
  }
}
