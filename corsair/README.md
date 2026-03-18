# corsair

Scimitar Elite WL SE profile manager. Backs up iCUE profiles into this repo with git version history and named snapshots.

## Usage

```powershell
scimitar backup                    # back up current profiles, git commit
scimitar backup -Name gaming       # same, plus tag as 'scimitar/gaming'
scimitar list                      # list all backups with dates and tags
scimitar status                    # diff live profiles vs last backup
scimitar diff                      # diff last two backups
scimitar diff -From gaming         # diff 'gaming' tag vs HEAD
scimitar diff -From gaming -To office  # diff two named tags
scimitar restore                   # restore from last backup (HEAD)
scimitar restore -Name gaming      # restore from 'gaming' tag
```

## What gets backed up

| File | Source |
|------|--------|
| `hw-slot-1.cueprofiledata` | On-board hardware slot 1 |
| `hw-slot-2.cueprofiledata` | On-board hardware slot 2 |
| `hw-slot-3.cueprofiledata` | On-board hardware slot 3 |
| `software.cueprofiledata`  | iCUE software profile |
| `config.cuecfg`            | Device settings (DPI, angle snap, lift height, brightness) |

## Notes

- Each `backup` produces one git commit on `master`. Push with `git push` to sync to GitHub.
- Named snapshots are lightweight git tags prefixed `scimitar/` — visible in `git tag -l 'scimitar/*'`.
- `restore` requires iCUE to be closed first. Relaunch iCUE after restoring.
- `diff` shows button binding changes and device setting changes. Lighting is reported as changed/unchanged only.
