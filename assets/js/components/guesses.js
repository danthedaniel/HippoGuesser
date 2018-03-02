import { h, Component } from 'preact';

const guessToSec = (guess) => {
  const parts = /(\d+):(\d\d.\d\d)/.exec(guess);
  return parseInt(parts[0]) * 60 + parseFloat(parts[1]);
};

export default class Guesses extends Component {
  constructor(props) {
    super(props);
  }

  guessSort(a, b) {
    return guessToSec(a.value) - guessToSec(b.value);
  }

  render(props, state) {
    return (
      <ul class="list-group">
        {
          props.guesses.sort(this.guessSort).map(guess => {
            const correct_guess = guess.value === props.correct;
            const item_class = correct_guess ? "active" : "";
            return (
              <li class={`list-group-item bg-dark ${item_class}`}>
                <div class="row">
                  <div class="col">
                    { guess.user } { guess.user_score }
                  </div>
                  <div class="col">
                    <span class="float-right">
                      { correct_guess && "Winner! " }
                      <kbd>{ guess.value }</kbd>
                    </span>
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
