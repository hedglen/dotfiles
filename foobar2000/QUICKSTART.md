# Quick Start Guide - foobar2000 Astra Theme

Get your foobar2000 looking stunning in 5 minutes.

## Step 1: Install foobar2000

Already done! It's in your winget packages list.

```powershell
winget install PeterPawlowski.foobar2000
```

## Step 2: Run the Installer

From your dotfiles directory:

```powershell
cd C:\Users\rjh\workstation\dotfiles\foobar2000
.\install-theme.ps1
```

This will guide you through the installation process.

## Step 3: Install Required Components

Download and install these components (double-click or drag into foobar2000):

**Essential (Required):**
1. [Columns UI](https://www.foobar2000.org/components/view/foo_ui_columns)
2. [Musical Spectrum](https://www.foobar2000.org/components/view/foo_musical_spectrum)
3. [Waveform Seekbar](https://www.foobar2000.org/components/view/foo_wave_seekbar)

**Recommended:**
4. [Panel Stack Splitter](https://www.foobar2000.org/components/view/foo_uie_panel_splitter)
5. [Biography](https://www.foobar2000.org/components/view/foo_biography)
6. [Facets](https://www.foobar2000.org/components/view/foo_facets)

## Step 4: Switch to Columns UI

1. Open foobar2000
2. `File` → `Preferences` → `Display` → `Default User Interface`
3. Select **Columns UI**
4. Click **OK** and restart foobar2000

## Step 5: Import the Layout

1. `File` → `Preferences` → `Display` → `Columns UI` → `Layout`
2. Click **Import**
3. Navigate to: `C:\Users\rjh\AppData\Roaming\foobar2000\astra-theme\astra-layout.fcl`
4. Click **OK**

## Step 6: Configure Visualizers

### Spectrum Analyzer
1. Right-click on the spectrum area
2. Select **Musical Spectrum** → **Settings**
3. Copy settings from: `theme\visualizer-settings.txt`

### Waveform Seekbar
1. Right-click on the waveform area
2. Select **Waveform Seekbar** → **Settings**
3. Set colors:
   - Foreground: `#39FF14`
   - Progress: `#BF00FF`
   - Background: `#0A0A0F`

## Step 7: Import EQ Preset (Optional)

1. `File` → `Preferences` → `Playback` → `DSP Manager`
2. Add **Equalizer**
3. Click **Import** and select: `theme\equalizer-preset.feq`

## Done! 🎉

Your foobar2000 should now have:
- ✅ Deep, vibrant color scheme
- ✅ Real-time spectrum analyzer
- ✅ Waveform seekbar
- ✅ Large album art with glow
- ✅ Clean, immersive layout

## Tips

- **Fullscreen**: Press `F11` for immersive mode
- **Search**: `Ctrl+F` to find tracks instantly
- **Queue**: Middle-click tracks to queue them
- **Customize**: Right-click any panel to adjust settings

## Troubleshooting

**Visualizers not showing?**
- Make sure audio is playing
- Check that Musical Spectrum component is installed
- Verify output device is working

**Colors look wrong?**
- Ensure you imported the layout file
- Check Columns UI is selected as the interface
- Restart foobar2000

**Layout is broken?**
- Re-import the layout file
- Make sure all components are installed
- Reset to default and try again

## Next Steps

- Add your music library: `File` → `Preferences` → `Media Library`
- Customize colors: Edit `theme\colors.cfg`
- Explore components: Check the main README for more options
