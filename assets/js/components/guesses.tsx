import { h, Component } from 'preact';

export interface Guess {
  user: string,
  user_score: number,
  value: string
}

interface GuessesProps {
  guesses: Guess[],
  correct: string
}

const guessToSec = (guess: string): number => {
  const parts = /(\d+):(\d\d.\d\d)/.exec(guess);
  return parseInt(parts[1]) * 60 + parseFloat(parts[2]);
};

export default class Guesses extends Component<GuessesProps, {}> {
  constructor(props) {
    super(props);
  }

  guessSort(a: Guess, b: Guess) {
    return guessToSec(a.value) - guessToSec(b.value);
  }

  render(props: GuessesProps, state: {}) {
    return (
      <ul class="list-group">
        {
          props.guesses.sort(this.guessSort).map(guess => {
            const correct_guess = guess.value === props.correct;
            const item_class = correct_guess ? "winner" : "";

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
