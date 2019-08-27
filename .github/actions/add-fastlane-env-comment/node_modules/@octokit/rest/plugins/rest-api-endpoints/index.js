module.exports = octokitRestApiEndpoints

const ROUTES = require('./routes.json')

function octokitRestApiEndpoints (octokit) {
  // Aliasing scopes for backward compatibility
  // See https://github.com/octokit/rest.js/pull/1134
  ROUTES.gitdata = ROUTES.git
  ROUTES.authorization = ROUTES.oauthAuthorizations
  ROUTES.pullRequests = ROUTES.pulls

  octokit.registerEndpoints(ROUTES)
}
