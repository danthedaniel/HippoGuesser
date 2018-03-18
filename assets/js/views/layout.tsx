import { h, Component } from 'preact';
import { Route, Switch } from 'react-router-dom';
import Navbar from '../components/navbar';
import Flash from '../components/flash';

import GuessView from './guessing';
import LeaderboardView from './leaderboards';
import NotFoundView from './not_found';

interface Cookies { [key: string]: string }

interface LayoutState {
  username: string,

  /**
   * Whether the current user is a moderator or admin.
   */
  moderator: boolean,

  /**
   * The alert container ref.
   */
  flash: null | Flash
}

const cookies: Cookies = document
  .cookie
  .split("; ")
  .map(cookie => cookie.split("="))
  .reduce((acc, x) => Object.assign(acc, {[x[0]]: x[1]}), {});

export default class Layout extends Component<{}, LayoutState> {
  constructor(props) {
    super(props);
    this.state = {
      username: cookies["username"],
      moderator: ["mod", "admin"].indexOf(cookies["role"]) !== -1,
      flash: null
    };
  }

  setFlash(ref: Flash) {
    if (!this.state.flash) {
      this.setState({flash: ref});
    }
  }

  render(props: {}, state: LayoutState) {
    return (
      <div class="container">
        <Flash ref={this.setFlash.bind(this)} />
        <div class="row">
          <div class="col">
            <Navbar username={state.username} />
          </div>
        </div>
        <Switch>
          <Route exact path="/" render={() => (<GuessView {...state} />)} />
          <Route path="/leaderboards/" component={LeaderboardView} />
          <Route component={NotFoundView} />
        </Switch>
      </div>
    );
  }
}
