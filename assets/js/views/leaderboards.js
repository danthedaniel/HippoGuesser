import { h, Component } from 'preact';

export default class LeaderboardView extends Component {
  constructor(props) {
    super(props);

    this.state = {
      leaderboard: []
    };
  }

  componentDidMount() {
    this.getLeaderboard();
  }

  getLeaderboard() {
    fetch("/api/leaderboard",
      {
        method: "GET",
        credentials: "same-origin"
      })
      .catch(error => console.error("Error: ", error))
      .then(response => response.json())
      .then(response => {
        let newState = Object.assign({}, this.state);
        newState.leaderboard = response;
        this.setState(newState);
      });
  }

  render(props, state) {
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
