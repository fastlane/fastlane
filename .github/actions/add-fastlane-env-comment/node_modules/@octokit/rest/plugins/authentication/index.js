module.exports = authenticationPlugin

const beforeRequest = require('./before-request')
const requestError = require('./request-error')
const validate = require('./validate')

function authenticationPlugin (octokit, options) {
  if (!options.auth) {
    return
  }

  validate(options.auth)

  const state = {
    octokit,
    auth: options.auth
  }

  octokit.hook.before('request', beforeRequest.bind(null, state))
  octokit.hook.error('request', requestError.bind(null, state))
}
