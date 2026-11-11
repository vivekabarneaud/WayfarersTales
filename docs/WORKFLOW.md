# Workflow

How we work on Wayfarer's Tales, so we're always on the same page.

## Branches
- **`dev`**: all work happens here, always. It must always load in game without errors.
- **`main`**: released versions only. We merge `dev` into `main` when we release.
- Claude commits after each change and pushes `dev` to GitHub at the end of each session.
- Any other branch is deleted once it's merged (only `dev` and `main` stay).

## Commit messages
- Written in player language: what a player would notice ("Fishing: new lines for your first catch").
- Commits a player would never notice start with **`[dev]`**: tools, review page, field notes, docs, fixes to things that were never released.
- The commits on `dev` that aren't in `main` yet (`git log main..dev`) are the "Unreleased" changes.

## Versions
- `0.MINOR.PATCH` in `WayfarersTales.toc`.
- MINOR goes up for a build with new features or lines, PATCH for fixes only.
- Bumped for every playtest build, so error reports tell which build caused them.

## Lines
- New ideas and lines: discussed first, then added as **drafts** (`draft = true`) so they can be reviewed on the review page and heard in game at the same time.
- During the beta (`D.DRAFTS_LIVE = true` in Data.lua), drafts and rewrite proposals play for everyone: the community hears them and flags what feels wrong. They keep their `draft` mark until confirmed. With `D.DRAFTS_LIVE` off, they play in dev mode only.
- Approved: the draft flag is removed. Rejected: the line is deleted. Tweaked: rewritten, stays a draft until approved.

## Who sees what
- **Players**: no dev windows, no dev data written to the saved file.
- **Testers** (`/wt tester`): Homework window, Bizarre button, report with what they choose to share (flagged lines, notes, proposals, roofs) plus errors.
- **Us (dev)**: on automatically when the addon runs from the repo; not possible to switch on in game. Drafts play, plus the "possible lines" window and the weather log.

## Playtest notes
- Testers paste their report (on Discord, once it exists). The user brings it to Claude.
- Each handled note is logged in `docs/field-notes.md` with a status (done / todo / wontfix / info), and its time goes into `Processed.lua` so the addon clears it in game.
- Ideas for later go into `TODO.md` (private, not in git).

## Sessions
- **Start**: Claude checks the branch (`dev`), git status, `TODO.md` and the field notes.
- **End**: commit, push `dev`, and a short "what to test" list.

## Release checklist
1. On `dev`: every note in `docs/field-notes.md` is done / wontfix / info (remaining todos fixed or moved to `TODO.md`).
2. No errors in the last playtest report.
3. Every text exists in English and French.
4. Dev and tester features are off by default; no drafts play for players.
5. `.toc`: version bumped, Interface number still matches the game.
6. Changelog: Claude reads `git log main..dev`, skips `[dev]` commits, groups the rest by feature and writes the new entry at the top of `CHANGELOG.md`. The user approves the text.
7. Merge `dev` into `main`, tag it, push both. Tag names: `vX.Y.Z-beta` while in beta, `vX.Y.Z` for full releases (the packager reads "beta" / "alpha" in the tag to set the release type).
8. CurseForge's packager builds and publishes the zip by itself when it sees the new tag (`.pkgmeta`: leaves out `Dev.lua`, `docs/`, `tools/`; changelog from `CHANGELOG.md`). Check the file appeared on the project's Files tab.
9. Announce on Discord.

Before the first CurseForge release: the Discord server must be ready (reports + ideas).
