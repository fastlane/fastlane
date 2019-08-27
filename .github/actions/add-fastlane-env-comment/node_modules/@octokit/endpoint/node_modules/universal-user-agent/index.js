module.exports = getUserAgentNode

const osName = require('os-name')

function getUserAgentNode () {
  try {
    return `Node.js/${process.version.substr(1)} (${osName()}; ${process.arch})`
  } catch (error) {
    if (/wmic os get Caption/.test(error.message)) {
      return 'Windows <version undetectable>'
    }

    throw error
  }
}
