import { h, Component } from 'preact';
import { Link } from 'react-router-dom';

interface NavOption {
  /**
   * Displayed text for a nav item.
   */
  label: string,

  /**
   * Link address for the nav item;
   */
  path: string
}

interface NavBarProps {
  /**
   * Username for the logged in user.
   */
  username?: string
}

interface NavBarState {
  /**
   * Whether the navbar is collapsed.
   */
  collapse: boolean
}

const options: NavOption[] = [
  {label: "Guess!", path: "/"},
  {label: "Leaderboards", path: "/leaderboards"}
]

export default class NavBar extends Component<NavBarProps, NavBarState> {
  constructor(props) {
    super(props);

    this.state = {
      collapse: true
    };
  }

  /**
   * Switch between an expanded and collapsed navbar. Only applies to the mobile
   * layout.
   */
  toggleCollapse() {
    this.setState({collapse: !this.state.collapse});
  }

  /**
   * Render a log in or log out button.
   *
   * @return A button element.
   */
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

  render(props: NavBarProps, state: NavBarState) {
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
              options.map(item => {
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
