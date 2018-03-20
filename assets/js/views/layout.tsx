import { h } from 'preact';
import { Route, Switch } from 'react-router-dom';
import Navbar from '../components/navbar';
import Flash from '../components/flash';

import GuessView from './guessing';
import LeaderboardView from './leaderboards';
import NotFoundView from './not_found';

import api from '../api';
import storage from '../storage';
import StateComponent from '../component';

interface Cookies { [key: string]: string }
const cookies: Cookies = document
  .cookie
  .split("; ")
  .map(cookie => cookie.split("="))
  .reduce((acc, x) => Object.assign(acc, {[x[0]]: x[1]}), {});

export default class Layout extends StateComponent<{}, storage.LayoutState> {
  /**
   * The alert container ref.
   */
  flash: Flash;

  constructor(props) {
    super(props);
    this.flash = null;
  }

  setFlash(ref: Flash) {
    if (!this.flash) {
      this.flash = ref;
      this.forceUpdate();
    }
  }

  componentDidMount() {
    api.authorize(cookies.twitch_token);
    if (api.authorized()) {
      api.get_me().then(user => {
        const moderator = ["admin", "mod"].indexOf(user.role) !== -1;
        this.setState({username: user.name, moderator});
      });
    } else {
      this.setState({username: "", moderator: false});
    }
  }

  render(props: {}, state: storage.LayoutState) {
    return (
      <div class="container">
        <Flash ref={this.setFlash.bind(this)} />
        <div class="row">
          <div class="col">
            <Navbar username={state.username} />
          </div>
        </div>
        <Switch>
          <Route exact path="/" render={() => (<GuessView flash={this.flash} {...state} />)} />
          <Route exact path="/leaderboards" component={LeaderboardView} />
          <Route component={NotFoundView} />
        </Switch>
      </div>
    );
  }
}
