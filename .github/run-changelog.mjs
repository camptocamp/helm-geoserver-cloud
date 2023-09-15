import { Octokit } from '@octokit/action';

if (process.env.GITHUB_REF_TYPE == 'tag') {
    console.log('Run changelog');

    const octokit = new Octokit();

    await octokit.rest.repos.createDispatchEvent({
        owner: 'camptocamp',
        repo: 'helm-mutualize',
        event_type: 'changelog',
    });
}
