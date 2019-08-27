module.exports = paginatePlugin

const iterator = require('./iterator')
const paginate = require('./paginate')

function paginatePlugin (octokit) {
  octokit.paginate = paginate.bind(null, octokit)
  octokit.paginate.iterator = iterator.bind(null, octokit)
}
