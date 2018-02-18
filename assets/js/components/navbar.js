import { h, Component } from 'preact';

export default class NavBar extends Component {
  constructor(props) {
    super(props);

    this.options = [
      "Guess!",
      "Leaderboards"
    ]
  }

  logInButton() {
    if (this.props.username) {
      return (
        <div>
          <span class="btn my-2 my-sm-0 disabled">{ this.props.username }</span>
          <a
            href="/auth/logout"
            class="btn btn-outline-danger my-2 my-sm-0">
            Log Out
          </a>
        </div>
      );
    } else {
      return (
        <a
          href="/auth/twitch"
          class="btn btn-outline-success my-2 my-sm-0">
          Log In
        </a>
      );
    }
  }

  render(props, state) {
    return (
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <a class="navbar-brand" href="#">Hippo Guesser</a>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav mr-auto">
            {
              this.options.map(label => {
                const item_class = label === props.active ? "active" : "";
                return (
                  <li class={`nav-item ${item_class}`}>
                    <a class="nav-link" href="#">{ label }</a>
                  </li>
                );
              })
            }
          </ul>
          <form class="form-inline my-2 my-lg-0">
            { this.logInButton() }
          </form>
        </div>
      </nav>
    );
  }
}
