import api from './api';

namespace storage {
  const data_store = window.sessionStorage;

  /**
   * Remove any types that aren't JSON compatible.
   */
  const serializer = (key: string, val: any) => {
    if (val === null)
      return val;

    const type = Object.getPrototypeOf(val).constructor.name;
    const shouldSerialize = val => {
      const whitelist = ["Array", "Number", "Boolean", "Object", "Array", "String"];
      return whitelist.indexOf(type) !== -1;
    };

    if (type === "Array") {
      return (<any[]> val).filter(shouldSerialize);
    } else if (shouldSerialize(val)) {
      return val;
    }
  };

  /**
   * Get the state object for a view.
   *
   * @param view_class The name of the class for the view (e.g.: GuessView).
   */
  export const getState = <T>(view_class: string): T => {
    if (data_store.getItem(view_class)) {
      const from_store = JSON.parse(data_store.getItem(view_class));
      return Object.assign(from_store, defaults[view_class]);
    } else {
      return resetState(view_class);
    }
  };

  /**
   * Reset the state object for a view to the default.
   *
   * @param view_class The name of the class for the view (e.g.: GuessView).
   */
  export const resetState = <T>(view_class: string) => {
    data_store.setItem(view_class, JSON.stringify(defaults[view_class], serializer));
    return defaults[view_class] as T;
  };

  /**
   * Set the state object for a view.
   *
   * @param view_class The name of the class for the view (e.g.: GuessView).
   * @param state      The value of the state.
   */
  export const setState = (view_class: string, state) => {
    data_store.setItem(view_class, JSON.stringify(state, serializer));
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
    flash: null
  };

  const defaults = {
    LeaderboardView: LeaderboardStateDefault,
    GuessView: GuessStateDefault,
    Layout: LayoutStateDefault
  };
}

export default storage;
