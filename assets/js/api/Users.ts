/** @module Users */
// Auto-generated, edits will be overwritten
import * as gateway from './gateway'
import { api } from './types';

/**
 * Get user leaderboards
 */
export function leaderboard(): Promise<api.Response<any>> {
  return gateway.request(leaderboardOperation)
}

/**
 * Get a user
 *
 * @param {number} id The id of the user.
 * @return {Promise<object>} Success
 */
export function get_user(id: number): Promise<api.Response<any>> {
  const parameters: api.OperationParamGroups = {
    path: {
      id
    }
  }
  return gateway.request(get_userOperation, parameters)
}

/**
 * Get whether the current user can submit a guess this round
 */
export function can_submit(): Promise<api.Response<any>> {
  return gateway.request(can_submitOperation)
}

const leaderboardOperation: api.OperationInfo = {
  path: '/leaderboard',
  method: 'get'
}

const get_userOperation: api.OperationInfo = {
  path: '/users/{id}',
  method: 'get'
}

const can_submitOperation: api.OperationInfo = {
  path: '/can_submit',
  method: 'get',
  security: [
    {
      id: 'cookieAuth'
    }
  ]
}
