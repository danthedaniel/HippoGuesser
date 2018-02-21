import { h, Component } from 'preact';
import { Link } from 'react-router-dom';

export default class NavBar extends Component {
  constructor(props) {
    super(props);

    this.options = [
      {label: "Guess!", path: "/"},
      {label: "Leaderboards", path: "/leaderboards/"}
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
              this.options.map(item => {
                const is_current = item.path === document.location.pathname;
                const item_class = is_current ? "active" : "";
                return (
                  <li class={`nav-item ${item_class}`}>
                    <Link to={item.path} class="nav-link">
                      { item.label }
                    </Link>
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
