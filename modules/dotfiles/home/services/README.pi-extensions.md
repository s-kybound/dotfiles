# pi-extensions.scm

Declares pi coding-agent extensions as data instead of running `pi install`.
Generates `~/.pi/agent/settings.json`, and Guix-verifies/fetches the
extensions themselves (git-fetch for git sources, a fixed-output derivation
for npm sources).

Used from `home-config.scm`:

```scheme
(define %pi-extensions
  (list
    (pi-extension (type 'git)
                  (source "github.com/user/repo")
                  (ref "COMMIT_SHA")
                  (hash "BASE32_HASH"))
    (pi-extension (type 'npm) (source "package-name") (version "^1.2.3"))
    (pi-extension (type 'local) (source (local-file "../my-ext" #:recursive? #t)))))
```

...and spliced into the home services list via:

```scheme
(pi-extensions->home-services
  %pi-extensions
  #:default-provider "local-qwen"
  #:default-model "qwen3.6-35b-a3b"
  #:npm-hash "BASE32_HASH")
```

## Adding a git-sourced extension

1. Clone it at the exact commit/tag you want:
   ```
   git clone https://github.com/user/repo /tmp/checkout
   cd /tmp/checkout && git checkout <commit-or-tag>
   ```
2. Hash it: `guix hash -x -r /tmp/checkout`
3. Add a `pi-extension` entry with `type 'git`, `source` = `"host/owner/repo"`
   (no `https://`), `ref` = the commit/tag, `hash` = the output of step 2.

## Adding an npm-sourced extension

1. Add a `pi-extension` entry with `type 'npm`, `source` = the npm package
   name, `version` = a semver range (e.g. `"^1.2.3"`).
2. `guix home build home-config.scm --dry-run` and note the `.drv` path for
   `pi-extensions-node-modules`.
3. `guix build <that.drv> -K` — it will fail (the old `#:npm-hash` no longer
   matches) but print the real hash: `actual hash: ...`.
4. Update `#:npm-hash` in `home-config.scm` with that value.

All npm extensions share one hash, since they're resolved together into one
`node_modules`. Adding/removing/changing any of them means repeating steps
2-4.

## Adding a local extension

For an extension you're developing in place rather than fetching. `source`
is a `local-file` object (usually `#:recursive? #t` for a directory), no
hash needed - Guix hashes local-file content automatically.

pi records local installs as a path *relative to `~/.pi/agent`*, no matter
what form you gave it (verified by testing `pi install` against a real
absolute path). This module computes the same relative path from the
`local-file`'s resolved store location, so the result matches what
`pi install ./some/path` would have written.

## Adding a skill

Skills are a separate mechanism from extensions (a different `settings.json`
key, `"skills"` instead of `"packages"`): plain filesystem paths, recursively
scanned for `SKILL.md`. No copying needed either way, since a Guix store
path is immutable - the path just gets listed directly.

```scheme
(pi-skill (type 'git)
          (source "github.com/user/skills-repo")
          (ref "COMMIT_SHA")
          (hash "BASE32_HASH"))
```

or `(type 'local) (source (local-file "../my-skills" #:recursive? #t))`.
Hash computation for git sources is the same as for extensions (see above).
Pass the list via `#:skills` to `pi-extensions->home-services`.

## Removing an extension

Delete its `pi-extension` entry from `%pi-extensions`. Nothing else to
clean up — `guix home reconfigure` replaces `~/.pi/agent/settings.json`,
`npm/`, and the relevant `git/` checkout wholesale each time.

## Applying changes

`guix home reconfigure home-config.scm` after any edit here. Don't run
`pi install`/`pi remove` and expect it to stick — the next reconfigure
overwrites `settings.json`, `npm/package.json`, `npm/package-lock.json`,
`npm/node_modules`, and each declared `git/` checkout with what's declared
here.

## Not yet supported

- `ssh://` sources (private repos over SSH) - TODO.
