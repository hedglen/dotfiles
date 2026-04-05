# foobar2000 Astra-Inspired Theme

Visually stunning foobar2000 setup with deep colors, vibrant visualizations, and immersive UI inspired by [Astra](https://github.com/Boof2015/astra).

## Current Installation

**Portable installation (this machine):** `C:\Users\rjh\workstation\tools\foobar2000`  
**Canonical path:** `$HOME\workstation\tools\foobar2000` (substitute your profile).

Using Georgia-Reborn theme with enhanced components. See [PORTABLE-SETUP.md](PORTABLE-SETUP.md) for detailed configuration.

## Features

- **Deep, vibrant color scheme** - Dark theme with neon accents and dynamic colors
- **Real-time visualizers** - Spectrum analyzer, oscilloscope, and waveform displays
- **Album art integration** - Large, prominent artwork with ambient glow effects
- **Parametric EQ** - Visual equalizer with frequency response curves
- **Modern UI layout** - Clean, immersive interface with smooth animations

## Required Components

Install these foobar2000 components for the full experience:

### Essential Components
1. **Columns UI** - Advanced UI framework
   - Download: https://www.foobar2000.org/components/view/foo_ui_columns
   
2. **Musical Spectrum** - Real-time spectrum analyzer
   - Download: https://www.foobar2000.org/components/view/foo_musical_spectrum

3. **Waveform Seekbar** - Visual waveform display
   - Download: https://www.foobar2000.org/components/view/foo_wave_seekbar

4. **Biography** - Artist info and images
   - Download: https://www.foobar2000.org/components/view/foo_biography

5. **Equalizer** - Parametric EQ with visualization
   - Download: https://www.foobar2000.org/components/view/foo_dsp_effect

### Visual Enhancement Components
6. **Panel Stack Splitter** - Advanced panel layout
   - Download: https://www.foobar2000.org/components/view/foo_uie_panel_splitter

7. **Facets** - Advanced library browser
   - Download: https://www.foobar2000.org/components/view/foo_facets

8. **Playback Statistics** - Track play counts and ratings
   - Download: https://www.foobar2000.org/components/view/foo_playcount

9. **Lyric Show Panel 3** - Synchronized lyrics display
   - Download: https://www.foobar2000.org/components/view/foo_uie_lyrics3

10. **OpenLyrics** - Automatic lyric fetching
    - Download: https://www.foobar2000.org/components/view/foo_openlyrics

## Installation

### Automated (Recommended)
Run the installation script from your dotfiles directory:
```powershell
.\foobar2000\install-theme.ps1
```

### Manual Installation
1. Install foobar2000 via winget (already in your package list)
2. Download and install all required components from the links above
3. Copy theme files:
   ```powershell
   Copy-Item -Path ".\foobar2000\theme\*" -Destination "$env:APPDATA\foobar2000" -Recurse -Force
   ```
4. Restart foobar2000
5. Go to `File > Preferences > Display > Columns UI`
6. Import the layout: `.\foobar2000\theme\astra-layout.fcl`

## Color Scheme

Inspired by Astra's deep, vibrant aesthetic:

- **Background**: `#0A0A0F` - Deep space black
- **Primary Accent**: `#BF00FF` - Vibrant purple/magenta
- **Secondary Accent**: `#39FF14` - Neon green
- **Tertiary Accent**: `#FF6000` - Bright orange
- **Text Primary**: `#FFFFFF` - Pure white
- **Text Secondary**: `#AAAAAA` - Light gray
- **Panel Background**: `#151520` - Slightly lighter black
- **Highlight**: `#6A0DAD` - Deep purple

## Visualizer Settings

### Spectrum Analyzer
- **Style**: Bars with glow effect
- **Color Gradient**: Purple → Magenta → Orange
- **FFT Size**: 8192 (high resolution)
- **Smoothing**: Medium
- **Peak Hold**: Enabled with fade

### Waveform Seekbar
- **Style**: Filled waveform
- **Color**: Neon green (#39FF14)
- **Background**: Transparent with subtle grid
- **RMS Display**: Enabled

### Oscilloscope (via Musical Spectrum)
- **Mode**: Oscilloscope
- **Color**: Cyan with glow
- **Trigger**: Auto with zero-crossing

## Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│  Now Playing - Artist · Album · Track                   │
├──────────────┬──────────────────────────────────────────┤
│              │  ┌────────────────────────────────────┐  │
│   Album      │  │  Spectrum Analyzer                 │  │
│   Art        │  │  (Real-time frequency display)     │  │
│   (Large)    │  └────────────────────────────────────┘  │
│              │  ┌────────────────────────────────────┐  │
│              │  │  Waveform Seekbar                  │  │
│              │  └────────────────────────────────────┘  │
├──────────────┼──────────────────────────────────────────┤
│  Library     │  Playlist / Queue                        │
│  Browser     │  (with metadata columns)                 │
│  (Facets)    │                                          │
├──────────────┴──────────────────────────────────────────┤
│  Playback Controls · Volume · EQ Toggle                 │
└─────────────────────────────────────────────────────────┘
```

## Customization

### Change Accent Colors
Edit `theme\colors.cfg` and modify the color values, then restart foobar2000.

### Adjust Visualizer Sensitivity
1. Right-click on the spectrum analyzer
2. Select "Settings"
3. Adjust gain and frequency range

### Modify Layout
1. `File > Preferences > Display > Columns UI > Layout`
2. Edit panels and splitters
3. Export your custom layout

## Tips for Maximum Immersion

1. **Enable fullscreen mode**: `View > Fullscreen` (F11)
2. **Use high-quality audio files**: FLAC, WAV, or high-bitrate MP3
3. **Enable gapless playback**: `Preferences > Playback > Gapless`
4. **Set up ReplayGain**: `Preferences > Playback > ReplayGain`
5. **Configure output device**: `Preferences > Playback > Output`

## Keyboard Shortcuts

- `Space` - Play/Pause
- `Z` - Previous track
- `X` - Play
- `C` - Pause
- `V` - Stop
- `B` - Next track
- `F11` - Fullscreen
- `Ctrl+P` - Preferences
- `Ctrl+F` - Search library

## Troubleshooting

### Visualizers not showing
- Ensure Musical Spectrum component is installed
- Check that playback is active
- Verify audio output device is working

### Theme colors not applying
- Restart foobar2000 after copying theme files
- Check that Columns UI is set as the active UI

### Layout looks broken
- Reset to default layout and re-import
- Ensure all required components are installed

## Credits

Inspired by [Astra](https://github.com/Boof2015/astra) by Boof2015 - an audiophile music player with stunning visualizations and modern design.
