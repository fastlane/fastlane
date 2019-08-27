# graphql.js

> GitHub GraphQL API client for browsers and Node

[![@latest](https://img.shields.io/npm/v/@octokit/graphql.svg)](https://www.npmjs.com/package/@octokit/graphql)
[![Build Status](https://travis-ci.com/octokit/graphql.js.svg?branch=master)](https://travis-ci.com/octokit/graphql.js)
[![Coverage Status](https://coveralls.io/repos/github/octokit/graphql.js/badge.svg)](https://coveralls.io/github/octokit/graphql.js)
[![Greenkeeper](https://badges.greenkeeper.io/octokit/graphql.js.svg)](https://greenkeeper.io/)

<!-- toc -->

- [Usage](#usage)
- [Errors](#errors)
- [Writing tests](#writing-tests)
- [License](#license)

<!-- tocstop -->

## Usage

Send a simple query

```js
const graphql = require('@octokit/graphql')
const { repository } = await graphql(`{
  repository(owner:"octokit", name:"graphql.js") {
    issues(last:3) {
      edges {
        node {
          title
        }
      }
    }
  }
}`, {
  headers: {
    authorization: `token secret123`
  }
})
```

⚠️ Do not use [template literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals) in the query strings as they make your code vulnerable to query injection attacks (see [#2](https://github.com/octokit/graphql.js/issues/2)). Use variables instead:

```js
const graphql = require('@octokit/graphql')
const { lastIssues } = await graphql(`query lastIssues($owner: String!, $repo: String!, $num: Int = 3) {
    repository(owner:$owner, name:$repo) {
      issues(last:$num) {
        edges {
          node {
            title
          }
        }
      }
    }
  }`, {
    owner: 'octokit',
    repo: 'graphql.js'
    headers: {
      authorization: `token secret123`
    }
  }
})
```

Create two new clients and set separate default configs for them.

```js
const graphql1 = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token secret123`
  }
})

const graphql2 = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token foobar`
  }
})
```

Create two clients, the second inherits config from the first.

```js
const graphql1 = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token secret123`
  }
})

const graphql2 = graphql1.defaults({
  headers: {
    'user-agent': 'my-user-agent/v1.2.3'
  }
})
```

Create a new client with default options and run query

```js
const graphql = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token secret123`
  }
})
const { repository } = await graphql(`{
  repository(owner:"octokit", name:"graphql.js") {
    issues(last:3) {
      edges {
        node {
          title
        }
      }
    }
  }
}`)
```

Pass query together with headers and variables

```js
const graphql = require('@octokit/graphql')
const { lastIssues } = await graphql({
  query: `query lastIssues($owner: String!, $repo: String!, $num: Int = 3) {
    repository(owner:$owner, name:$repo) {
      issues(last:$num) {
        edges {
          node {
            title
          }
        }
      }
    }
  }`,
  owner: 'octokit',
  repo: 'graphql.js'
  headers: {
    authorization: `token secret123`
  }
})
```

Use with GitHub Enterprise

```js
const graphql = require('@octokit/graphql').defaults({
  baseUrl: 'https://github-enterprise.acme-inc.com/api',
  headers: {
    authorization: `token secret123`
  }
})
const { repository } = await graphql(`{
  repository(owner:"acme-project", name:"acme-repo") {
    issues(last:3) {
      edges {
        node {
          title
        }
      }
    }
  }
}`)
```

## Errors

In case of a GraphQL error, `error.message` is set to the first error from the response’s `errors` array. All errors can be accessed at `error.errors`. `error.request` has the request options such as query, variables and headers set for easier debugging.

```js
const graphql = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token secret123`
  }
})
const query = `{
  viewer {
    bioHtml
  }
}`

try {
  const result = await graphql(query)
} catch (error) {
  // server responds with
  // {
  // 	"data": null,
  // 	"errors": [{
  // 		"message": "Field 'bioHtml' doesn't exist on type 'User'",
  // 		"locations": [{
  // 			"line": 3,
  // 			"column": 5
  // 		}]
  // 	}]
  // }

  console.log('Request failed:', error.request) // { query, variables: {}, headers: { authorization: 'token secret123' } }
  console.log(error.message) // Field 'bioHtml' doesn't exist on type 'User'
}
```

## Partial responses

A GraphQL query may respond with partial data accompanied by errors. In this case we will throw an error but the partial data will still be accessible through `error.data`

```js
const graphql = require('@octokit/graphql').defaults({
  headers: {
    authorization: `token secret123`
  }
})
const query = `{
  repository(name: "probot", owner: "probot") {
    name
    ref(qualifiedName: "master") {
      target {
        ... on Commit {
          history(first: 25, after: "invalid cursor") {
            nodes {
              message
            }
          }
        }
      }
    }
  }
}`

try {
  const result = await graphql(query)
} catch (error) {
  // server responds with
  // { 
  //   "data": { 
  //     "repository": { 
  //       "name": "probot", 
  //       "ref": null 
  //     } 
  //   }, 
  //   "errors": [ 
  //     { 
  //       "type": "INVALID_CURSOR_ARGUMENTS", 
  //       "path": [ 
  //         "repository", 
  //         "ref", 
  //         "target", 
  //         "history" 
  //       ], 
  //       "locations": [ 
  //         { 
  //           "line": 7, 
  //           "column": 11 
  //         } 
  //       ], 
  //       "message": "`invalid cursor` does not appear to be a valid cursor." 
  //     } 
  //   ] 
  // } 

  console.log('Request failed:', error.request) // { query, variables: {}, headers: { authorization: 'token secret123' } }
  console.log(error.message) // `invalid cursor` does not appear to be a valid cursor.
  console.log(error.data) // { repository: { name: 'probot', ref: null } }
}
```

## Writing tests

You can pass a replacement for [the built-in fetch implementation](https://github.com/bitinn/node-fetch) as `request.fetch` option. For example, using [fetch-mock](http://www.wheresrhys.co.uk/fetch-mock/) works great to write tests

```js
const assert = require('assert')
const fetchMock = require('fetch-mock/es5/server')

const graphql = require('@octokit/graphql')

graphql('{ viewer { login } }', {
  headers: {
    authorization: 'token secret123'
  },
  request: {
    fetch: fetchMock.sandbox()
      .post('https://api.github.com/graphql', (url, options) => {
        assert.strictEqual(options.headers.authorization, 'token secret123')
        assert.strictEqual(options.body, '{"query":"{ viewer { login } }"}', 'Sends correct query')
        return { data: {} }
      })
  }
})
```

## License

[MIT](LICENSE)
