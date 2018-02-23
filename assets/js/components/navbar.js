import { h, Component } from 'preact';
import { Link } from 'react-router-dom';

export default class NavBar extends Component {
  constructor(props) {
    super(props);

    this.state = {
      collapse: true
    };

    this.options = [
      {label: "Guess!", path: "/"},
      {label: "Leaderboards", path: "/leaderboards/"}
    ]
  }

  toggleCollapse() {
    let newState = Object.assign({}, this.state);
    newState.collapse = !newState.collapse;
    this.setState(newState);
  }

  logInButton() {
    if (this.props.username) {
      return (
        <a
          href="/auth/logout"
          style="float: right;"
          class="btn btn-outline-danger my-2 my-sm-0">
          Log Out
        </a>
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
    const collapse = state.collapse ? "collapse" : "";
    return (
      <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <a class="navbar-brand" href="#">Hippo Guesser</a>
        <button
          class="navbar-toggler"
          type="button"
          onClick={this.toggleCollapse.bind(this)}
          aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class={`${collapse} navbar-collapse`} id="navbarSupportedContent">
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
            { props.username && <li class="nav-item">
              <a class="nav-link disabled">Welcome, { this.props.username }!</a>
            </li> }
          </ul>
          <form class="form-inline my-2 my-lg-0">
            { this.logInButton() }
          </form>
        </div>
      </nav>
    );
  }
}
