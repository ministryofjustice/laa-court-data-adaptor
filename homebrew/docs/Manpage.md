brew(1) -- The Missing Package Manager for macOS (or Linux)
===========================================================

## SYNOPSIS

`brew` `--version`<br>
`brew` *`command`* [`--verbose`|`-v`] [*`options`*] [*`formula`*] ...

## DESCRIPTION

Homebrew is the easiest and most flexible way to install the UNIX tools Apple
didn't include with macOS. It can also install software not packaged for your
Linux distribution to your home directory without requiring `sudo`.

## ESSENTIAL COMMANDS

For the full command list, see the [COMMANDS](#commands) section.

With `--verbose` or `--debug`, many commands print extra debugging information.
Note that these options should only appear after a command.

### `install` *`formula`*

Install *`formula`*.

*`formula`* is usually the name of the formula to install, but it has other
syntaxes which are listed in the [SPECIFYING FORMULAE](#specifying-formulae)
section.

### `uninstall` *`formula`*

Uninstall *`formula`*.

### `list`

List all installed formulae.

### `search` [*`text`*|`/`*`text`*`/`]

Perform a substring search of cask tokens and formula names for *`text`*. If
*`text`* is flanked by slashes, it is interpreted as a regular expression.
The search for *`text`* is extended online to `homebrew/core` and `homebrew/cask`.
If no search term is provided, all locally available formulae are listed.

## COMMANDS

### `analytics` [*`subcommand`*]

Control Homebrew's anonymous aggregate user behaviour analytics.
Read more at <https://docs.brew.sh/Analytics>.

`brew analytics` [`state`]
<br>Display the current state of Homebrew's analytics.

`brew analytics` (`on`|`off`)
<br>Turn Homebrew's analytics on or off respectively.

`brew analytics regenerate-uuid`
<br>Regenerate the UUID used for Homebrew's analytics.

### `autoremove` [*`options`*]

Uninstall formulae that were only installed as a dependency of another formula and are now no longer needed.

* `-n`, `--dry-run`:
  List what would be uninstalled, but do not actually uninstall anything.

### `cleanup` [*`options`*] [*`formula`*|*`cask`*]

Remove stale lock files and outdated downloads for all formulae and casks,
and remove old versions of installed formulae. If arguments are specified,
only do this for the given formulae and casks. Removes all downloads more than
120 days old. This can be adjusted with `HOMEBREW_CLEANUP_MAX_AGE_DAYS`.

* `--prune`:
  Remove all cache files older than specified *`days`*.
* `-n`, `--dry-run`:
  Show what would be removed, but do not actually remove anything.
* `-s`:
  Scrub the cache, including downloads for even the latest versions. Note downloads for any installed formulae or casks will still not be deleted. If you want to delete those too: `rm -rf "$(brew --cache)"`
* `--prune-prefix`:
  Only prune the symlinks and directories from the prefix and remove no other files.

### `commands` [*`options`*]

Show lists of built-in and external commands.

* `-q`, `--quiet`:
  List only the names of commands without category headers.
* `--include-aliases`:
  Include aliases of internal commands.

### `config`

Show Homebrew and system configuration info useful for debugging. If you file
a bug report, you will be required to provide this information.

### `deps` [*`options`*] [*`formula`*]

Show dependencies for *`formula`*. Additional options specific to *`formula`*
may be appended to the command. When given multiple formula arguments,
show the intersection of dependencies for each formula.

* `-n`:
  Sort dependencies in topological order.
* `--1`:
  Only show dependencies one level down, instead of recursing.
* `--union`:
  Show the union of dependencies for multiple *`formula`*, instead of the intersection.
* `--full-name`:
  List dependencies by their full name.
* `--include-build`:
  Include `:build` dependencies for *`formula`*.
* `--include-optional`:
  Include `:optional` dependencies for *`formula`*.
* `--include-test`:
  Include `:test` dependencies for *`formula`* (non-recursive).
* `--skip-recommended`:
  Skip `:recommended` dependencies for *`formula`*.
* `--include-requirements`:
  Include requirements in addition to dependencies for *`formula`*.
* `--tree`:
  Show dependencies as a tree. When given multiple formula arguments, show individual trees for each formula.
* `--annotate`:
  Mark any build, test, optional, or recommended dependencies as such in the output.
* `--installed`:
  List dependencies for formulae that are currently installed. If *`formula`* is specified, list only its dependencies that are currently installed.
* `--all`:
  List dependencies for all available formulae.
* `--for-each`:
  Switch into the mode used by the `--all` option, but only list dependencies for each provided *`formula`*, one formula per line. This is used for debugging the `--installed`/`--all` display mode.
* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `desc` [*`options`*] (*`text`*|`/`*`text`*`/`|*`formula`*)

Display *`formula`*'s name and one-line description.
Formula descriptions are cached; the cache is created on the
first search, making that search slower than subsequent ones.

* `-s`, `--search`:
  Search both names and descriptions for *`text`*. If *`text`* is flanked by slashes, it is interpreted as a regular expression.
* `-n`, `--name`:
  Search just names for *`text`*. If *`text`* is flanked by slashes, it is interpreted as a regular expression.
* `-d`, `--description`:
  Search just descriptions for *`text`*. If *`text`* is flanked by slashes, it is interpreted as a regular expression.

### `doctor` [*`options`*]

Check your system for potential problems. Will exit with a non-zero status
if any potential problems are found. Please note that these warnings are just
used to help the Homebrew maintainers with debugging if you file an issue. If
everything you use Homebrew for is working fine: please don't worry or file
an issue; just ignore this.

* `--list-checks`:
  List all audit methods, which can be run individually if provided as arguments.
* `-D`, `--audit-debug`:
  Enable debugging and profiling of audit methods.

### `fetch` [*`options`*] *`formula`*

Download a bottle (if available) or source packages for *`formula`*e
and binaries for *`cask`*s. For files, also print SHA-256 checksums.

* `--HEAD`:
  Fetch HEAD version instead of stable version.
* `--devel`:
  Fetch development version instead of stable version.
* `-f`, `--force`:
  Remove a previously cached version and re-fetch.
* `-v`, `--verbose`:
  Do a verbose VCS checkout, if the URL represents a VCS. This is useful for seeing if an existing VCS cache has been updated.
* `--retry`:
  Retry if downloading fails or re-download if the checksum of a previously cached version no longer matches.
* `--deps`:
  Also download dependencies for any listed *`formula`*.
* `-s`, `--build-from-source`:
  Download source packages rather than a bottle.
* `--build-bottle`:
  Download source packages (for eventual bottling) rather than a bottle.
* `--force-bottle`:
  Download a bottle if it exists for the current or newest version of macOS, even if it would not be used during installation.
* `--[no-]quarantine`:
  Disable/enable quarantining of downloads (default: enabled).
* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `formulae`

List all locally installable formulae including short names.

### `gist-logs` [*`options`*] *`formula`*

Upload logs for a failed build of *`formula`* to a new Gist. Presents an
error message if no logs are found.

* `--with-hostname`:
  Include the hostname in the Gist.
* `-n`, `--new-issue`:
  Automatically create a new issue in the appropriate GitHub repository after creating the Gist.
* `-p`, `--private`:
  The Gist will be marked private and will not appear in listings but will be accessible with its link.

### `home` [*`formula`*|*`cask`*]

Open a *`formula`* or *`cask`*'s homepage in a browser, or open
Homebrew's own homepage if no argument is provided.

### `info` [*`options`*] [*`formula`*|*`cask`*]

Display brief statistics for your Homebrew installation.

If a *`formula`* or *`cask`* is provided, show summary of information about it.

* `--analytics`:
  List global Homebrew analytics data or, if specified, installation and build error data for *`formula`* (provided neither `HOMEBREW_NO_ANALYTICS` nor `HOMEBREW_NO_GITHUB_API` are set).
* `--days`:
  How many days of analytics data to retrieve. The value for *`days`* must be `30`, `90` or `365`. The default is `30`.
* `--category`:
  Which type of analytics data to retrieve. The value for *`category`* must be `install`, `install-on-request` or `build-error`; `cask-install` or `os-version` may be specified if *`formula`* is not. The default is `install`.
* `--github`:
  Open the GitHub source page for *`formula`* in a browser. To view formula history locally: `brew log -p` *`formula`*
* `--json`:
  Print a JSON representation. Currently the default value for *`version`* is `v1` for *`formula`*. For *`formula`* and *`cask`* use `v2`. See the docs for examples of using the JSON output: <https://docs.brew.sh/Querying-Brew>
* `--installed`:
  Print JSON of formulae that are currently installed.
* `--all`:
  Print JSON of all available formulae.
* `-v`, `--verbose`:
  Show more verbose analytics data for *`formula`*.
* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `install` [*`options`*] *`formula`*|*`cask`*

Install a *`formula`* or *`cask`*. Additional options specific to a *`formula`* may be
appended to the command.

Unless `HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for
the installed formulae or, every 30 days, for all formulae.

* `-d`, `--debug`:
  If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory.
* `-f`, `--force`:
  Install formulae without checking for previously installed keg-only or non-migrated versions. Overwrite existing files when installing casks.
* `-v`, `--verbose`:
  Print the verification and postinstall steps.
* `--formula`:
  Treat all named arguments as formulae.
* `--env`:
  If `std` is passed, use the standard build environment instead of superenv. If `super` is passed, use superenv even if the formula specifies the standard build environment.
* `--ignore-dependencies`:
  An unsupported Homebrew development flag to skip installing any dependencies of any kind. If the dependencies are not already present, the formula will have issues. If you're not developing Homebrew, consider adjusting your PATH rather than using this flag.
* `--only-dependencies`:
  Install the dependencies with specified options but do not install the formula itself.
* `--cc`:
  Attempt to compile using the specified *`compiler`*, which should be the name of the compiler's executable, e.g. `gcc-7` for GCC 7. In order to use LLVM's clang, specify `llvm_clang`. To use the Apple-provided clang, specify `clang`. This option will only accept compilers that are provided by Homebrew or bundled with macOS. Please do not file issues if you encounter errors while using this option.
* `-s`, `--build-from-source`:
  Compile *`formula`* from source even if a bottle is provided. Dependencies will still be installed from bottles if they are available.
* `--force-bottle`:
  Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation.
* `--include-test`:
  Install testing dependencies required to run `brew test` *`formula`*.
* `--HEAD`:
  If *`formula`* defines it, install the HEAD version, aka. master, trunk, unstable.
* `--fetch-HEAD`:
  Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository's HEAD will only be checked for updates when a new stable or development version has been released.
* `--keep-tmp`:
  Retain the temporary files created during installation.
* `--build-bottle`:
  Prepare the formula for eventual bottling during installation, skipping any post-install steps.
* `--bottle-arch`:
  Optimise bottles for the specified architecture rather than the oldest architecture supported by the version of macOS the bottles are built on.
* `--display-times`:
  Print install times for each formula at the end of the run.
* `-i`, `--interactive`:
  Download and patch *`formula`*, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package.
* `-g`, `--git`:
  Create a Git repository, useful for creating patches to the software.
* `--cask`:
  Treat all named arguments as casks.
* `--[no-]binaries`:
  Disable/enable linking of helper executables (default: enabled).
* `--require-sha`:
  Require all casks to have a checksum.
* `--[no-]quarantine`:
  Disable/enable quarantining of downloads (default: enabled).
* `--skip-cask-deps`:
  Skip installing cask dependencies.

### `leaves`

List installed formulae that are not dependencies of another installed formula.

### `link`, `ln` [*`options`*] *`formula`*

Symlink all of *`formula`*'s installed files into Homebrew's prefix. This
is done automatically when you install formulae but can be useful for DIY
installations.

* `--overwrite`:
  Delete files that already exist in the prefix while linking.
* `-n`, `--dry-run`:
  List files which would be linked or deleted by `brew link --overwrite` without actually linking or deleting any files.
* `-f`, `--force`:
  Allow keg-only formulae to be linked.

### `list`, `ls` [*`options`*] [*`formula`*|*`cask`*]

List all installed formulae and casks.

If *`formula`* is provided, summarise the paths within its current keg.
If *`cask`* is provided, list its artifacts.

* `--formula`:
  List only formulae, or treat all named arguments as formulae.
* `--cask`:
  List only casks, or treat all named arguments as casks.
* `--full-name`:
  Print formulae with fully-qualified names. Unless `--full-name`, `--versions` or `--pinned` are passed, other options (i.e. `-1`, `-l`, `-r` and `-t`) are passed to `ls`(1) which produces the actual output.
* `--versions`:
  Show the version number for installed formulae, or only the specified formulae if *`formula`* are provided.
* `--multiple`:
  Only show formulae with multiple versions installed.
* `--pinned`:
  List only pinned formulae, or only the specified (pinned) formulae if *`formula`* are provided. See also `pin`, `unpin`.
* `-1`:
  Force output to be one entry per line. This is the default when output is not to a terminal.
* `-l`:
  List formulae in long format. If the output is to a terminal, a total sum for all the file sizes is printed before the long listing.
* `-r`:
  Reverse the order of the formulae sort to list the oldest entries first.
* `-t`:
  Sort formulae by time modified, listing most recently modified first.

### `log` [*`options`*] [*`formula`*]

Show the `git log` for *`formula`*, or show the log for the Homebrew repository
if no formula is provided.

* `-p`, `--patch`:
  Also print patch from commit.
* `--stat`:
  Also print diffstat from commit.
* `--oneline`:
  Print only one line per commit.
* `-1`:
  Print only one commit.
* `-n`, `--max-count`:
  Print only a specified number of commits.

### `migrate` [*`options`*] *`formula`*

Migrate renamed packages to new names, where *`formula`* are old names of
packages.

* `-f`, `--force`:
  Treat installed *`formula`* and provided *`formula`* as if they are from the same taps and migrate them anyway.

### `missing` [*`options`*] [*`formula`*]

Check the given *`formula`* kegs for missing dependencies. If no *`formula`* are
provided, check all kegs. Will exit with a non-zero status if any kegs are found
to be missing dependencies.

* `--hide`:
  Act as if none of the specified *`hidden`* are installed. *`hidden`* should be a comma-separated list of formulae.

### `options` [*`options`*] [*`formula`*]

Show install options specific to *`formula`*.

* `--compact`:
  Show all options on a single line separated by spaces.
* `--installed`:
  Show options for formulae that are currently installed.
* `--all`:
  Show options for all available formulae.
* `--command`:
  Show options for the specified *`command`*.

### `outdated` [*`options`*] [*`formula`*|*`cask`*]

List installed casks and formulae that have an updated version available. By default, version
information is displayed in interactive shells, and suppressed otherwise.

* `-q`, `--quiet`:
  List only the names of outdated kegs (takes precedence over `--verbose`).
* `-v`, `--verbose`:
  Include detailed version information.
* `--formula`:
  List only outdated formulae.
* `--cask`:
  List only outdated casks.
* `--json`:
  Print output in JSON format. There are two versions: v1 and v2. v1 is deprecated and is currently the default if no version is specified. v2 prints outdated formulae and casks. 
* `--fetch-HEAD`:
  Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository's HEAD will only be checked for updates when a new stable or development version has been released.
* `--greedy`:
  Print outdated casks with `auto_updates` or `version :latest`.

### `pin` *`formula`*

Pin the specified *`formula`*, preventing them from being upgraded when
issuing the `brew upgrade` *`formula`* command. See also `unpin`.

### `postinstall` *`formula`*

Rerun the post-install steps for *`formula`*.

### `readall` [*`options`*] [*`tap`*]

Import all items from the specified *`tap`*, or from all installed taps if none is provided.
This can be useful for debugging issues across all items when making
significant changes to `formula.rb`, testing the performance of loading
all items or checking if any current formulae/casks have Ruby issues.

* `--aliases`:
  Verify any alias symlinks in each tap.
* `--syntax`:
  Syntax-check all of Homebrew's Ruby files (if no `*`tap`*` is passed).

### `reinstall` [*`options`*] *`formula`*|*`cask`*

Uninstall and then reinstall a *`formula`* or *`cask`* using the same options it was
originally installed with, plus any appended options specific to a *`formula`*.

Unless `HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for the
reinstalled formulae or, every 30 days, for all formulae.

* `-d`, `--debug`:
  If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory.
* `-f`, `--force`:
  Install without checking for previously installed keg-only or non-migrated versions.
* `-v`, `--verbose`:
  Print the verification and postinstall steps.
* `--formula`:
  Treat all named arguments as formulae.
* `-s`, `--build-from-source`:
  Compile *`formula`* from source even if a bottle is available.
* `-i`, `--interactive`:
  Download and patch *`formula`*, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package.
* `--force-bottle`:
  Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation.
* `--keep-tmp`:
  Retain the temporary files created during installation.
* `--display-times`:
  Print install times for each formula at the end of the run.
* `--cask`:
  Treat all named arguments as casks.
* `--[no-]binaries`:
  Disable/enable linking of helper executables (default: enabled).
* `--require-sha`:
  Require all casks to have a checksum.
* `--[no-]quarantine`:
  Disable/enable quarantining of downloads (default: enabled).
* `--skip-cask-deps`:
  Skip installing cask dependencies.

### `search` [*`options`*] [*`text`*|`/`*`text`*`/`]

Perform a substring search of cask tokens and formula names for *`text`*. If *`text`*
is flanked by slashes, it is interpreted as a regular expression.
The search for *`text`* is extended online to `homebrew/core` and `homebrew/cask`.

If no *`text`* is provided, list all locally available formulae (including tapped ones).
No online search is performed.

* `--formula`:
  Without *`text`*, list all locally available formulae (no online search is performed). With *`text`*, search online and locally for formulae.
* `--cask`:
  Without *`text`*, list all locally available casks (including tapped ones, no online search is performed). With *`text`*, search online and locally for casks.
* `--desc`:
  Search for formulae with a description matching *`text`* and casks with a name matching *`text`*.
* `--pull-request`:
  Search for GitHub pull requests containing *`text`*.
* `--macports`:
  Search for *`text`* in the given package manager's list.
* `--fink`:
  Search for *`text`* in the given package manager's list.
* `--opensuse`:
  Search for *`text`* in the given package manager's list.
* `--fedora`:
  Search for *`text`* in the given package manager's list.
* `--debian`:
  Search for *`text`* in the given package manager's list.
* `--ubuntu`:
  Search for *`text`* in the given package manager's list.

### `shellenv`

Print export statements. When run in a shell, this installation of Homebrew will be added to your `PATH`, `MANPATH`, and `INFOPATH`.

The variables `HOMEBREW_PREFIX`, `HOMEBREW_CELLAR` and `HOMEBREW_REPOSITORY` are also exported to avoid querying them multiple times.
Consider adding evaluation of this command's output to your dotfiles (e.g. `~/.profile`, `~/.bash_profile`, or `~/.zprofile`) with: `eval $(brew shellenv)`

### `tap` [*`options`*] [*`user`*`/`*`repo`*] [*`URL`*]

Tap a formula repository.

If no arguments are provided, list all installed taps.

With *`URL`* unspecified, tap a formula repository from GitHub using HTTPS.
Since so many taps are hosted on GitHub, this command is a shortcut for
`brew tap` *`user`*`/`*`repo`* `https://github.com/`*`user`*`/homebrew-`*`repo`*.

With *`URL`* specified, tap a formula repository from anywhere, using
any transport protocol that `git`(1) handles. The one-argument form of `tap`
simplifies but also limits. This two-argument command makes no
assumptions, so taps can be cloned from places other than GitHub and
using protocols other than HTTPS, e.g. SSH, git, HTTP, FTP(S), rsync.

* `--full`:
  Convert a shallow clone to a full clone without untapping. Taps are only cloned as shallow clones if `--shallow` was originally passed.
* `--shallow`:
  Fetch tap as a shallow clone rather than a full clone. Useful for continuous integration.
* `--force-auto-update`:
  Auto-update tap even if it is not hosted on GitHub. By default, only taps hosted on GitHub are auto-updated (for performance reasons).
* `--repair`:
  Migrate tapped formulae from symlink-based to directory-based structure.
* `--list-pinned`:
  List all pinned taps.

### `tap-info` [*`options`*] [*`tap`*]

Show detailed information about one or more *`tap`*s.

If no *`tap`* names are provided, display brief statistics for all installed taps.

* `--installed`:
  Show information on each installed tap.
* `--json`:
  Print a JSON representation of *`tap`*. Currently the default and only accepted value for *`version`* is `v1`. See the docs for examples of using the JSON output: <https://docs.brew.sh/Querying-Brew>

### `uninstall`, `rm`, `remove` [*`options`*] *`formula`*|*`cask`*

Uninstall a *`formula`* or *`cask`*.

* `-f`, `--force`:
  Delete all installed versions of *`formula`*. Uninstall even if *`cask`* is not installed, overwrite existing files and ignore errors when removing files.
* `--zap`:
  Remove all files associated with a *`cask`*. *May remove files which are shared between applications.*
* `--ignore-dependencies`:
  Don't fail uninstall, even if *`formula`* is a dependency of any installed formulae.
* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `unlink` [*`options`*] *`formula`*

Remove symlinks for *`formula`* from Homebrew's prefix. This can be useful
for temporarily disabling a formula:
`brew unlink` *`formula`* `&&` *`commands`* `&& brew link` *`formula`*

* `-n`, `--dry-run`:
  List files which would be unlinked without actually unlinking or deleting any files.

### `unpin` *`formula`*

Unpin *`formula`*, allowing them to be upgraded by `brew upgrade` *`formula`*.
See also `pin`.

### `untap` *`tap`*

Remove a tapped formula repository.

### `update` [*`options`*]

Fetch the newest version of Homebrew and all formulae from GitHub using `git`(1) and perform any necessary migrations.

* `--merge`:
  Use `git merge` to apply updates (rather than `git rebase`).
* `--preinstall`:
  Run on auto-updates (e.g. before `brew install`). Skips some slower steps.
* `-f`, `--force`:
  Always do a slower, full update check (even if unnecessary).

### `update-reset` [*`repository`*]

Fetch and reset Homebrew and all tap repositories (or any specified *`repository`*) using `git`(1) to their latest `origin/master`.

*Note:* this will destroy all your uncommitted or committed changes.

### `upgrade` [*`options`*] [*`formula`*|*`cask`*]

Upgrade outdated casks and outdated, unpinned formulae using the same options they were originally
installed with, plus any appended brew formula options. If *`cask`* or *`formula`* are specified,
upgrade only the given *`cask`* or *`formula`* kegs (unless they are pinned; see `pin`, `unpin`).

Unless `HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for the
upgraded formulae or, every 30 days, for all formulae.

* `-d`, `--debug`:
  If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory.
* `-f`, `--force`:
  Install formulae without checking for previously installed keg-only or non-migrated versions. Overwrite existing files when installing casks.
* `-v`, `--verbose`:
  Print the verification and postinstall steps.
* `-n`, `--dry-run`:
  Show what would be upgraded, but do not actually upgrade anything.
* `--formula`:
  Treat all named arguments as formulae. If no named argumentsare specified, upgrade only outdated formulae.
* `-s`, `--build-from-source`:
  Compile *`formula`* from source even if a bottle is available.
* `-i`, `--interactive`:
  Download and patch *`formula`*, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package.
* `--force-bottle`:
  Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation.
* `--fetch-HEAD`:
  Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository's HEAD will only be checked for updates when a new stable or development version has been released.
* `--ignore-pinned`:
  Set a successful exit status even if pinned formulae are not upgraded.
* `--keep-tmp`:
  Retain the temporary files created during installation.
* `--display-times`:
  Print install times for each formula at the end of the run.
* `--cask`:
  Treat all named arguments as casks. If no named arguments are specified, upgrade only outdated casks.
* `--[no-]binaries`:
  Disable/enable linking of helper executables (default: enabled).
* `--require-sha`:
  Require all casks to have a checksum.
* `--[no-]quarantine`:
  Disable/enable quarantining of downloads (default: enabled).
* `--skip-cask-deps`:
  Skip installing cask dependencies.
* `--greedy`:
  Also include casks with `auto_updates true` or `version :latest`.

### `uses` [*`options`*] *`formula`*

Show formulae that specify *`formula`* as a dependency (i.e. show dependents
of *`formula`*). When given multiple formula arguments, show the intersection
of formulae that use *`formula`*. By default, `uses` shows all formulae that
specify *`formula`* as a required or recommended dependency for their stable builds.

* `--recursive`:
  Resolve more than one level of dependencies.
* `--installed`:
  Only list formulae that are currently installed.
* `--include-build`:
  Include all formulae that specify *`formula`* as `:build` type dependency.
* `--include-test`:
  Include all formulae that specify *`formula`* as `:test` type dependency.
* `--include-optional`:
  Include all formulae that specify *`formula`* as `:optional` type dependency.
* `--skip-recommended`:
  Skip all formulae that specify *`formula`* as `:recommended` type dependency.

### `--cache` [*`options`*] [*`formula`*|*`cask`*]

Display Homebrew's download cache. See also `HOMEBREW_CACHE`.

If *`formula`* is provided, display the file or directory used to cache *`formula`*.

* `-s`, `--build-from-source`:
  Show the cache file used when building from source.
* `--force-bottle`:
  Show the cache file used when pouring a bottle.
* `--formula`:
  Only show cache files for formulae.
* `--cask`:
  Only show cache files for casks.

### `--caskroom` [*`cask`*]

Display Homebrew's Caskroom path.

If *`cask`* is provided, display the location in the Caskroom where *`cask`*
would be installed, without any sort of versioned directory as the last path.

### `--cellar` [*`formula`*]

Display Homebrew's Cellar path. *Default:* `$(brew --prefix)/Cellar`, or if
that directory doesn't exist, `$(brew --repository)/Cellar`.

If *`formula`* is provided, display the location in the Cellar where *`formula`*
would be installed, without any sort of versioned directory as the last path.

### `--env` [*`options`*] [*`formula`*]

Summarise Homebrew's build environment as a plain list.

If the command's output is sent through a pipe and no shell is specified,
the list is formatted for export to `bash`(1) unless `--plain` is passed.

* `--shell`:
  Generate a list of environment variables for the specified shell, or `--shell=auto` to detect the current shell.
* `--plain`:
  Generate plain output even when piped.

### `--prefix` [*`formula`*]

Display Homebrew's install path. *Default:*

  - macOS Intel: `/usr/local`
  - macOS ARM: `/opt/homebrew`
  - Linux: `/home/linuxbrew/.linuxbrew`

If *`formula`* is provided, display the location in the Cellar where *`formula`*
is or would be installed.

* `--unbrewed`:
  List files in Homebrew's prefix not installed by Homebrew.

### `--repository`, `--repo` [*`user`*`/`*`repo`*]

Display where Homebrew's `.git` directory is located.

If *`user`*`/`*`repo`* are provided, display where tap *`user`*`/`*`repo`*'s directory is located.

### `--version`

Print the version numbers of Homebrew, Homebrew/homebrew-core and Homebrew/homebrew-cask
(if tapped) to standard output.

## DEVELOPER COMMANDS

### `audit` [*`options`*] [*`formula`*|*`cask`*]

Check *`formula`* for Homebrew coding style violations. This should be run before
submitting a new formula or cask. If no *`formula`*|*`cask`* are provided, check all
locally available formulae and casks and skip style checks. Will exit with a
non-zero status if any errors are found.

* `--strict`:
  Run additional, stricter style checks.
* `--git`:
  Run additional, slower style checks that navigate the Git repository.
* `--online`:
  Run additional, slower style checks that require a network connection.
* `--new`:
  Run various additional style checks to determine if a new formula or cask is eligible for Homebrew. This should be used when creating new formula and implies `--strict` and `--online`.
* `--tap`:
  Check the formulae within the given tap, specified as *`user`*`/`*`repo`*.
* `--fix`:
  Fix style violations automatically using RuboCop's auto-correct feature.
* `--display-cop-names`:
  Include the RuboCop cop name for each violation in the output.
* `--display-filename`:
  Prefix every line of output with the file or formula name being audited, to make output easy to grep.
* `--skip-style`:
  Skip running non-RuboCop style checks. Useful if you plan on running `brew style` separately. Enabled by default unless a formula is specified by name.
* `-D`, `--audit-debug`:
  Enable debugging and profiling of audit methods.
* `--only`:
  Specify a comma-separated *`method`* list to only run the methods named `audit_`*`method`*.
* `--except`:
  Specify a comma-separated *`method`* list to skip running the methods named `audit_`*`method`*.
* `--only-cops`:
  Specify a comma-separated *`cops`* list to check for violations of only the listed RuboCop cops.
* `--except-cops`:
  Specify a comma-separated *`cops`* list to skip checking for violations of the listed RuboCop cops.
* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.
* `--[no-]appcast`:
  Audit the appcast
* `--token-conflicts`:
  Audit for token conflicts

### `bottle` [*`options`*] *`formula`*

Generate a bottle (binary package) from a formula that was installed with
`--build-bottle`.
If the formula specifies a rebuild version, it will be incremented in the
generated DSL. Passing `--keep-old` will attempt to keep it at its original
value, while `--no-rebuild` will remove it.

* `--skip-relocation`:
  Do not check if the bottle can be marked as relocatable.
* `--force-core-tap`:
  Build a bottle even if *`formula`* is not in `homebrew/core` or any installed taps.
* `--no-rebuild`:
  If the formula specifies a rebuild version, remove it from the generated DSL.
* `--keep-old`:
  If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL.
* `--json`:
  Write bottle information to a JSON file, which can be used as the value for `--merge`.
* `--merge`:
  Generate an updated bottle block for a formula and optionally merge it into the formula file. Instead of a formula name, requires the path to a JSON file generated with `brew bottle --json` *`formula`*.
* `--write`:
  Write changes to the formula file. A new commit will be generated unless `--no-commit` is passed.
* `--no-commit`:
  When passed with `--write`, a new commit will not generated after writing changes to the formula file.
* `--root-url`:
  Use the specified *`URL`* as the root of the bottle's URL instead of Homebrew's default.

### `bump` [*`options`*] [*`formula`*]

Display out-of-date brew formulae and the latest version available.
Also displays whether a pull request has been opened with the URL.

* `--limit`:
  Limit number of package results returned.

### `bump-cask-pr` [*`options`*] *`cask`*

Create a pull request to update *`cask`* with a new version.

A best effort to determine the *`SHA-256`* will be made if the value is not
supplied by the user.

* `-n`, `--dry-run`:
  Print what would be done rather than doing it.
* `--write`:
  Make the expected file modifications without taking any Git actions.
* `--commit`:
  When passed with `--write`, generate a new commit after writing changes to the cask file.
* `--no-audit`:
  Don't run `brew audit` before opening the PR.
* `--online`:
  Run `brew audit --online` before opening the PR.
* `--no-style`:
  Don't run `brew style --fix` before opening the PR.
* `--no-browse`:
  Print the pull request URL instead of opening in a browser.
* `--no-fork`:
  Don't try to fork the repository.
* `--version`:
  Specify the new *`version`* for the cask.
* `--message`:
  Append *`message`* to the default pull request message.
* `--url`:
  Specify the *`URL`* for the new download.
* `--sha256`:
  Specify the *`SHA-256`* checksum of the new download.
* `-f`, `--force`:
  Ignore duplicate open PRs.

### `bump-formula-pr` [*`options`*] [*`formula`*]

Create a pull request to update *`formula`* with a new URL or a new tag.

If a *`URL`* is specified, the *`SHA-256`* checksum of the new download should also
be specified. A best effort to determine the *`SHA-256`* and *`formula`* name will
be made if either or both values are not supplied by the user.

If a *`tag`* is specified, the Git commit *`revision`* corresponding to that tag
should also be specified. A best effort to determine the *`revision`* will be made
if the value is not supplied by the user.

If a *`version`* is specified, a best effort to determine the *`URL`* and *`SHA-256`* or
the *`tag`* and *`revision`* will be made if both values are not supplied by the user.

*Note:* this command cannot be used to transition a formula from a
URL-and-SHA-256 style specification into a tag-and-revision style specification,
nor vice versa. It must use whichever style specification the formula already uses.

* `-n`, `--dry-run`:
  Print what would be done rather than doing it.
* `--write`:
  Make the expected file modifications without taking any Git actions.
* `--commit`:
  When passed with `--write`, generate a new commit after writing changes to the formula file.
* `--no-audit`:
  Don't run `brew audit` before opening the PR.
* `--strict`:
  Run `brew audit --strict` before opening the PR.
* `--online`:
  Run `brew audit --online` before opening the PR.
* `--no-browse`:
  Print the pull request URL instead of opening in a browser.
* `--no-fork`:
  Don't try to fork the repository.
* `--mirror`:
  Use the specified *`URL`* as a mirror URL. If *`URL`* is a comma-separated list of URLs, multiple mirrors will be added.
* `--version`:
  Use the specified *`version`* to override the value parsed from the URL or tag. Note that `--version=0` can be used to delete an existing version override from a formula if it has become redundant.
* `--message`:
  Append *`message`* to the default pull request message.
* `--url`:
  Specify the *`URL`* for the new download. If a *`URL`* is specified, the *`SHA-256`* checksum of the new download should also be specified.
* `--sha256`:
  Specify the *`SHA-256`* checksum of the new download.
* `--tag`:
  Specify the new git commit *`tag`* for the formula.
* `--revision`:
  Specify the new git commit *`revision`* corresponding to the specified *`tag`*.
* `-f`, `--force`:
  Ignore duplicate open PRs. Remove all mirrors if `--mirror` was not specified.

### `bump-revision` [*`options`*] *`formula`* [*`formula`* ...]

Create a commit to increment the revision of *`formula`*. If no revision is
present, "revision 1" will be added.

* `-n`, `--dry-run`:
  Print what would be done rather than doing it.
* `--message`:
  Append *`message`* to the default commit message.

### `cat` *`formula`*|*`cask`*

Display the source of a *`formula`* or *`cask`*.

* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `command` *`cmd`*

Display the path to the file being used when invoking `brew` *`cmd`*.

### `create` [*`options`*] *`URL`*

Generate a formula or, with `--cask`, a cask for the downloadable file at *`URL`*
and open it in the editor. Homebrew will attempt to automatically derive the
formula name and version, but if it fails, you'll have to make your own template.
The `wget` formula serves as a simple example. For the complete API, see:
<https://rubydoc.brew.sh/Formula>

* `--autotools`:
  Create a basic template for an Autotools-style build.
* `--cask`:
  Create a basic template for a cask.
* `--cmake`:
  Create a basic template for a CMake-style build.
* `--crystal`:
  Create a basic template for a Crystal build.
* `--go`:
  Create a basic template for a Go build.
* `--meson`:
  Create a basic template for a Meson-style build.
* `--node`:
  Create a basic template for a Node build.
* `--perl`:
  Create a basic template for a Perl build.
* `--python`:
  Create a basic template for a Python build.
* `--ruby`:
  Create a basic template for a Ruby build.
* `--rust`:
  Create a basic template for a Rust build.
* `--no-fetch`:
  Homebrew will not download *`URL`* to the cache and will thus not add its SHA-256 to the formula for you, nor will it check the GitHub API for GitHub projects (to fill out its description and homepage).
* `--HEAD`:
  Indicate that *`URL`* points to the package's repository rather than a file.
* `--set-name`:
  Explicitly set the *`name`* of the new formula or cask.
* `--set-version`:
  Explicitly set the *`version`* of the new formula or cask.
* `--set-license`:
  Explicitly set the *`license`* of the new formula.
* `--tap`:
  Generate the new formula within the given tap, specified as *`user`*`/`*`repo`*.
* `-f`, `--force`:
  Ignore errors for disallowed formula names and names that shadow aliases.

### `dispatch-build-bottle` [*`options`*] *`formula`* [*`formula`* ...]

Build bottles for these formulae with GitHub Actions.

* `--tap`:
  Target tap repository (default: `homebrew/core`).
* `--issue`:
  If specified, post a comment to this issue number if the job fails.
* `--macos`:
  Version of macOS the bottle should be built for.
* `--workflow`:
  Dispatch specified workflow (default: `dispatch-build-bottle.yml`).
* `--upload`:
  Upload built bottles to Bintray.

### `edit` [*`formula`*|*`cask`*]

Open a *`formula`* or *`cask`* in the editor set by `EDITOR` or `HOMEBREW_EDITOR`,
or open the Homebrew repository for editing if no formula is provided.

* `--formula`:
  Treat all named arguments as formulae.
* `--cask`:
  Treat all named arguments as casks.

### `extract` [*`options`*] *`formula`* *`tap`*

Look through repository history to find the most recent version of *`formula`* and
create a copy in *`tap`*`/Formula/`*`formula`*`@`*`version`*`.rb`. If the tap is not
installed yet, attempt to install/clone the tap before continuing. To extract
a formula from a tap that is not `homebrew/core` use its fully-qualified form of
*`user`*`/`*`repo`*`/`*`formula`*.

* `--version`:
  Extract the specified *`version`* of *`formula`* instead of the most recent.
* `-f`, `--force`:
  Overwrite the destination formula if it already exists.

### `formula` *`formula`*

Display the path where *`formula`* is located.

### `install-bundler-gems`

Install Homebrew's Bundler gems.

### `irb` [*`options`*]

Enter the interactive Homebrew Ruby shell.

* `--examples`:
  Show several examples.
* `--pry`:
  Use Pry instead of IRB. Implied if `HOMEBREW_PRY` is set.

### `linkage` [*`options`*] [*`formula`*]

Check the library links from the given *`formula`* kegs. If no *`formula`* are
provided, check all kegs. Raises an error if run on uninstalled formulae.

* `--test`:
  Show only missing libraries and exit with a non-zero status if any missing libraries are found.
* `--reverse`:
  For every library that a keg references, print its dylib path followed by the binaries that link to it.
* `--cached`:
  Print the cached linkage values stored in `HOMEBREW_CACHE`, set by a previous `brew linkage` run.

### `livecheck` [*`formulae`*]

Check for newer versions of formulae from upstream.

If no formula argument is passed, the list of formulae to check is taken from `HOMEBREW_LIVECHECK_WATCHLIST`
or `~/.brew_livecheck_watchlist`.

* `--full-name`:
  Print formulae with fully-qualified names.
* `--tap`:
  Check formulae within the given tap, specified as *`user`*`/`*`repo`*.
* `--all`:
  Check all available formulae.
* `--installed`:
  Check formulae that are currently installed.
* `--newer-only`:
  Show the latest version only if it's newer than the formula.
* `--json`:
  Output information in JSON format.
* `-q`, `--quiet`:
  Suppress warnings, don't print a progress bar for JSON output.

### `man` [*`options`*]

Generate Homebrew's manpages.

* `--fail-if-changed`:
  Return a failing status code if changes are detected in the manpage outputs. This can be used to notify CI when the manpages are out of date. Additionally, the date used in new manpages will match those in the existing manpages (to allow comparison without factoring in the date).
* `--link`:
  This is now done automatically by `brew update`.

### `mirror` *`formula`*

Reupload the stable URL of a formula to Bintray for use as a mirror.

* `--bintray-org`:
  Upload to the specified Bintray organisation (default: `homebrew`).
* `--bintray-repo`:
  Upload to the specified Bintray repository (default: `mirror`).
* `--no-publish`:
  Upload to Bintray, but don't publish.

### `pr-automerge` [*`options`*]

Find pull requests that can be automatically merged using `brew pr-publish`.

* `--tap`:
  Target tap repository (default: `homebrew/core`).
* `--with-label`:
  Pull requests must have this label.
* `--without-labels`:
  Pull requests must not have these labels (default: `do not merge`, `new formula`, `automerge-skip`, `linux-only`).
* `--without-approval`:
  Pull requests do not require approval to be merged.
* `--publish`:
  Run `brew pr-publish` on matching pull requests.
* `--autosquash`:
  Instruct `brew pr-publish` to automatically reformat and reword commits in the pull request to our preferred format.
* `--ignore-failures`:
  Include pull requests that have failing status checks.

### `pr-publish` [*`options`*] *`pull_request`* [*`pull_request`* ...]

Publish bottles for a pull request with GitHub Actions.
Requires write access to the repository.

* `--autosquash`:
  If supported on the target tap, automatically reformat and reword commits in the pull request to our preferred format.
* `--message`:
  Message to include when autosquashing revision bumps, deletions, and rebuilds.
* `--tap`:
  Target tap repository (default: `homebrew/core`).
* `--workflow`:
  Target workflow filename (default: `publish-commit-bottles.yml`).

### `pr-pull` [*`options`*] *`pull_request`* [*`pull_request`* ...]

Download and publish bottles, and apply the bottle commit from a
pull request with artifacts generated by GitHub Actions.
Requires write access to the repository.

* `--no-publish`:
  Download the bottles, apply the bottle commit and upload the bottles to Bintray, but don't publish them.
* `--no-upload`:
  Download the bottles and apply the bottle commit, but don't upload to Bintray or GitHub Releases.
* `-n`, `--dry-run`:
  Print what would be done rather than doing it.
* `--clean`:
  Do not amend the commits from pull requests.
* `--keep-old`:
  If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL.
* `--autosquash`:
  Automatically reformat and reword commits in the pull request to our preferred format.
* `--branch-okay`:
  Do not warn if pulling to a branch besides the repository default (useful for testing).
* `--resolve`:
  When a patch fails to apply, leave in progress and allow user to resolve, instead of aborting.
* `--warn-on-upload-failure`:
  Warn instead of raising an error if the bottle upload fails. Useful for repairing bottle uploads that previously failed.
* `--message`:
  Message to include when autosquashing revision bumps, deletions, and rebuilds.
* `--workflow`:
  Retrieve artifacts from the specified workflow (default: `tests.yml`). Legacy: use --workflows instead
* `--artifact`:
  Download artifacts with the specified name (default: `bottles`).
* `--bintray-org`:
  Upload to the specified Bintray organisation (default: `homebrew`).
* `--tap`:
  Target tap repository (default: `homebrew/core`).
* `--root-url`:
  Use the specified *`URL`* as the root of the bottle's URL instead of Homebrew's default.
* `--bintray-mirror`:
  Use the specified Bintray repository to automatically mirror stable URLs defined in the formulae (default: `mirror`).
* `--workflows`:
  Retrieve artifacts from the specified workflow (default: `tests.yml`) Comma-separated list to include multiple workflows.
* `--ignore-missing-artifacts`:
  Comma-separated list of workflows which can be ignored if they have not been run.

### `pr-upload` [*`options`*]

Apply the bottle commit and publish bottles to Bintray or GitHub Releases.

* `--no-publish`:
  Apply the bottle commit and upload the bottles, but don't publish them.
* `--keep-old`:
  If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL.
* `-n`, `--dry-run`:
  Print what would be done rather than doing it.
* `--no-commit`:
  Do not generate a new commit before uploading.
* `--warn-on-upload-failure`:
  Warn instead of raising an error if the bottle upload fails. Useful for repairing bottle uploads that previously failed.
* `--bintray-org`:
  Upload to the specified Bintray organisation (default: `homebrew`).
* `--root-url`:
  Use the specified *`URL`* as the root of the bottle's URL instead of Homebrew's default.

### `prof` [*`command`*]

Run Homebrew with a Ruby profiler, e.g. `brew prof readall`.

* `--stackprof`:
  Use `stackprof` instead of `ruby-prof` (the default).

### `release-notes` [*`options`*] [*`previous_tag`*] [*`end_ref`*]

Print the merged pull requests on Homebrew/brew between two Git refs.
If no *`previous_tag`* is provided it defaults to the latest tag.
If no *`end_ref`* is provided it defaults to `origin/master`.

* `--markdown`:
  Print as a Markdown list.

### `ruby` (`-e` *`text`*|*`file`*)

Run a Ruby instance with Homebrew's libraries loaded, e.g.
`brew ruby -e "puts :gcc.f.deps"` or `brew ruby script.rb`.

* `-r`:
  Load a library using `require`.
* `-e`:
  Execute the given text string as a script.

### `sh` [*`options`*] [*`file`*]

Homebrew build environment that uses years-battle-hardened
build logic to help your `./configure && make && make install`
and even your `gem install` succeed. Especially handy if you run Homebrew
in an Xcode-only configuration since it adds tools like `make` to your `PATH`
which build systems would not find otherwise.

* `--env`:
  Use the standard `PATH` instead of superenv's when `std` is passed.
* `-c`, `--cmd`:
  Execute commands in a non-interactive shell.

### `sponsors`

Print a Markdown summary of Homebrew's GitHub Sponsors, suitable for pasting into a README.

### `style` [*`options`*] [*`file`*|*`tap`*|*`formula`*]

Check formulae or files for conformance to Homebrew style guidelines.

Lists of *`file`*, *`tap`* and *`formula`* may not be combined. If none are
provided, `style` will run style checks on the whole Homebrew library,
including core code and all formulae.

* `--fix`:
  Fix style violations automatically using RuboCop's auto-correct feature.
* `--display-cop-names`:
  Include the RuboCop cop name for each violation in the output.
* `--reset-cache`:
  Reset the RuboCop cache.
* `--only-cops`:
  Specify a comma-separated *`cops`* list to check for violations of only the listed RuboCop cops.
* `--except-cops`:
  Specify a comma-separated *`cops`* list to skip checking for violations of the listed RuboCop cops.

### `tap-new` [*`options`*] *`user`*`/`*`repo`*

Generate the template files for a new tap.

* `--no-git`:
  Don't initialize a Git repository for the tap.
* `--pull-label`:
  Label name for pull requests ready to be pulled (default: `pr-pull`).
* `--branch`:
  Initialize Git repository with the specified branch name (default: `main`).

### `test` [*`options`*] *`formula`*

Run the test method provided by an installed formula.
There is no standard output or return code, but generally it should notify the
user if something is wrong with the installed formula.

*Example:* `brew install jruby && brew test jruby`

* `--devel`:
  Test the development version of a formula.
* `--HEAD`:
  Test the head version of a formula.
* `--keep-tmp`:
  Retain the temporary files created for the test.
* `--retry`:
  Retry if a testing fails.

### `tests` [*`options`*]

Run Homebrew's unit and integration tests.

* `--coverage`:
  Generate code coverage reports.
* `--generic`:
  Run only OS-agnostic tests.
* `--no-compat`:
  Do not load the compatibility layer when running tests.
* `--online`:
  Include tests that use the GitHub API and tests that use any of the taps for official external commands.
* `--byebug`:
  Enable debugging using byebug.
* `--only`:
  Run only *`test_script`*`_spec.rb`. Appending `:`*`line_number`* will start at a specific line.
* `--seed`:
  Randomise tests with the specified *`value`* instead of a random seed.

### `typecheck`

Check for typechecking errors using Sorbet.

* `--fix`:
  Automatically fix type errors.
* `-q`, `--quiet`:
  Silence all non-critical errors.
* `--update`:
  Update RBI files.
* `--suggest-typed`:
  Try upgrading `typed` sigils.
* `--fail-if-not-changed`:
  Return a failing status code if all gems are up to date and gem definitions do not need a tapioca update.
* `--dir`:
  Typecheck all files in a specific directory.
* `--file`:
  Typecheck a single file.
* `--ignore`:
  Ignores input files that contain the given string in their paths (relative to the input path passed to Sorbet).

### `unbottled` [*`formula`*]

Outputs the unbottled dependents of formulae.

* `--tag`:
  Use the specified bottle tag (e.g. big_sur) instead of the current OS.
* `--dependents`:
  Don't get analytics data and sort by number of dependents instead.
* `--total`:
  Output the number of unbottled and total formulae.

### `unpack` [*`options`*] *`formula`*

Unpack the source files for *`formula`* into subdirectories of the current
working directory.

* `--destdir`:
  Create subdirectories in the directory named by *`path`* instead.
* `--patch`:
  Patches for *`formula`* will be applied to the unpacked source.
* `-g`, `--git`:
  Initialise a Git repository in the unpacked source. This is useful for creating patches for the software.
* `-f`, `--force`:
  Overwrite the destination directory if it already exists.

### `update-license-data` [*`options`*]

 Update SPDX license data in the Homebrew repository.

* `--fail-if-not-changed`:
  Return a failing status code if current license data's version is the same as the upstream. This can be used to notify CI when the SPDX license data is out of date.

### `update-python-resources` [*`options`*] *`formula`*

Update versions for PyPI resource blocks in *`formula`*.

* `-p`, `--print-only`:
  Print the updated resource blocks instead of changing *`formula`*.
* `-s`, `--silent`:
  Suppress any output.
* `--ignore-non-pypi-packages`:
  Don't fail if *`formula`* is not a PyPI package.
* `--version`:
  Use the specified *`version`* when finding resources for *`formula`*. If no version is specified, the current version for *`formula`* will be used.
* `--package-name`:
  Use the specified *`package-name`* when finding resources for *`formula`*. If no package name is specified, it will be inferred from the formula's stable URL.
* `--extra-packages`:
  Include these additional packages when finding resources.
* `--exclude-packages`:
  Exclude these packages when finding resources.

### `update-test` [*`options`*]

Run a test of `brew update` with a new repository clone.
If no options are passed, use `origin/master` as the start commit.

* `--to-tag`:
  Set `HOMEBREW_UPDATE_TO_TAG` to test updating between tags.
* `--keep-tmp`:
  Retain the temporary directory containing the new repository clone.
* `--commit`:
  Use the specified *`commit`* as the start commit.
* `--before`:
  Use the commit at the specified *`date`* as the start commit.

### `vendor-gems`

Install and commit Homebrew's vendored gems.

* `--update`:
  Update all vendored Gems to the latest version.

## GLOBAL CASK OPTIONS

These options are applicable to subcommands accepting a `--cask` flag and all `cask` commands.

* `--appdir`:
  Target location for Applications (default: `/Applications`).

* `--colorpickerdir`:
  Target location for Color Pickers (default: `~/Library/ColorPickers`).

* `--prefpanedir`:
  Target location for Preference Panes (default: `~/Library/PreferencePanes`).

* `--qlplugindir`:
  Target location for QuickLook Plugins (default: `~/Library/QuickLook`).

* `--mdimporterdir`:
  Target location for Spotlight Plugins (default: `~/Library/Spotlight`).

* `--dictionarydir`:
  Target location for Dictionaries (default: `~/Library/Dictionaries`).

* `--fontdir`:
  Target location for Fonts (default: `~/Library/Fonts`).

* `--servicedir`:
  Target location for Services (default: `~/Library/Services`).

* `--input_methoddir`:
  Target location for Input Methods (default: `~/Library/Input Methods`).

* `--internet_plugindir`:
  Target location for Internet Plugins (default: `~/Library/Internet Plug-Ins`).

* `--audio_unit_plugindir`:
  Target location for Audio Unit Plugins (default: `~/Library/Audio/Plug-Ins/Components`).

* `--vst_plugindir`:
  Target location for VST Plugins (default: `~/Library/Audio/Plug-Ins/VST`).

* `--vst3_plugindir`:
  Target location for VST3 Plugins (default: `~/Library/Audio/Plug-Ins/VST3`).

* `--screen_saverdir`:
  Target location for Screen Savers (default: `~/Library/Screen Savers`).

* `--language`:
  Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask's default language. The default value is the language of your system.

## GLOBAL OPTIONS

These options are applicable across multiple subcommands.

* `-d`, `--debug`:
  Display any debugging information.

* `-q`, `--quiet`:
  Make some output more quiet.

* `-v`, `--verbose`:
  Make some output more verbose.

* `-h`, `--help`:
  Show this message.

## OFFICIAL EXTERNAL COMMANDS

### `bundle` [*`subcommand`*]

Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask, Mac App Store and Whalebrew.

`brew bundle` [`install`]
<br>Install and upgrade (by default) all dependencies from the `Brewfile`.

You can specify the `Brewfile` location using `--file` or by setting the `HOMEBREW_BUNDLE_FILE` environment variable.

You can skip the installation of dependencies by adding space-separated values to one or more of the following environment variables: `HOMEBREW_BUNDLE_BREW_SKIP`, `HOMEBREW_BUNDLE_CASK_SKIP`, `HOMEBREW_BUNDLE_MAS_SKIP`, `HOMEBREW_BUNDLE_WHALEBREW_SKIP`, `HOMEBREW_BUNDLE_TAP_SKIP`.

`brew bundle` will output a `Brewfile.lock.json` in the same directory as the `Brewfile` if all dependencies are installed successfully. This contains dependency and system status information which can be useful in debugging `brew bundle` failures and replicating a "last known good build" state. You can opt-out of this behaviour by setting the `HOMEBREW_BUNDLE_NO_LOCK` environment variable or passing the `--no-lock` option. You may wish to check this file into the same version control system as your `Brewfile` (or ensure your version control system ignores it if you'd prefer to rely on debugging information from a local machine).

`brew bundle dump`
<br>Write all installed casks/formulae/images/taps into a `Brewfile` in the current directory.

`brew bundle cleanup`
<br>Uninstall all dependencies not listed from the `Brewfile`.

This workflow is useful for maintainers or testers who regularly install lots of formulae.

`brew bundle check`
<br>Check if all dependencies are installed from the `Brewfile`.

This provides a successful exit code if everything is up-to-date, making it useful for scripting.

`brew bundle list`
<br>List all dependencies present in the `Brewfile`.

By default, only Homebrew dependencies are listed.

`brew bundle exec` *`command`*
<br>Run an external command in an isolated build environment based on the `Brewfile` dependencies.

This sanitized build environment ignores unrequested dependencies, which makes sure that things you didn't specify in your `Brewfile` won't get picked up by commands like `bundle install`, `npm install`, etc. It will also add compiler flags which will help find keg-only dependencies like `openssl`, `icu4c`, etc.

* `--file`:
  Read the `Brewfile` from this location. Use `--file=-` to pipe to stdin/stdout.
* `--global`:
  Read the `Brewfile` from `~/.Brewfile`.
* `-v`, `--verbose`:
  `install` prints output from commands as they are run. `check` lists all missing dependencies.
* `--no-upgrade`:
  `install` won't run `brew upgrade` on outdated dependencies. Note they may still be upgraded by `brew install` if needed.
* `-f`, `--force`:
  `dump` overwrites an existing `Brewfile`. `cleanup` actually performs its cleanup operations.
* `--cleanup`:
  `install` performs cleanup operation, same as running `cleanup --force`.
* `--no-lock`:
  `install` won't output a `Brewfile.lock.json`.
* `--all`:
  `list` all dependencies.
* `--formula`:
  `list` Homebrew dependencies.
* `--cask`:
  `list` Homebrew Cask dependencies.
* `--tap`:
  `list` tap dependencies.
* `--mas`:
  `list` Mac App Store dependencies.
* `--whalebrew`:
  `list` Whalebrew dependencies.
* `--describe`:
  `dump` adds a description comment above each line, unless the dependency does not have a description.
* `--no-restart`:
  `dump` does not add `restart_service` to formula lines.
* `--zap`:
  `cleanup` casks using the `zap` command instead of `uninstall`.

### `services` [*`subcommand`*]

Manage background services with macOS' `launchctl`(1) daemon manager.

If `sudo` is passed, operate on `/Library/LaunchDaemons` (started at boot).
Otherwise, operate on `~/Library/LaunchAgents` (started at login).

[`sudo`] `brew services` [`list`]
<br>List all managed services for the current user (or root).

[`sudo`] `brew services run` (*`formula`*|`--all`)
<br>Run the service *`formula`* without registering to launch at login (or boot).

[`sudo`] `brew services start` (*`formula`*|`--all`)
<br>Start the service *`formula`* immediately and register it to launch at login (or boot).

[`sudo`] `brew services stop` (*`formula`*|`--all`)
<br>Stop the service *`formula`* immediately and unregister it from launching at login (or boot).

[`sudo`] `brew services restart` (*`formula`*|`--all`)
<br>Stop (if necessary) and start the service *`formula`* immediately and register it to launch at login (or boot).

[`sudo`] `brew services cleanup`
<br>Remove all unused services.

* `--all`:
  Run *`subcommand`* on all services.

### `test-bot` [*`options`*] [*`formula`*]

Tests the full lifecycle of a Homebrew change to a tap (Git repository). For example, for a GitHub Actions pull request that changes a formula `brew test-bot` will ensure the system is cleaned and set up to test the formula, install the formula, run various tests and checks on it, bottle (package) the binaries and test formulae that depend on it to ensure they aren't broken by these changes.

Only supports GitHub Actions as a CI provider. This is because Homebrew uses GitHub Actions and it's freely available for public and private use with macOS and Linux workers.

* `--dry-run`:
  Print what would be done rather than doing it.
* `--cleanup`:
  Clean all state from the Homebrew directory. Use with care!
* `--skip-setup`:
  Don't check if the local system is set up correctly.
* `--keep-old`:
  Run `brew bottle --keep-old` to build new bottles for a single platform.
* `--skip-relocation`:
  Run `brew bottle --skip-relocation` to build new bottles that don't require relocation.
* `--local`:
  Ask Homebrew to write verbose logs under `./logs/` and set `$HOME` to `./home/`
* `--tap`:
  Use the Git repository of the given tap. Defaults to the core tap for syntax checking.
* `--fail-fast`:
  Immediately exit on a failing step.
* `-v`, `--verbose`:
  Print test step output in real time. Has the side effect of passing output as raw bytes instead of re-encoding in UTF-8.
* `--test-default-formula`:
  Use a default testing formula when not building a tap and no other formulae are specified.
* `--bintray-org`:
  Upload bottles to the given Bintray organisation.
* `--root-url`:
  Use the specified *`URL`* as the root of the bottle's URL instead of Homebrew's default.
* `--git-name`:
  Set the Git author/committer names to the given name.
* `--git-email`:
  Set the Git author/committer email to the given email.
* `--ci-upload`:
  Use the Homebrew CI bottle upload options.
* `--publish`:
  Publish the uploaded bottles.
* `--skip-recursive-dependents`:
  Only test the direct dependents.
* `--only-cleanup-before`:
  Only run the pre-cleanup step. Needs `--cleanup`.
* `--only-setup`:
  Only run the local system setup check step.
* `--only-tap-syntax`:
  Only run the tap syntax check step.
* `--only-formulae`:
  Only run the formulae steps.
* `--only-cleanup-after`:
  Only run the post-cleanup step. Needs `--cleanup`.

## CUSTOM EXTERNAL COMMANDS

Homebrew, like `git`(1), supports external commands. These are executable
scripts that reside somewhere in the `PATH`, named `brew-`*`cmdname`* or
`brew-`*`cmdname`*`.rb`, which can be invoked like `brew` *`cmdname`*. This allows
you to create your own commands without modifying Homebrew's internals.

Instructions for creating your own commands can be found in the docs:
<https://docs.brew.sh/External-Commands>

## SPECIFYING FORMULAE

Many Homebrew commands accept one or more *`formula`* arguments. These arguments
can take several different forms:

  * The name of a formula:
    e.g. `git`, `node`, `wget`.

  * The fully-qualified name of a tapped formula:
    Sometimes a formula from a tapped repository may conflict with one in
    `homebrew/core`.
    You can still access these formulae by using a special syntax, e.g.
    `homebrew/dupes/vim` or `homebrew/versions/node4`.

  * An arbitrary file:
    Homebrew can install formulae from a local path. It can point to either a
    formula file or a bottle.
    Prefix relative paths with `./` to prevent them being interpreted as a
    formula or tap name.

## SPECIFYING CASKS

Many Homebrew Cask commands accept one or more *`cask`* arguments. These can be
specified the same way as the *`formula`* arguments described in
`SPECIFYING FORMULAE` above.

## ENVIRONMENT

Note that environment variables must have a value set to be detected. For
example, run `export HOMEBREW_NO_INSECURE_REDIRECT=1` rather than just
`export HOMEBREW_NO_INSECURE_REDIRECT`.

- `HOMEBREW_ARCH`
  <br>Linux only: Pass this value to a type name representing the compiler's `-march` option.

  *Default:* `native`.

- `HOMEBREW_ARTIFACT_DOMAIN`
  <br>Prefix all download URLs, including those for bottles, with this variable. For example, `HOMEBREW_ARTIFACT_DOMAIN=http://localhost:8080` will cause a formula with the URL `https://example.com/foo.tar.gz` to instead download from `http://localhost:8080/example.com/foo.tar.gz`.

- `HOMEBREW_AUTO_UPDATE_SECS`
  <br>Automatically check for updates once per this seconds interval.

  *Default:* `300`.

- `HOMEBREW_BAT`
  <br>If set, use `bat` for the `brew cat` command.

- `HOMEBREW_BAT_CONFIG_PATH`
  <br>Use this as the `bat` configuration file.

  *Default:* `$HOME/.bat/config`.

- `HOMEBREW_BINTRAY_KEY`
  <br>Use this API key when accessing the Bintray API (where bottles are stored).

- `HOMEBREW_BINTRAY_USER`
  <br>Use this username when accessing the Bintray API (where bottles are stored).

- `HOMEBREW_BOTTLE_DOMAIN`
  <br>Use this URL as the download mirror for bottles. For example, `HOMEBREW_BOTTLE_DOMAIN=http://localhost:8080` will cause all bottles to download from the prefix `http://localhost:8080/`.

  *Default:* macOS: `https://homebrew.bintray.com/`, Linux: `https://linuxbrew.bintray.com/`.

- `HOMEBREW_BREW_GIT_REMOTE`
  <br>Use this URL as the Homebrew/brew `git`(1) remote.

  *Default:* `https://github.com/Homebrew/brew`.

- `HOMEBREW_BROWSER`
  <br>Use this as the browser when opening project homepages.

  *Default:* `$BROWSER` or the OS's default browser.

- `HOMEBREW_CACHE`
  <br>Use this directory as the download cache.

  *Default:* macOS: `$HOME/Library/Caches/Homebrew`, Linux: `$XDG_CACHE_HOME/Homebrew` or `$HOME/.cache/Homebrew`.

- `HOMEBREW_CASK_OPTS`
  <br>Append these options to all `cask` commands. All `--*dir` options, `--language`, `--require-sha`, `--no-quarantine` and `--no-binaries` are supported. For example, you might add something like the following to your `~/.profile`, `~/.bash_profile`, or `~/.zshenv`:

    `export HOMEBREW_CASK_OPTS="--appdir=~/Applications --fontdir=/Library/Fonts"`

- `HOMEBREW_CLEANUP_MAX_AGE_DAYS`
  <br>Cleanup all cached files older than this many days.

  *Default:* `120`.

- `HOMEBREW_COLOR`
  <br>If set, force colour output on non-TTY outputs.

- `HOMEBREW_CORE_GIT_REMOTE`
  <br>Use this URL as the Homebrew/homebrew-core `git`(1) remote.

  *Default:* macOS: `https://github.com/Homebrew/homebrew-core`, Linux: `https://github.com/Homebrew/linuxbrew-core`.

- `HOMEBREW_CURLRC`
  <br>If set, do not pass `--disable` when invoking `curl`(1), which disables the use of `curlrc`.

- `HOMEBREW_CURL_RETRIES`
  <br>Pass the given retry count to `--retry` when invoking `curl`(1).

  *Default:* `3`.

- `HOMEBREW_CURL_VERBOSE`
  <br>If set, pass `--verbose` when invoking `curl`(1).

- `HOMEBREW_DEVELOPER`
  <br>If set, tweak behaviour to be more relevant for Homebrew developers (active or budding) by e.g. turning warnings into errors.

- `HOMEBREW_DISABLE_LOAD_FORMULA`
  <br>If set, refuse to load formulae. This is useful when formulae are not trusted (such as in pull requests).

- `HOMEBREW_DISPLAY`
  <br>Use this X11 display when opening a page in a browser, for example with `brew home`. Primarily useful on Linux.

  *Default:* `$DISPLAY`.

- `HOMEBREW_DISPLAY_INSTALL_TIMES`
  <br>If set, print install times for each formula at the end of the run.

- `HOMEBREW_EDITOR`
  <br>Use this editor when editing a single formula, or several formulae in the same directory.

    *Note:* `brew edit` will open all of Homebrew as discontinuous files and directories. Visual Studio Code can handle this correctly in project mode, but many editors will do strange things in this case.

  *Default:* `$EDITOR` or `$VISUAL`.

- `HOMEBREW_FAIL_LOG_LINES`
  <br>Output this many lines of output on formula `system` failures.

  *Default:* `15`.

- `HOMEBREW_FORBIDDEN_LICENSES`
  <br>A space-separated list of licenses. Homebrew will refuse to install a formula if it or any of its dependencies has a license on this list.

- `HOMEBREW_FORCE_BREWED_CURL`
  <br>If set, always use a Homebrew-installed `curl`(1) rather than the system version. Automatically set if the system version of `curl` is too old.

- `HOMEBREW_FORCE_BREWED_GIT`
  <br>If set, always use a Homebrew-installed `git`(1) rather than the system version. Automatically set if the system version of `git` is too old.

- `HOMEBREW_FORCE_HOMEBREW_ON_LINUX`
  <br>If set, running Homebrew on Linux will use URLs for macOS. This is useful when merging pull requests for macOS while on Linux.

- `HOMEBREW_FORCE_VENDOR_RUBY`
  <br>If set, always use Homebrew's vendored, relocatable Ruby version even if the system version of Ruby is new enough.

- `HOMEBREW_GITHUB_API_PASSWORD`
  <br>Use this password for authentication with the GitHub API, for features such as `brew search`. This is deprecated in favour of using `HOMEBREW_GITHUB_API_TOKEN`.

- `HOMEBREW_GITHUB_API_TOKEN`
  <br>Use this personal access token for the GitHub API, for features such as `brew search`. You can create one at <https://github.com/settings/tokens>. If set, GitHub will allow you a greater number of API requests. For more information, see: <https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting>

    *Note:* Homebrew doesn't require permissions for any of the scopes, but some developer commands may require additional permissions.

- `HOMEBREW_GITHUB_API_USERNAME`
  <br>Use this username for authentication with the GitHub API, for features such as `brew search`. This is deprecated in favour of using `HOMEBREW_GITHUB_API_TOKEN`.

- `HOMEBREW_GIT_EMAIL`
  <br>Set the Git author and committer email to this value.

- `HOMEBREW_GIT_NAME`
  <br>Set the Git author and committer name to this value.

- `HOMEBREW_INSTALL_BADGE`
  <br>Print this text before the installation summary of each successful build.

  *Default:* The "Beer Mug" emoji.

- `HOMEBREW_LIVECHECK_WATCHLIST`
  <br>Consult this file for the list of formulae to check by default when no formula argument is passed to `brew livecheck`.

  *Default:* `$HOME/.brew_livecheck_watchlist`.

- `HOMEBREW_LOGS`
  <br>Use this directory to store log files.

  *Default:* macOS: `$HOME/Library/Logs/Homebrew`, Linux: `$XDG_CACHE_HOME/Homebrew/Logs` or `$HOME/.cache/Homebrew/Logs`.

- `HOMEBREW_MAKE_JOBS`
  <br>Use this value as the number of parallel jobs to run when building with `make`(1).

  *Default:* The number of available CPU cores.

- `HOMEBREW_NO_ANALYTICS`
  <br>If set, do not send analytics. For more information, see: <https://docs.brew.sh/Analytics>

- `HOMEBREW_NO_AUTO_UPDATE`
  <br>If set, do not automatically update before running `brew install`, `brew upgrade` or `brew tap`.

- `HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK`
  <br>If set, fail on the failure of installation from a bottle rather than falling back to building from source.

- `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK`
  <br>If set, do not check for broken dependents after installing, upgrading or reinstalling formulae.

- `HOMEBREW_NO_COLOR`
  <br>If set, do not print text with colour added.

  *Default:* `$NO_COLOR`.

- `HOMEBREW_NO_COMPAT`
  <br>If set, disable all use of legacy compatibility code.

- `HOMEBREW_NO_EMOJI`
  <br>If set, do not print `HOMEBREW_INSTALL_BADGE` on a successful build.

    *Note:* Will only try to print emoji on OS X Lion or newer.

- `HOMEBREW_NO_GITHUB_API`
  <br>If set, do not use the GitHub API, e.g. for searches or fetching relevant issues after a failed install.

- `HOMEBREW_NO_INSECURE_REDIRECT`
  <br>If set, forbid redirects from secure HTTPS to insecure HTTP.

    *Note:* While ensuring your downloads are fully secure, this is likely to cause from-source SourceForge, some GNU & GNOME-hosted formulae to fail to download.

- `HOMEBREW_NO_INSTALL_CLEANUP`
  <br>If set, `brew install`, `brew upgrade` and `brew reinstall` will never automatically cleanup installed/upgraded/reinstalled formulae or all formulae every 30 days.

- `HOMEBREW_PRY`
  <br>If set, use Pry for the `brew irb` command.

- `HOMEBREW_SKIP_OR_LATER_BOTTLES`
  <br>If set along with `HOMEBREW_DEVELOPER`, do not use bottles from older versions of macOS. This is useful in development on new macOS versions.

- `HOMEBREW_SORBET_RUNTIME`
  <br>If set, enable runtime typechecking using Sorbet.

- `HOMEBREW_SVN`
  <br>Use this as the `svn`(1) binary.

  *Default:* A Homebrew-built Subversion (if installed), or the system-provided binary.

- `HOMEBREW_TEMP`
  <br>Use this path as the temporary directory for building packages. Changing this may be needed if your system temporary directory and Homebrew prefix are on different volumes, as macOS has trouble moving symlinks across volumes when the target does not yet exist. This issue typically occurs when using FileVault or custom SSD configurations.

  *Default:* macOS: `/private/tmp`, Linux: `/tmp`.

- `HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED`
  <br>If set, `brew update` only lists updates to installed software.

- `HOMEBREW_UPDATE_TO_TAG`
  <br>If set, always use the latest stable tag (even if developer commands have been run).

- `HOMEBREW_VERBOSE`
  <br>If set, always assume `--verbose` when running commands.

- `HOMEBREW_DEBUG`
  <br>If set, always assume `--debug` when running commands.

- `HOMEBREW_VERBOSE_USING_DOTS`
  <br>If set, verbose output will print a `.` no more than once a minute. This can be useful to avoid long-running Homebrew commands being killed due to no output.

- `all_proxy`
  <br>Use this SOCKS5 proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.

- `ftp_proxy`
  <br>Use this FTP proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.

- `http_proxy`
  <br>Use this HTTP proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.

- `https_proxy`
  <br>Use this HTTPS proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.

- `no_proxy`
  <br>A comma-separated list of hostnames and domain names excluded from proxying by `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.

- `SUDO_ASKPASS`
  <br>If set, pass the `-A` option when calling `sudo`(8).

## USING HOMEBREW BEHIND A PROXY

Set the `http_proxy`, `https_proxy`, `all_proxy`, `ftp_proxy` and/or `no_proxy`
environment variables documented above.

For example, to use an unauthenticated HTTP or SOCKS5 proxy:

    export http_proxy=http://$HOST:$PORT

    export all_proxy=socks5://$HOST:$PORT

And for an authenticated HTTP proxy:

    export http_proxy=http://$USER:$PASSWORD@$HOST:$PORT

## SEE ALSO

Homebrew Documentation: <https://docs.brew.sh>

Homebrew API: <https://rubydoc.brew.sh>

`git`(1), `git-log`(1)

## AUTHORS

Homebrew's Project Leader is Mike McQuaid.

Homebrew's Project Leadership Committee is Misty De Meo, Shaun Jackman, Jonathan Chang, Sean Molenaar and Markus Reiter.

Homebrew's Technical Steering Committee is Michka Popoff, FX Coudert, Markus Reiter, Misty De Meo and Mike McQuaid.

Homebrew/brew's Linux maintainers are Michka Popoff, Shaun Jackman, Dawid Dziurla, Issy Long and Maxim Belkin.

Homebrew's other current maintainers are Claudia Pellegrino, Zach Auten, Rui Chen, Vitor Galvao, Caleb Xu, Gautham Goli, Steven Peters, Bo Anderson, William Woodruff, Igor Kapkov, Sam Ford, Alexander Bayandin, Izaak Beekman, Eric Knibbe, Viktor Szakats, Thierry Moisan, Steven Peters, Tom Schoonjans, Issy Long, CoreCode, Randall, Rylan Polster, SeekingMeaning, William Ma and Dustin Rodrigues.

Former maintainers with significant contributions include Jan Viljanen, JCount, commitay, Dominyk Tiller, Tim Smith, Baptiste Fontaine, Xu Cheng, Martin Afanasjew, Brett Koonce, Charlie Sharpsteen, Jack Nagel, Adam Vandenberg, Andrew Janke, Alex Dunn, neutric, Tomasz Pajor, Uladzislau Shablinski, Alyssa Ross, ilovezfs, Chongyu Zhu and Homebrew's creator: Max Howell.

## BUGS

See our issues on GitHub:

  * **Homebrew/brew**:
    <br><https://github.com/Homebrew/brew/issues>

  * **Homebrew/homebrew-core**:
    <br><https://github.com/Homebrew/homebrew-core/issues>

  * **Homebrew/homebrew-cask**:
    <br><https://github.com/Homebrew/homebrew-cask/issues>

[SYNOPSIS]: #SYNOPSIS "SYNOPSIS"
[DESCRIPTION]: #DESCRIPTION "DESCRIPTION"
[ESSENTIAL COMMANDS]: #ESSENTIAL-COMMANDS "ESSENTIAL COMMANDS"
[COMMANDS]: #COMMANDS "COMMANDS"
[DEVELOPER COMMANDS]: #DEVELOPER-COMMANDS "DEVELOPER COMMANDS"
[GLOBAL CASK OPTIONS]: #GLOBAL-CASK-OPTIONS "GLOBAL CASK OPTIONS"
[GLOBAL OPTIONS]: #GLOBAL-OPTIONS "GLOBAL OPTIONS"
[OFFICIAL EXTERNAL COMMANDS]: #OFFICIAL-EXTERNAL-COMMANDS "OFFICIAL EXTERNAL COMMANDS"
[CUSTOM EXTERNAL COMMANDS]: #CUSTOM-EXTERNAL-COMMANDS "CUSTOM EXTERNAL COMMANDS"
[SPECIFYING FORMULAE]: #SPECIFYING-FORMULAE "SPECIFYING FORMULAE"
[SPECIFYING CASKS]: #SPECIFYING-CASKS "SPECIFYING CASKS"
[ENVIRONMENT]: #ENVIRONMENT "ENVIRONMENT"
[USING HOMEBREW BEHIND A PROXY]: #USING-HOMEBREW-BEHIND-A-PROXY "USING HOMEBREW BEHIND A PROXY"
[SEE ALSO]: #SEE-ALSO "SEE ALSO"
[AUTHORS]: #AUTHORS "AUTHORS"
[BUGS]: #BUGS "BUGS"

[-]: -.html
