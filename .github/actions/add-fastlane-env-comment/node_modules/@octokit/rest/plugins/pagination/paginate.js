module.exports = paginate

const iterator = require('./iterator')

function paginate (octokit, route, options, mapFn) {
  if (typeof options === 'function') {
    mapFn = options
    options = undefined
  }
  options = octokit.request.endpoint.merge(route, options)
  return gather(octokit, [], iterator(octokit, options)[Symbol.asyncIterator](), mapFn)
}

function gather (octokit, results, iterator, mapFn) {
  return iterator.next()
    .then(result => {
      if (result.done) {
        return results
      }

      let earlyExit = false
      function done () {
        earlyExit = true
      }

      results = results.concat(mapFn ? mapFn(result.value, done) : result.value.data)

      if (earlyExit) {
        return results
      }

      return gather(octokit, results, iterator, mapFn)
    })
}
