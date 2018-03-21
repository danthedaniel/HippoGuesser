import { h } from 'preact';
import { Route, Switch } from 'react-router-dom';
import Navbar from '../components/navbar';
import Flash from '../components/flash';

import GuessView from './guessing';
import LeaderboardView from './leaderboards';
import NotFoundView from './not_found';

import api from '../api';
import StoredComponent from 'stored-component';

interface Cookies { [key: string]: string }
const cookies: Cookies = document
  .cookie
  .split("; ")
  .map(cookie => cookie.split("="))
  .reduce((acc, x) => Object.assign(acc, {[x[0]]: x[1]}), {});

type StateType = typeof defaultState;
const defaultState = {
  username: "",
  moderator: false,
  flash: null as Flash
};

export default class Layout extends StoredComponent<{}, StateType> {
  constructor(props) {
    super(props, defaultState);
  }

  setFlash(ref: Flash) {
    if (!this.state.flash) {
      this.setState({flash: ref});
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
      this.defaultState();
    }
  }

  render(props: {}, state: StateType) {
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
          <Route exact path="/leaderboards" component={LeaderboardView} />
          <Route component={NotFoundView} />
        </Switch>
      </div>
    );
  }
}
