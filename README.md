# Uyama dotfiles

## Contents

What's in there?

- all my `brew` dependencies. See [`Brewfile`](https://github.com/Uyama0/dotfiles/blob/main/Brewfile)
- all my `sheel` configuration. See [`zshrc`](https://github.com/Uyama0/dotfiles/blob/main/zsh/zshrc)

## How to use

```sh
# create symbolic links for dotfiles

sh scripts/bootstrap.sh
```

```sh
# setup initial environment

sh scripts/symlinks.sh
```

```sh
# install Brewfile environment

brew bundle install
```
