/**
 * Some “list” response that can be paginated have a different response structure
 *
 * They have a `total_count` key in the response (search also has `incomplete_results`,
 * /installation/repositories also has `repository_selection`), as well as a key with
 * the list of the items which name varies from endpoint to endpoint:
 *
 * - https://developer.github.com/v3/search/#example (key `items`)
 * - https://developer.github.com/v3/checks/runs/#response-3 (key: `check_runs`)
 * - https://developer.github.com/v3/checks/suites/#response-1 (key: `check_suites`)
 * - https://developer.github.com/v3/apps/installations/#list-repositories (key: `repositories`)
 * - https://developer.github.com/v3/apps/installations/#list-installations-for-a-user (key `installations`)
 *
 * Octokit normalizes these responses so that paginated results are always returned following
 * the same structure. One challenge is that if the list response has only one page, no Link
 * header is provided, so this header alone is not sufficient to check wether a response is
 * paginated or not. For the exceptions with the namespace, a fallback check for the route
 * paths has to be added in order to normalize the response. We cannot check for the total_count
 * property because it also exists in the response of Get the combined status for a specific ref.
 */

module.exports = normalizePaginatedListResponse

const { Deprecation } = require('deprecation')
const once = require('once')

const deprecateIncompleteResults = once((log, deprecation) => log.warn(deprecation))
const deprecateTotalCount = once((log, deprecation) => log.warn(deprecation))
const deprecateNamespace = once((log, deprecation) => log.warn(deprecation))

const REGEX_IS_SEARCH_PATH = /^\/search\//
const REGEX_IS_CHECKS_PATH = /^\/repos\/[^/]+\/[^/]+\/commits\/[^/]+\/(check-runs|check-suites)/
const REGEX_IS_INSTALLATION_REPOSITORIES_PATH = /^\/installation\/repositories/
const REGEX_IS_USER_INSTALLATIONS_PATH = /^\/user\/installations/

function normalizePaginatedListResponse (octokit, url, response) {
  const path = url.replace(octokit.request.endpoint.DEFAULTS.baseUrl, '')
  if (
    !REGEX_IS_SEARCH_PATH.test(path) &&
    !REGEX_IS_CHECKS_PATH.test(path) &&
    !REGEX_IS_INSTALLATION_REPOSITORIES_PATH.test(path) &&
    !REGEX_IS_USER_INSTALLATIONS_PATH.test(path)
  ) {
    return
  }

  // keep the additional properties intact to avoid a breaking change,
  // but log a deprecation warning when accessed
  const incompleteResults = response.data.incomplete_results
  const repositorySelection = response.data.repository_selection
  const totalCount = response.data.total_count
  delete response.data.incomplete_results
  delete response.data.repository_selection
  delete response.data.total_count

  const namespaceKey = Object.keys(response.data)[0]

  response.data = response.data[namespaceKey]

  Object.defineProperty(response.data, namespaceKey, {
    get () {
      deprecateNamespace(octokit.log, new Deprecation(`[@octokit/rest] "result.data.${namespaceKey}" is deprecated. Use "result.data" instead`))
      return response.data
    }
  })

  if (typeof incompleteResults !== 'undefined') {
    Object.defineProperty(response.data, 'incomplete_results', {
      get () {
        deprecateIncompleteResults(octokit.log, new Deprecation('[@octokit/rest] "result.data.incomplete_results" is deprecated.'))
        return incompleteResults
      }
    })
  }

  if (typeof repositorySelection !== 'undefined') {
    Object.defineProperty(response.data, 'repository_selection', {
      get () {
        deprecateTotalCount(octokit.log, new Deprecation('[@octokit/rest] "result.data.repository_selection" is deprecated.'))
        return repositorySelection
      }
    })
  }

  Object.defineProperty(response.data, 'total_count', {
    get () {
      deprecateTotalCount(octokit.log, new Deprecation('[@octokit/rest] "result.data.total_count" is deprecated.'))
      return totalCount
    }
  })
}
