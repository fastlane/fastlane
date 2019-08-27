"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const core = __importStar(require("@actions/core"));
const github = __importStar(require("@actions/github"));
function run() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const context = github.context;
            const isIssue = !!context.payload.issue;
            if (!isIssue) {
                console.log('The event that triggered this action was not an issue, exiting');
                return;
            }
            if (context.payload.action !== 'opened') {
                console.log('No issue was opened, exiting');
                return;
            }
            const issueBody = context.payload.issue.body;
            if (issueBody == null) {
                console.log('The issue body is empty, exiting');
                return;
            }
            if (issueBody.includes('Loaded fastlane plugins')) {
                console.log('`fastlane env` was already provided, exiting');
                return;
            }
            if (issueBody.includes('### Feature Request')) {
                console.log('The issue is a feature request, exiting');
                return;
            }
            const issueMessage = core.getInput('issue-message');
            const repoToken = core.getInput('repo-token', { required: true });
            const issue = context.issue;
            const client = new github.GitHub(repoToken);
            console.log('posting a message');
            yield client.issues.createComment({
                owner: issue.owner,
                repo: issue.repo,
                issue_number: issue.number,
                body: issueMessage
            });
        }
        catch (error) {
            core.setFailed(error.message);
            return;
        }
    });
}
exports.run = run;
run();
