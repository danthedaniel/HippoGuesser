import { h, Component } from 'preact';

function onlyUnique(value, index, self) {
  return self.indexOf(value) === index;
}

export default class Flash extends Component {
  constructor(props) {
    super(props);
    this.state = {
      flashes: []
    };
  }

  success(text) {
    this.addFlash({classes: 'alert-success', text: text});
  }

  info(text) {
    this.addFlash({classes: 'alert-info', text: text});
  }

  danger(text) {
    this.addFlash({classes: 'alert-danger', text: text});
  }

  addFlash(flash) {
    let newState = Object.assign({}, this.state);
    newState.flashes = newState.flashes
      .concat([flash])
      .filter(onlyUnique);
    newState.flashes.forEach(flash => {
      setTimeout(this.removeFlash.bind(this, flash), 8000);
    });
    this.setState(newState);
  }

  removeFlash(flash) {
    let newState = Object.assign({}, this.state);
    var index = newState.flashes.indexOf(flash);
    if (index !== -1) newState.flashes.splice(index, 1);
    this.setState(newState);
  }

  render(props, state) {
    return (
      <div class="alert-container">
        {
          state.flashes.map(flash => {
            return (
              <div
                class={`alert alert-animate ${flash.classes}`}
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
