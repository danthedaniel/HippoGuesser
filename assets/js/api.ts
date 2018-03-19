import { ajax } from 'noquery-ajax';

namespace api {
  const ROOT_PATH = "/api";
  const ROUTES = {
    state_change: (type: State) => `/rounds/current/change/${type}`,
    guess: "/rounds/current/guess",
    can_submit: "/can_submit",
    leaderboard: "/leaderboard",
    get_round: (id: number) => `/rounds/${id}`
  };

  type Method = "GET" | "POST" | "PATCH" | "DELETE" | "HEAD";

  /**
   * Create a Promise for an XHR.
   *
   * @template T   Return type for a successful request.
   *
   * @param path   The path to send the XHR to. Will have ROOT_PATH prepended.
   * @param method HTTP method to use.
   * @param data   Query or POST parameters.
   */
  const ajax_promise = <T>(path: string, method?: Method, data?: object) => {
    return new Promise<T>((resolve, reject) => ajax({
      url: ROOT_PATH + path,
      method: method,
      data: data,
      success: (data: T) => resolve(data),
      error: xhr => reject(xhr)
    }));
  }

  /**
   * Make a state change to the current round.
   *
   * @param type    The new desired state.
   * @param correct (optional) If moving to "closed", this is the winning guess.
   */
  export const state_change = (type: State, correct?: string) => {
    return ajax_promise<Round>(ROUTES.state_change(type), "PATCH", {correct});
  }

  /**
   * Submit a guess.
   *
   * @param value The guess (formatted as 0:00.00).
   */
  export const guess = (value: string) => {
    return ajax_promise<Round>(ROUTES.guess, "POST", {value});
  }

  /**
   * Whether the current user can make a guess.
   */
  export const can_submit = () => {
    return ajax_promise<{can_submit: boolean}>(ROUTES.can_submit);
  }

  /**
   * Get the leaderboard.
   */
  export const leaderboard = () => {
    return ajax_promise<BoardEntry[]>(ROUTES.leaderboard);
  }

  /**
   * Get a Round.
   */
  export const get_round = (id: number) => {
    return ajax_promise<Round>(ROUTES.get_round(id));
  }

  /**
   * The game state.
   */
  export type State = "in_progress" | "completed" | "closed";

  /**
   * An entry on the leaderboard.
   */
  export interface BoardEntry {
    name: string,
    count: number
  }

  export interface Round {
    id: number,
    state: State
  }

  export interface User {
    id: number,
    name: string,
    wins: number
  }

  export interface Guess {
    user: string,
    user_score: number,
    value: string
  }
}

export default api;
