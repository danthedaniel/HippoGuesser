import { h, Component } from 'preact';

const guessToSec = (guess) => {
  const parts = /(\d+):(\d\d.\d\d)/.exec(guess);
  return parseInt(parts[1]) * 60 + parseFloat(parts[2]);
};

export default class Guesses extends Component {
  constructor(props) {
    super(props);
  }

  guessSort(a, b) {
    return guessToSec(a.time) - guessToSec(b.time);
  }

  render(props, state) {
    return (
      <ul class="list-group">
        {
          props.guesses.sort(this.guessSort).map(guess => {
            return (
              <li class="list-group-item bg-dark">
                <div class="row">
                  <div class="col">
                    { guess.user }
                  </div>
                  <div class="col">
                    { 0 }
                  </div>
                  <div class="col">
                    <kbd>{ guess.time }</kbd>
                  </div>
                </div>
              </li>
            );
          })
        }
      </ul>
    );
  }
}
