import { h } from 'preact';

import api from '../api';
import StoredComponent from 'stored-component';

type StateType = typeof defaultState;
const defaultState = {leaderboard: [] as api.BoardEntry[]};

export default class LeaderboardView extends StoredComponent<{}, StateType> {
  constructor(props) {
    super(props, defaultState);
  }

  componentDidMount() {
    api.leaderboard().then(leaderboard => this.setState({leaderboard}));
  }

  render(props: {}, state: StateType) {
    return (
      <div class="row">
        <div class="col">
          <ul class="list-group">
            {
              state.leaderboard.length === 0 &&
              <div class="alert alert-info" role="alert">
                No one has won yet!
              </div>
            }
            {
              state.leaderboard.map(entry => {
                return (
                  <li class="list-group-item bg-dark">
                    <div class="row">
                      <div class="col">
                        <a
                          class="font-light"
                          href={`https://twitch.tv/${entry.name}`}
                          target="_blank">
                          { entry.name }
                        </a>
                      </div>
                      <div class="col"></div>
                      <div class="col">Wins: { entry.count }</div>
                    </div>
                  </li>
                );
              })
            }
          </ul>
        </div>
      </div>
    );
  }
}
