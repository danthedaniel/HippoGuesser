import { h, Component } from 'preact';

const onlyUnique = (value: any, index: number, self: any[]) => {
  return self.indexOf(value) === index;
}

interface FlashMsg {
  classes: string,
  text: string
}

interface FlashState {
  flashes: FlashMsg[]
}

export default class Flash extends Component<{}, FlashState> {
  constructor(props) {
    super(props);
    this.state = {
      flashes: []
    };
  }

  success(text: string) {
    this.addFlash({classes: 'alert-success', text: text});
  }

  info(text: string) {
    this.addFlash({classes: 'alert-info', text: text});
  }

  danger(text: string) {
    this.addFlash({classes: 'alert-danger', text: text});
  }

  addFlash(flash: FlashMsg) {
    let flashes = this.state.flashes
      .concat([flash])
      .filter(onlyUnique);
    setTimeout(this.removeFlash.bind(this, flash), 8000);
    this.setState({flashes});
  }

  removeFlash(flash: FlashMsg) {
    let index = this.state.flashes.indexOf(flash);
    if (index !== -1) {
      let flashes = Object.assign({}, this.state).flashes;
      flashes.splice(index, 1);
      this.setState({flashes});
    }
  }

  render(props: {}, state: FlashState) {
    return (
      <div class="alert-container">
        {
          state.flashes.map(flash => {
            return (
              <div
                class={`alert alert-clickable alert-animate ${flash.classes}`}
                role="alert"
                onClick={() => this.removeFlash(flash)}>
                { flash.text }
              </div>
            );
          })
        }
      </div>
    );
  }
}
