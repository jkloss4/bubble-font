# BubbleFont

Sets the font size of chat bubbles in World of Warcraft, including the speech bubbles NPCs use while questing and
players' `/say` and `/yell` bubbles (they all share Blizzard's `ChatBubbleFont`).

Retail (Interface 120100) and WoW: Forever (Interface 16001).

## Features

- Font size from 6 to 24 pt, set from Options → AddOns → BubbleFont (Blizzard's slider with arrow steppers).
- "Reset to default" returns to the game's own bubble font size.
- The size is saved and reapplied at login. Bubbles size themselves to their text when they appear, so a change
  applies to every bubble shown afterwards (ones already on screen keep their size).
- The options page is built from the addon's own frames rather than Blizzard's pooled Settings controls, so it
  can't taint Blizzard's own settings pages.

Slash commands: `/bubblefont` (options), `/bubblefont <size>` (set the size), `/bubblefont reset`.

## Install

Download `BubbleFont-<version>.zip` from the [latest release](../../releases/latest) and extract the `BubbleFont`
folder into `World of Warcraft\_retail_\Interface\AddOns\` (for WoW: Forever, `_classic_beta_` instead of `_retail_`).

An addon manager that installs from GitHub releases (e.g. WowUp: *Install from URL* with this repo's URL) can also
install and update it, **but only if the repository is public**.

To update from the command line (works for a private repo, needs `gh auth login` once):

```powershell
.\scripts\update-from-release.ps1
```

## Developing / releasing

- Test local changes: `.\scripts\install-local.ps1` copies the addon folder into `AddOns`, then `/reload`.
- After a WoW patch: bump `## Interface:` in `BubbleFont/BubbleFont.toc`.
- Release: `git tag v1.0.1 && git push --tags`. The [Release workflow](.github/workflows/release.yml) stamps the
  version into the TOC, builds the zip (with a `release.json` so addon managers see it's a retail and Forever build), and
  publishes the GitHub release.

## License

MIT ([`LICENSE`](LICENSE), also included in the addon folder).
