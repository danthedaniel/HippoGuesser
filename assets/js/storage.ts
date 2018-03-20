import api from './api';

namespace storage {
  let defaults: {[name: string]: any} = {};
  const data_store = window.sessionStorage;

  const className = (val): string => Object.getPrototypeOf(val).constructor.name;

  /**
   * Remove any types that aren't JSON compatible.
   */
  const serializer = (key: string, val: any) => {
    if (typeof val === 'undefined')
      return;
    if (val === null)
      return val;

    const shouldSerialize = val => {
      const whitelist = ["Array", "Number", "Boolean", "Object", "Array", "String"];
      return whitelist.indexOf(className(val)) !== -1;
    };

    if (className(val) === "Array") {
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
      return Object.assign(defaults[view_class], from_store);
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

  export const registerDefault = (view_class: string, def: any) => {
    defaults[view_class] = def;
  };
}

export default storage;
