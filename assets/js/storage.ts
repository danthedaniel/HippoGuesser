import api from './api';

namespace storage {
  const dataStore = window.localStorage || window.sessionStorage;

  /**
   * Get the state object for a view.
   *
   * @param view_class The name of the class for the view (e.g.: GuessView).
   */
  export const getState = <T>(view_class: string) => {
    if (dataStore.getItem(view_class)) {
      return JSON.parse(dataStore.getItem(view_class)) as T;
    } else {
      dataStore.setItem(view_class, JSON.stringify(defaults[view_class]));
      return defaults[view_class] as T;
    }
  };

  /**
   * Set the state object for a view.
   *
   * @param view_class The name of the class for the view (e.g.: GuessView).
   * @param state      The value of the state.
   */
  export const setState = (view_class: string, state) => {
    dataStore.setItem(view_class, JSON.stringify(state));
  }

  export type GuessState = typeof GuessStateDefault;
  const GuessStateDefault = {
    guesses: [],
    can_submit: false,
    game_state: null,
    correct: null,
    input: {
      guess: ""
    }
  };

  export type LeaderboardState = typeof LeaderboardStateDefault;
  const LeaderboardStateDefault = {
    leaderboard: []
  };

  export type LayoutState = typeof LayoutStateDefault;
  const LayoutStateDefault = {
    username: "",
    moderator: false,
  };

  const defaults = {
    LeaderboardView: LeaderboardStateDefault,
    GuessView: GuessStateDefault,
    Layout: LayoutStateDefault
  };
}

export default storage;
