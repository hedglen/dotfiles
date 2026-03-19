# foobar2000 Portable Installation

## Installation Location

**Portable installation:** `C:\Users\rjh\workstation\tools\foobar2000`

The portable version stores all configuration, components, and user data in the `profile` subdirectory, making it easy to backup and sync.

## Current Setup

### Installed Components

**Core Components:**
- **Columns UI** - Advanced UI framework
- **Georgia-Reborn** - Modern theme with customizable layouts
- **Spider Monkey Panel** - JavaScript panel framework for advanced customization

**Lyrics & Metadata:**
- **ESLyric** - Lyrics display and synchronization
- **MusicBrainz Tagger** - Automatic metadata tagging
- **Enhanced Playcount** - Advanced playback statistics

**Audio Features:**
- **Parametric EQ** - Built-in equalizer
- **DSP Effects** - Audio processing
- **Converter** - Format conversion utility

**Network & Integration:**
- **UPnP Output** - Network streaming to DLNA/UPnP devices
- **Last.fm Scrobbler** - Scrobbling support

**Utilities:**
- **Audio Wizard** - Setup and configuration wizard
- **UI Wizard** - Interface customization helper
- **CUE Fixer** - CUE sheet management

### Directory Structure

```
C:\Users\rjh\workstation\tools\foobar2000\
├── foobar2000.exe          # Main executable
├── portable_mode_enabled   # Enables portable mode
├── components/             # Installed components
├── profile/                # User configuration and data
│   ├── configuration/      # Component settings
│   ├── library-v2.0/       # Media library database
│   ├── playlists-v2.0/     # Saved playlists
│   ├── georgia-reborn/     # Georgia-Reborn theme data
│   ├── eslyric-data/       # Lyrics cache
│   ├── cache/              # Temporary cache
│   └── theme.fth           # Active theme file
├── themes/                 # Theme files
└── doc/                    # Documentation
```

## Configuration Files

- **config.sqlite** - Main configuration database
- **metadb.sqlite** - Media library metadata
- **foo_ui_columns.dll.cfg** - Columns UI settings
- **foo_uie_eslyric.dll.cfg** - ESLyric configuration
- **foo_scrobble.dll.cfg** - Last.fm scrobbler settings
- **foo_enhanced_playcount.dll.cfg** - Playback statistics

## Backup & Sync

To backup your foobar2000 configuration:

1. **Full backup:** Copy the entire `C:\Users\rjh\workstation\tools\foobar2000` folder
2. **Config only:** Copy the `profile` folder
3. **Playlists only:** Copy `profile\playlists-v2.0`

## Updating Components

1. Download new component `.fb2k-component` files
2. Double-click to install, or drag into foobar2000 window
3. Restart foobar2000 to load new components

## Theme Management

Current theme: **Georgia-Reborn** with **Premium Gold Executive** color scheme

### Premium Gold Executive Theme

A rich, dark gold aesthetic with executive feel featuring:
- Deep charcoal black backgrounds (#0D0D0D, #121212)
- Luxurious gold accents (#D4AF37, #FFD700)
- Waveform seekbar with gold gradient
- Spectrum analyzer with bronze-to-gold gradient
- Warm, balanced EQ preset
- Professional typography

**Setup Guide:** See `themes/premium-gold/QUICKSTART.md`
**Full Documentation:** See `themes/premium-gold/README.md`
**Color Reference:** See `themes/premium-gold/colors.ini`

Theme files are stored in:
- `profile\georgia-reborn\` - Theme-specific data
- `profile\theme.fth` - Active theme configuration
- `themes\premium-gold\` - Premium Gold theme resources

## Music Library

Library location: `D:\Media\Music\`

The library is monitored and automatically updates when files are added or changed.

## Network Features

**UPnP/DLNA Streaming:**
- Configured via `foo_out_upnp-config-v2.txt`
- Allows streaming to network devices

## Performance Notes

Portable installation benefits:
- ✅ Self-contained - no registry entries
- ✅ Easy to backup and restore
- ✅ Can run from external drive
- ✅ Multiple installations possible
- ✅ Clean uninstall (just delete folder)

## Migration from Standard Installation

If migrating from `C:\Program Files\foobar2000`:

1. Export your library and playlists
2. Copy components from old installation
3. Import library and playlists to portable version
4. Reconfigure preferences as needed
