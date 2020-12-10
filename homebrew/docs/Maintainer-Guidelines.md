# Maintainer Guidelines

**This guide is for maintainers.** These special people have **write
access** to Homebrew’s repository and help merge the contributions of
others. You may find what is written here interesting, but it’s
definitely not a beginner’s guide.

Maybe you were looking for the [Formula Cookbook](Formula-Cookbook.md)?

This document is current practice. If you wish to change or discuss any of the below: open a PR to suggest a change.

## Mission

Homebrew aims to be the missing package manager for macOS (and Linux). Its primary goal is to be useful to as many people as possible, while remaining maintainable to a professional, high standard by a small group of volunteers. Where possible and sensible, it should seek to use features of macOS to blend in with the macOS and Apple ecosystems. On Linux and Windows, it should seek to be as self-contained as possible.

## Quick checklist

This is all that really matters:

- Ensure the name seems reasonable.
- Add aliases.
- Ensure it uses `keg_only :provided_by_macos` if it already comes with macOS.
- Ensure it is not a library that can be installed with
  [gem](https://en.wikipedia.org/wiki/RubyGems),
  [cpan](https://en.wikipedia.org/wiki/Cpan) or
  [pip](https://pip.pypa.io/en/stable/).
- Ensure that any dependencies are accurate and minimal. We don't need to
  support every possible optional feature for the software.
- Use the GitHub squash & merge workflow where bottles aren't required.
- Use `brew pr-publish` or `brew pr-pull` otherwise, which adds messages to auto-close pull requests and pull bottles built by the Brew Test Bot.
- Thank people for contributing.

Checking dependencies is important, because they will probably stick around
forever. Nobody really checks if they are necessary or not. Use the
`:optional` and `:recommended` modifiers as appropriate.

Depend on as little stuff as possible. Disable X11 functionality if possible.
For example, we build Wireshark, but not the heavy GUI.

For [some formulae](https://github.com/Homebrew/homebrew-core/search?q=%22homebrew%2Fmirror%22&unscoped_q=%22homebrew%2Fmirror%22),
we mirror the tarballs to our own BinTray automatically as part of the
bottle publish CI run.

Homebrew is about Unix software. Stuff that builds to an `.app` should
be in Homebrew Cask instead.

### Naming

The name is the strictest item, because avoiding a later name change is
desirable.

Choose a name that’s the most common name for the project.
For example, we initially chose `objective-caml` but we should have chosen `ocaml`.
Choose what people say to each other when talking about the project.

Add other names as aliases as symlinks in `Aliases` in the tap root. Ensure the
name referenced on the homepage is one of these, as it may be different and have
underscores and hyphens and so on.

We now accept versioned formulae as long as they [meet the requirements](Versions.md).

### Merging, rebasing, cherry-picking

Merging should be done in the `Homebrew/brew` repository to preserve history & GPG commit signing,
and squash/merge via GitHub should be used for formulae where those formulae
don't need bottles or the change does not require new bottles to be pulled.
Otherwise, you should use `brew pr-pull` (or `rebase`/`cherry-pick` contributions).

Don’t `rebase` until you finally `push`. Once `master` is pushed, you can’t
`rebase`: **you’re a maintainer now!**

Cherry-picking changes the date of the commit, which kind of sucks.

Don’t `merge` unclean branches. So if someone is still learning `git` and
their branch is filled with nonsensical merges, then `rebase` and squash
the commits. Our main branch history should be useful to other people,
not confusing.

Here’s a flowchart for managing a PR which is ready to merge:

![Flowchart for managing pull requests](assets/img/docs/managing-pull-requests.drawio.svg)

### Testing

We need to at least check that it builds. Use the [Brew Test Bot](Brew-Test-Bot.md) for this.

Verify the formula works if possible. If you can’t tell (e.g. if it’s a
library) trust the original contributor, it worked for them, so chances are it
is fine. If you aren’t an expert in the tool in question, you can’t really
gauge if the formula installed the program correctly. At some point an expert
will come along, cry blue murder that it doesn’t work, and fix it. This is how
open source works. Ideally, request a `test do` block to test that
functionality is consistently available.

If the formula uses a repository, then the `url` parameter should have a
tag or revision. `url`s have versions and are stable (not yet
implemented!).

Don't merge any formula updates with failing `brew test`s. If a `test do` block
is failing it needs to be fixed. This may involve replacing more involved tests
with those that are more reliable. This is fine: false positives are better than
false negatives as we don't want to teach maintainers to merge red PRs. If the
test failure is believed to be due to a bug in Homebrew/brew or the CI system,
that bug must be fixed, or worked around in the formula to yield a passing test,
before the PR can be merged.

## Common “gotchas”

1. [Ensure you have set your username and email address properly](https://help.github.com/articles/setting-your-email-in-git/)
2. Sign off cherry-picks if you amended them (use `git -s`)
3. If the commit fixes a bug, use “Fixes \#104” syntax to close the bug report and link to the commit

### Duplicates

We now accept stuff that comes with macOS as long as it uses `keg_only :provided_by_macos` to be keg-only by default.

### Add comments

It may be enough to refer to an issue ticket, but make sure changes are clear so that
if you came to them unaware of the surrounding issues they would make sense
to you. Many times on other projects I’ve seen code removed because the
new guy didn’t know why it was there. Regressions suck.

### Don’t allow bloated diffs

Amend a cherry-pick to remove commits that are only changes in
whitespace. They are not acceptable because our history is important and
`git blame` should be useful.

Whitespace corrections (to Ruby standard etc.) are allowed (in fact this
is a good opportunity to do it) provided the line itself has some kind
of modification that is not whitespace in it. But be careful about
making changes to inline patches—make sure they still apply.

### Adding or updating formulae

Only one maintainer is necessary to approve and merge the addition of a new or updated formula which passes CI. However, if the formula addition or update proves controversial the maintainer who adds it will be expected to answer requests and fix problems that arise with it in future.

### Removing formulae

Formulae that:

- work on at least 2/3 of our supported macOS versions in the default Homebrew prefix
- do not require patches rejected by upstream to work
- do not have known security vulnerabilities or CVEs for the version we package
- are shown to be still installed by users in our analytics with a `BuildError` rate of <25%

should not be removed from Homebrew. The exception to this rule are [versioned formulae](Versions.md) for which there are higher standards of usage and a maximum number of versions for a given formula.

### Closing issues/PRs

Maintainers (including the lead maintainer) should not close issues or pull requests (note a merge is not considered a close in this case) opened by other maintainers unless they are stale (i.e. have seen no updates for 28 days) in which case they can be closed by any maintainer. Any maintainer is encouraged to reopen a closed issue when they wish to do additional work on the issue.

Any maintainer can merge any PR they have carefully reviewed and is passing CI that has been opened by any other maintainer. If you do not wish to have other maintainers merge your PRs: please use the `do not merge` label to indicate that until you're ready to merge it yourself.

## Reverting PRs

Any maintainer can revert a PR created by another maintainer after a user submitted issue or CI failure that results. The maintainer who created the original PR should be given no less than an hour to fix the issue themselves or decide to revert the PR themselves if they would rather.

### Give time for other maintainers to review

PRs that are an "enhancement" to existing functionality i.e. not a fix to an open user issue/discussion, not a version bump, not a security fix, not a fix for CI failure, a usability improvement, a new feature, refactoring etc. should wait 24h Monday - Friday before being merged. For example,

- a new feature PR submitted at 5pm on Thursday should wait until 5pm on Friday before it is merged
- a usability fix PR submitted at 5pm on Friday should wait until 5pm on Monday before it is merged
- a user-reported issue fix PR can be merged immediately after CI is green

If a maintainer is on holiday/vacation/sick during this time and leaves comments after they are back: please treat post-merge PR comments and feedback as you would left within the time period and follow-up with another PR to address their requests (if agreed).

The vast majority of Homebrew/homebrew-core PRs are bug fixes or version bumps so can be self-merged once CI has completed.

## Communication

Maintainers have a variety of ways to communicate with each other:

- Homebrew's public repositories on GitHub
- Homebrew's group communications between more than two maintainers on private channels (e.g. GitHub/Slack)
- Homebrew's direct 1:1 messages between two maintainers on private channels (e.g. iMessage/Slack/carrier pigeon)

All communication should ideally occur in public on GitHub. Where this is not possible or appropriate (e.g. a security disclosure, interpersonal issue between two maintainers, urgent breakage that needs to be resolved) this can move to maintainers' private group communication and, if necessary, 1:1 communication. Technical decisions should not happen in 1:1 communications but if they do (or did in the past) they must end up back as something linkable on GitHub. For example, if a technical decision was made a year ago on Slack and another maintainer/contributor/user asks about it on GitHub, that's a good chance to explain it to them and have something that can be linked to in the future.

This makes it easier for other maintainers, contributors and users to follow along with what we're doing (and, more importantly, why we're doing it) and means that decisions have a linkable URL.

All maintainers (and lead maintainer) communication through any medium is bound by [Homebrew's Code of Conduct](https://github.com/Homebrew/.github/blob/HEAD/CODE_OF_CONDUCT.md#code-of-conduct). Abusive behaviour towards other maintainers, contributors or users will not be tolerated; the maintainer will be given a warning and if their behaviour continues they will be removed as a maintainer.

Maintainers should feel free to pleasantly disagree with the work and decisions of other maintainers. Healthy, friendly, technical disagreement between maintainers is actively encouraged and should occur in public on the issue tracker to make the project better. Interpersonal issues should be handled privately in Slack, ideally with moderation. If work or decisions are insufficiently documented or explained any maintainer or contributor should feel free to ask for clarification. No maintainer may ever justify a decision with e.g. "because I say so" or "it was I who did X" alone. Off-topic discussions on the issue tracker, [bike-shedding](https://en.wikipedia.org/wiki/Law_of_triviality) and personal attacks are forbidden.
