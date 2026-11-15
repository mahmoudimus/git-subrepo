# git-subrepo (mahmoudimus fork)

> **I recommend [Copybara](https://github.com/google/copybara) instead of git-subrepo** for syncing a monorepo directory with a separate repository. git-subrepo doesn't handle:
>
> * **Squash-merged pull requests.** git-subrepo records the last synced upstream commit by SHA in `.gitrepo`. A squash merge creates a new commit that isn't descended from the one you pushed, so the next `pull` fails with `Local repository does not contain <sha>`. You have to re-anchor `.gitrepo` by hand after every merge. Copybara puts the source commit in a label in the commit message (for example `GitOrigin-RevId:`), and the label survives the squash.
> * **Protected branches.** When the upstream default branch requires pull requests, signed commits and passing checks, `git subrepo push` can only push to a side branch. It can't open or update the PR, and the commits it writes aren't signed. Copybara's `git.github_pr_destination` opens and updates the PR itself.
> * **Files that must differ between the two repos.** git-subrepo copies the directory byte for byte. A monorepo build file (for example a Maven `pom.xml` whose parent is the monorepo root) can't build upstream, so the PR fails its checks. Copybara moves, renames and rewrites files on export (`core.move`, `core.replace`) and reverses them on import.
>
> It's also built on `git filter-branch`, which git itself now warns against using, plus temporary worktrees that can be left behind and block the next command (`There is already a worktree with branch subrepo/...`).
>
> A blog post on moving from git-subrepo to Copybara is coming soon on [mahmoudimus.com](https://mahmoudimus.com).

If you still want git-subrepo, this fork is current with [ingydotnet/git-subrepo](https://github.com/ingydotnet/git-subrepo) `master` as of 2026-02-05 (`5e0f401`, version 0.4.9) and passes all 360 tests in the project's suite. The full documentation is in [ReadMe.pod](ReadMe.pod).

## What this fork changes

Each item is a commit (or a merged PR) on the `fork` branch that isn't in upstream.

### Bugs fixed

* `push` straight after `subrepo commit` no longer dies with `cd: null directory`. The branch `commit` leaves behind made `push` skip setting its worktree path. Upstream 0.4.9 still has this bug.
* `push` starts the subrepo branch from the most recent `subrepo.commit`, not the one recorded at the first commit in the range. When a push crossed other parent commits, the old behaviour dropped already-pushed upstream commits from the branch, and the rebase then conflicted. (TransFICC, #8)
* With `--method rebase`, the first commit of that branch got its parent as one word (`-p <sha>`), so `git commit-tree` failed with `not a valid object name` before push fell back. Test: `test/push-rebase-method.t`.
* `reclone --branch` writes the new branch to `.gitrepo` again.
* `status` handles subrepos whose paths share a prefix (upstream issue #534).
* The `-u`/`--update` option works as documented. (Kai)

### Behaviour changes

* `push` doesn't rewrite `.gitrepo` unless you pass `-u`. It also works out a default branch name for the push.
* `.gitrepo` is stripped from the subrepo branch with `git filter-branch --index-filter`, which is much faster than `--tree-filter` on large trees, still limited to first-parent commits as upstream does.
* Nested subrepos (#1).
* Messages name the branch they're about, and errors say why a command may have failed and warn when a `subrepo/<name>` branch already exists. The internal `error` function takes several arguments.

### Tests

* The suite passes when `init.defaultBranch` isn't `master`, and when you have a global `.gitignore`. (Michael Tedder)
* The `status` tests no longer depend on the repository they run in.
* `test/push-nested.t` actually tests nested pushes, and the suite passes on macOS with Homebrew bash.

## Merging this fork

The fork's open PRs from 2022 were checked against upstream on 2026-11-15:

* #11 (default branch in tests) and #12 (`git add --force` in tests) are already in upstream.
* #8 (push edge case) is merged here, together with the `-p` quoting fix above.

## Running the tests

```
make test
```

You need bash 4 or later. On macOS, install it with Homebrew.
