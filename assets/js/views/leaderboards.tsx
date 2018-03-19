import { h, Component } from 'preact';
import api from '../api';

interface LeaderboardState {
  leaderboard: api.BoardEntry[]
}

export default class LeaderboardView extends Component<{}, LeaderboardState> {
  constructor(props) {
    super(props);

    this.state = {
      leaderboard: []
    };
  }

  componentDidMount() {
    api.leaderboard().then(leaderboard => this.setState({leaderboard}));
  }

  render(props: {}, state: LeaderboardState) {
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
