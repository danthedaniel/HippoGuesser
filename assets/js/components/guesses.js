import { h, Component } from 'preact';

export default class Guesses extends Component {
  constructor(props) {
    super(props);
  }

  render(props, state) {
    return (
      <ul class="list-group">
        {
          props.data.sort().map(guess => {
            return (
              <li class="list-group-item">
                <button type="button" class="btn btn-secondary">
                  { guess.user } <span class="badge badge-light">0</span>
                </button>
                { guess.time }
              </li>
            );
          })
        }
      </ul>
    );
  }
}
