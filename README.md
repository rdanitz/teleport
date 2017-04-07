# teleport
Lets you jump around directories by pre-defined mnemonics.
Heavily inspired by https://github.com/bollu/teleport.

## Dependencies
- guile 2.0+
- guile-dbi
- guile-dbd-sqlite3

## Setup
Put the `teleport.sh` script somewhere in `$PATH`, then add this to your profile:
```sh
function tp() {
  $(teleport.sh "$@")
}
```

Initialize the database:
```sh
tp --init
```

Mark the current working dir:
```sh
cd /some/long/path
tp --add here be dragons
```

Jump around:
```sh
cd ~
tp here be dragons
```

## Autocompletion (zsh)

Put the `_tp` script somewhere in `$fpath`.
