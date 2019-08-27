const { request } = require('@octokit/request')
const getUserAgent = require('universal-user-agent')

const version = require('./package.json').version
const userAgent = `octokit-graphql.js/${version} ${getUserAgent()}`

const withDefaults = require('./lib/with-defaults')

module.exports = withDefaults(request, {
  method: 'POST',
  url: '/graphql',
  headers: {
    'user-agent': userAgent
  }
})
