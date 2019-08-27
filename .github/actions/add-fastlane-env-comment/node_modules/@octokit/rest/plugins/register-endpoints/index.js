module.exports = octokitRegisterEndpoints

const registerEndpoints = require('./register-endpoints')

function octokitRegisterEndpoints (octokit) {
  octokit.registerEndpoints = registerEndpoints.bind(null, octokit)
}
