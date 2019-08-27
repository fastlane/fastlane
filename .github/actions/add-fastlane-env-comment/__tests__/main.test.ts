const path = require('path');
const nock = require('nock');

const validScenarios = [{
  response: 'issue.json'
}
];

const invalidScenarios = [{
  response: 'pull-request.json',
}, {
  response: 'action-closed.json',
}, {
  response: 'issue-missing-body.json',
}, {
  response: 'issue-contains-fastlane-env.json',
}, {
  response: 'issue-feature-request.json'
}
];

describe('action test suite', () => {
  for (const scenario of validScenarios) {
    it(`It posts a comment on an opened issue for (${scenario.response})`, async () => {
      const issueMessage = 'message';
      const repoToken = 'token';
      process.env['INPUT_ISSUE-MESSAGE'] = issueMessage;
      process.env['INPUT_REPO-TOKEN'] = repoToken;

      process.env['GITHUB_REPOSITORY'] = 'foo/bar';
      process.env['GITHUB_EVENT_PATH'] = path.join(__dirname, scenario.response);

      const api = nock('https://api.github.com')
        .persist()
        .post('/repos/foo/bar/issues/10/comments', '{\"body\":\"message\"}')
        .reply(200);

      const main = require('../src/main');
      await main.run();

      expect(api.isDone()).toBeTruthy();
    });
  }

  for (const scenario of invalidScenarios) {
    it(`It does not post a comment on an opened issue for (${scenario.response})`, async () => {
      const issueMessage = 'message';
      const repoToken = 'token';
      process.env['INPUT_ISSUE-MESSAGE'] = issueMessage;
      process.env['INPUT_REPO-TOKEN'] = repoToken;

      process.env['GITHUB_REPOSITORY'] = 'foo/bar';
      process.env['GITHUB_EVENT_PATH'] = path.join(__dirname, scenario.response);

      const api = nock('https://api.github.com')
        .persist()
        .post('/repos/foo/bar/issues/10/comments', '{\"body\":\"message\"}')
        .reply(200);

      const main = require('../src/main');
      await main.run();

      expect(api.isDone()).not.toBeTruthy();
    });
  }
});
