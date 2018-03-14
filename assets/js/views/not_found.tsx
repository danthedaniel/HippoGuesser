import { h, Component } from 'preact';

export default class NotFoundView extends Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  render(props: {}, state, {}) {
    return (
      <div class="row">
        <div class="col">
          <div class="jumbotron bg-dark">
            <h1 class="display-4">Page not found</h1>
            <p class="lead">Please navigate to another page.</p>
          </div>
        </div>
      </div>
    );
  }
}
