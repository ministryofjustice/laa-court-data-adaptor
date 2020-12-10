# Homebrew Shell Completion

Homebrew comes with completion definitions for the `brew` command. Some packages also provide completion definitions for their own programs.

`zsh`, `bash` and `fish` are currently supported.

You must configure your shell to enable its completion support. This is because the Homebrew-managed completions are stored under `HOMEBREW_PREFIX` which your system shell may not be aware of, and since it is difficult to automatically configure `bash` and `zsh` completions in a robust manner, the Homebrew installer does not do it for you.

## Configuring Completions in `bash`

To make Homebrew's completions available in `bash`, you must source the definitions as part of your shell's startup. Add the following to your `~/.bash_profile` (or, if it doesn't exist, `~/.profile):

```sh
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi
fi
```

If you install the `bash-completion` formula, this will automatically source the completions' initialisation script (so you do not need to follow the instructions in the caveats).

If you are using the `bash` formula as your shell (i.e. `bash` >= v4) you should use the `bash-completion@2` formula instead.


## Configuring Completions in `zsh`

To make Homebrew's completions available in `zsh`, you must get the Homebrew-managed zsh site-functions on your `FPATH` before initialising `zsh`'s completion facility. Add the following to your `~/.zshrc` file:

```sh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi
```

This must be done before `compinit` is called. Note that if you are using Oh My Zsh, it will call `compinit` for you, so this must be done before you call `oh-my-zsh.sh`.

You may also need to forcibly rebuild `zcompdump`:

```sh
  rm -f ~/.zcompdump; compinit
```

Additionally, if you receive "zsh compinit: insecure directories" warnings when attempting to load these completions, you may need to run this:

```sh
  chmod -R go-w "$(brew --prefix)/share"
```

## Configuring Completions in `fish`

No configuration is needed if you're using Homebrew's `fish`. Friendly!

If your `fish` is from somewhere else, add the following to your `~/.config/fish/config.fish`:

```sh
if test -d (brew --prefix)"/share/fish/completions"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end
```
