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
      .catch(error => console.error("Error:", error))
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
          <h4 style="margin: 0 auto">Leaderboards</h4>
          <ul class="list-group">
            {
              state.leaderboard.map(entry => {
                return (
                  <li class="list-group-item bg-dark">
                    <div class="row">
                      <div class="col">{ entry.name }</div>
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
