module.exports = octokitRestNormalizeGitReferenceResponses

const { RequestError } = require('@octokit/request-error')

function octokitRestNormalizeGitReferenceResponses (octokit) {
  octokit.hook.wrap('request', (request, options) => {
    const isGetOrListRefRequest = /\/repos\/:?\w+\/:?\w+\/git\/refs\/:?\w+/.test(options.url)

    if (!isGetOrListRefRequest) {
      return request(options)
    }

    const isGetRefRequest = 'ref' in options

    return request(options)
      .then(response => {
        // request single reference
        if (isGetRefRequest) {
          if (Array.isArray(response.data)) {
            throw new RequestError(`More than one reference found for "${options.ref}"`, 404, {
              request: options
            })
          }

          // ✅ received single reference
          return response
        }

        // request list of references
        if (!Array.isArray(response.data)) {
          response.data = [response.data]
        }

        return response
      })

      .catch(error => {
        if (isGetRefRequest) {
          throw error
        }

        if (error.status === 404) {
          return {
            status: 200,
            headers: error.headers,
            data: []
          }
        }

        throw error
      })
  })
}
