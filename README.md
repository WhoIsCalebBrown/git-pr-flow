# Git PR Flow

Git PR Flow turns the habit of committing directly on `main` into a complete,
CI-gated pull request workflow at the moment you run `git push`.

When a direct push targets the default branch of one of your standalone
personal GitHub repositories, the pre-push hook:

1. preserves every local commit on a `work/YYYYMMDD-description` branch;
2. pushes that branch instead;
3. opens a pull request using the first commit for its title and body;
4. waits for its CI checks and refuses to merge if any fail;
5. squash-merges the passing PR and removes the work branch; and
6. returns you to an up-to-date local default branch.

The attempted default-branch push is cancelled because the pull request
replaces it. No commit is lost.

### What it looks like

You keep using Git normally:

```text
$ git push
git-pr-flow: direct push to main detected; publishing 2 commit(s) as
work/20260917-improve-audio-routing instead.
git-pr-flow: created PR: https://github.com/you/project/pull/42
git-pr-flow: waiting for CI before squash-merging.
git-pr-flow: COMPLETE — CI passed and the PR was squash-merged.
git-pr-flow: local main is current; the work branch was removed.
```

Git reports the original push as cancelled because hooks cannot replace Git's
already-calculated destination ref. When the hook prints `COMPLETE`, the branch
push, PR, CI gate, squash merge, cleanup, and local synchronization succeeded.

If CI fails, merge is refused and the generated branch and PR remain available
for repair. The timeout defaults to 15 minutes. Advanced overrides are Git
configuration keys: `prflow.mergeTimeout`, `prflow.pollInterval`, and
`prflow.checkGrace`, all expressed in seconds.

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

## Why automatic squash merges?

The goal is useful project history without requiring the repository owner to
remember ceremony. CI remains the gate: passing work becomes one clean commit
on the default branch, while failures remain visible in an open PR for repair.

MIT licensed.
