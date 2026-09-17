# Git PR Flow

Git PR Flow turns the habit of committing directly on `main` into a real pull
request workflow at the moment you run `git push`.

When a direct push targets the default branch of one of your standalone
personal GitHub repositories, the pre-push hook:

1. preserves every local commit on a `work/YYYYMMDD-description` branch;
2. pushes that branch instead;
3. opens a draft pull request using the first commit for its title and body;
4. leaves you on the work branch so later pushes update the same PR; and
5. restores your local default-branch pointer to the remote base.

The attempted default-branch push is cancelled. No commit is lost or rewritten.

## Safety boundary

Installation uses Git's conditional configuration. The hook is active only in
repositories whose remote URL is owned by the configured personal GitHub
account. It passes through without intervention for:

- repositories owned by another person or organization;
- forks, unless explicitly enabled;
- tags and feature branches;
- initial pushes with no base branch;
- `hehehehehe` and `neetcode-submissions`; and
- repositories containing `prflow.enabled=false` in local Git config.

Conventional repository hooks in `.git/hooks/pre-push` are run before Git PR
Flow. A repository-specific `core.hooksPath` takes precedence automatically.

## Install

```bash
git clone https://github.com/WhoIsCalebBrown/git-pr-flow.git
cd git-pr-flow
./install.sh
```

Requirements: Git 2.36 or newer and an authenticated GitHub CLI (`gh`).

## Commands

```bash
git pr-flow status
git pr-flow disable
git pr-flow enable       # also opts a fork in explicitly
git pr-flow automatic
git pr-flow drafts
```

Use `./uninstall.sh` to remove the conditional Git configuration and installed
hook. It does not touch repositories, commits, branches, or pull requests.

## Why draft pull requests?

The push proves the commits are ready to leave the laptop, but not necessarily
ready to merge. A draft PR gives CI and the eventual review a stable place
without pretending the work was reviewed. Convert it to ready when the change
is complete, then prefer a squash merge if the branch contains noisy checkpoint
commits.

MIT licensed.
