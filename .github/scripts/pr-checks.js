const COMMENT_HEADER = '### ⚠️ PR Lint Warnings';
const BOT_LOGIN = 'github-actions[bot]';
const BIG_PR_LINE_COUNT = 500;
const MIN_BODY_LENGTH = 5;
const VERSIONED_HELPER_FILES = [
  'snapshot/lib/assets/SnapshotHelper.swift',
  'snapshot/lib/assets/SnapshotHelperXcode8.swift'
];

/**
 * Collects every warning that applies to the pull request.
 *
 * @param {object} github Authenticated Octokit client provided by actions/github-script.
 * @param {object} context Workflow run context provided by actions/github-script.
 * @returns {Promise<string[]>}
 */
async function collectWarnings(github, context) {
  const owner = context.repo.owner;
  const repo = context.repo.repo;
  const pr = context.payload.pull_request;
  const prNumber = pr.number;

  const warnings = [];

  // The webhook payload doesn't carry line counts, so ask for the full pull request.
  const { data: fullPR } = await github.rest.pulls.get({ owner, repo, pull_number: prNumber });
  const changedLines = (fullPR.additions ?? 0) + (fullPR.deletions ?? 0);
  if (changedLines > BIG_PR_LINE_COUNT) {
    warnings.push('Big PR');
  }

  const title = (pr.title || '').toUpperCase();
  const body = (pr.body || '').toUpperCase();
  if ((title + body).includes('WIP')) {
    warnings.push('Pull Request is Work in Progress');
  }

  if ((pr.body || '').trim().length < MIN_BODY_LENGTH) {
    warnings.push(`Please provide a changelog summary in the Pull Request description @${pr.user.login}`);
  }

  const files = await github.paginate(github.rest.pulls.listFiles, {
    owner,
    repo,
    pull_number: prNumber,
    per_page: 100
  });
  const filenames = new Set(files.map(file => file.filename));

  for (const helper of VERSIONED_HELPER_FILES) {
    if (filenames.has(helper)) {
      const name = helper.split('/').pop();
      warnings.push(`You modified \`${name}\`, make sure to update the version number at the bottom of the file to notify users about the new helper file.`);
    }
  }

  // PRs made from a branch owned by somebody else should allow maintainers to push to it.
  if (pr.maintainer_can_modify === false && pr.head.repo.owner.login !== pr.base.repo.owner.login) {
    warnings.push(
      'If you would allow the maintainers access to make changes to your branch that would be 💯 ' +
      'This allows maintainers to help move pull requests through quicker if there are any changes that they can help with 😊 ' +
      'See more info at https://help.github.com/en/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork'
    );
  }

  return warnings;
}

/**
 * Deletes the warnings comment left by earlier runs of this workflow, so the pull
 * request only ever shows the warnings that still apply.
 *
 * @param {object} github Authenticated Octokit client provided by actions/github-script.
 * @param {object} context Workflow run context provided by actions/github-script.
 * @returns {Promise<void>}
 */
async function deletePreviousComments(github, context) {
  const owner = context.repo.owner;
  const repo = context.repo.repo;
  const prNumber = context.payload.pull_request.number;

  const comments = await github.paginate(github.rest.issues.listComments, {
    owner,
    repo,
    issue_number: prNumber,
    per_page: 100
  });

  for (const comment of comments) {
    const isOurs = typeof comment.body === 'string' && comment.body.startsWith(COMMENT_HEADER);
    if (isOurs && comment.user && comment.user.login === BOT_LOGIN) {
      await github.rest.issues.deleteComment({ owner, repo, comment_id: comment.id });
    }
  }
}

/**
 * Runs every check and leaves a single aggregated comment when something needs attention.
 *
 * @param {{ github: object, context: object }} params actions/github-script globals.
 * @returns {Promise<void>}
 */
module.exports = async ({ github, context }) => {
  const warnings = await collectWarnings(github, context);

  await deletePreviousComments(github, context);

  if (warnings.length === 0) {
    return;
  }

  await github.rest.issues.createComment({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.payload.pull_request.number,
    body: [COMMENT_HEADER, '', ...warnings.map(warning => `- ${warning}`)].join('\n')
  });
};
