/** @module Rounds */
// Auto-generated, edits will be overwritten
import * as gateway from './gateway'
import { api } from './types';

/**
 * Get a round
 */
export function get_round(): Promise<api.Response<any>> {
  return gateway.request(get_roundOperation)
}

/**
 * Get the current round
 */
export function current_round(): Promise<api.Response<any>> {
  return gateway.request(current_roundOperation)
}

/**
 * Create a new guess.
 *
 * @param {string} value A guess formatted as 0:00.00
 * @return {Promise<object>} Success
 */
export function guess(value: string): Promise<api.Response<any>> {
  const parameters: api.OperationParamGroups = {
    query: {
      value
    }
  }
  return gateway.request(guessOperation, parameters)
}

/**
 * Update the current round's state.
 *
 * @param {string} state The state to change to.
 * @param {object} options Optional options
 * @param {string} [options.correct] The correct guess value formatted as 0:00.00
 * @return {Promise<object>} Success
 */
export function state_change(state: 'closed'|'in_progress'|'completed', options?: State_changeOptions): Promise<api.Response<any>> {
  if (!options) options = {}
  const parameters: api.OperationParamGroups = {
    path: {
      state
    },
    query: {
      correct: options.correct
    }
  }
  return gateway.request(state_changeOperation, parameters)
}

export interface State_changeOptions {
  /**
   * The correct guess value formatted as 0:00.00
   */
  correct?: string
}

const get_roundOperation: api.OperationInfo = {
  path: '/rounds/{id}',
  method: 'get'
}

const current_roundOperation: api.OperationInfo = {
  path: '/rounds/current',
  method: 'get'
}

const guessOperation: api.OperationInfo = {
  path: '/rounds/current/guess',
  method: 'post',
  security: [
    {
      id: 'cookieAuth'
    }
  ]
}

const state_changeOperation: api.OperationInfo = {
  path: '/rounds/current/change/{state}',
  method: 'patch',
  security: [
    {
      id: 'cookieAuth'
    }
  ]
}
