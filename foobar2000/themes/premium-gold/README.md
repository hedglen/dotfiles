# Premium Gold Executive Theme for foobar2000

A rich, dark gold aesthetic with premium executive feel featuring waveforms, equalizer, and sophisticated visual elements.

## Theme Overview

**Color Palette:**
- **Primary Background:** Deep charcoal black (#0D0D0D, #121212)
- **Secondary Background:** Rich dark gray (#1A1A1A, #1E1E1E)
- **Accent Gold:** Luxurious gold (#D4AF37, #FFD700)
- **Highlight Gold:** Bright metallic gold (#F4C430)
- **Text Primary:** Warm off-white (#F5F5DC)
- **Text Secondary:** Muted gold (#C9B037)
- **Borders:** Subtle gold (#8B7355)

## Georgia-Reborn Configuration

### Theme Settings

1. **Open Georgia-Reborn Options:**
   - Right-click on foobar2000 window
   - Select `Options` → `Georgia-Reborn`

2. **Theme Configuration:**
   - **Theme:** Custom
   - **Theme Preset:** Dark
   - **Primary Color:** Gold (#D4AF37)
   - **Accent Color:** Bright Gold (#FFD700)

### Color Scheme Settings

**Background Colors:**
```
Main Background: #0D0D0D
Panel Background: #121212
Sidebar Background: #1A1A1A
Player Bar Background: #1E1E1E
```

**Text Colors:**
```
Primary Text: #F5F5DC (Beige/Cream)
Secondary Text: #C9B037 (Muted Gold)
Highlight Text: #FFD700 (Gold)
Playing Track: #F4C430 (Bright Gold)
```

**Accent Colors:**
```
Primary Accent: #D4AF37 (Gold)
Secondary Accent: #8B7355 (Bronze)
Border Color: #3D3D3D
Selection Background: #2A2A2A
Selection Text: #FFD700
```

### Waveform Seekbar Configuration

**ESLyric Waveform Settings:**

1. **Enable Waveform Display:**
   - Preferences → Tools → ESLyric → Waveform
   - Enable "Show waveform seekbar"

2. **Waveform Colors:**
   ```
   Background: #121212
   Waveform Color: #D4AF37 (Gold)
   Progress Color: #FFD700 (Bright Gold)
   Cursor Color: #F4C430
   Grid Lines: #2A2A2A
   ```

3. **Waveform Style:**
   - Style: Filled
   - Smoothing: Medium
   - Peak Hold: Enabled
   - Reflection: Subtle (20% opacity)

### Spectrum Analyzer Configuration

**For premium executive look:**

1. **Spectrum Settings:**
   ```
   Bar Count: 32 (cleaner, more refined)
   Bar Width: Medium
   Bar Spacing: 2px
   Smoothing: High (smooth, elegant motion)
   ```

2. **Spectrum Colors:**
   ```
   Gradient Start (Low): #8B7355 (Bronze)
   Gradient Mid: #D4AF37 (Gold)
   Gradient End (High): #FFD700 (Bright Gold)
   Peak Hold Color: #F4C430
   Background: #0D0D0D
   ```

3. **Visual Effects:**
   - Peak Hold: Enabled (3 second decay)
   - Glow Effect: Subtle (15% intensity)
   - Reflection: Enabled (25% opacity)
   - Border: 1px solid #3D3D3D

### Equalizer Display

**Parametric EQ Visualization:**

1. **Enable EQ Display:**
   - Preferences → Playback → DSP Manager
   - Add "Equalizer" component
   - Enable "Show frequency response curve"

2. **EQ Visual Style:**
   ```
   Curve Color: #D4AF37 (Gold)
   Grid Color: #2A2A2A
   Background: #121212
   Active Band: #FFD700
   Text Labels: #C9B037
   ```

3. **Recommended EQ Preset (Warm Executive):**
   ```
   32 Hz:   +2 dB  (Deep warmth)
   64 Hz:   +1 dB  (Bass foundation)
   125 Hz:   0 dB  (Neutral)
   250 Hz:  -1 dB  (Clarity)
   500 Hz:   0 dB  (Neutral)
   1 kHz:   +1 dB  (Presence)
   2 kHz:   +2 dB  (Vocal clarity)
   4 kHz:   +1 dB  (Detail)
   8 kHz:    0 dB  (Neutral)
   16 kHz:  +1 dB  (Air/sparkle)
   ```

## Layout Configuration

### Recommended Panel Layout

**Top Section (Player Bar):**
- Height: 80px
- Background: #1E1E1E
- Elements:
  - Album Art (60x60px, left)
  - Track Info (center) - Gold text on dark background
  - Playback Controls (right) - Gold icons

**Middle Section (Main Display):**
- Split into 3 columns:
  
  **Left Panel (25%):**
  - Library Tree
  - Background: #1A1A1A
  - Text: #F5F5DC
  - Selection: #2A2A2A with gold highlight

  **Center Panel (50%):**
  - Playlist View
  - Alternating row colors: #121212 / #0D0D0D
  - Playing track: Gold highlight (#FFD700)
  - Column headers: Gold text
  
  **Right Panel (25%):**
  - Album Art Display (large)
  - Track Details
  - Lyrics (ESLyric)
  - Background: #121212

**Bottom Section (Visualizers):**
- Height: 200px
- Split horizontally:
  - Waveform Seekbar (top 80px)
  - Spectrum Analyzer (bottom 120px)
  - Background: #0D0D0D

## Typography

**Recommended Fonts:**

```
Primary Font: Segoe UI Semibold
Secondary Font: Segoe UI Regular
Monospace: Consolas

Sizes:
- Track Title: 11pt
- Artist/Album: 10pt
- Metadata: 9pt
- Playlist: 9pt
- Time Display: 12pt (Consolas)
```

## Album Art Display

**Premium Art Presentation:**

1. **Main Album Art:**
   - Size: 300x300px minimum
   - Border: 2px solid #3D3D3D
   - Shadow: Soft gold glow (8px blur, #D4AF37 at 30% opacity)
   - Reflection: 40% opacity, 50% height

2. **Background Art (Optional):**
   - Blurred album art as background
   - Opacity: 15%
   - Blur: 40px
   - Overlay: Dark gradient (#0D0D0D at 85% opacity)

## Playback Controls

**Button Styling:**

```
Normal State: #C9B037 (Muted Gold)
Hover State: #FFD700 (Bright Gold)
Active State: #F4C430 (Highlight Gold)
Background: Transparent
Border: None
Size: 32x32px
Spacing: 8px
```

**Progress Bar:**
```
Background: #2A2A2A
Played: Linear gradient (#D4AF37 → #FFD700)
Buffered: #3D3D3D
Height: 4px
Border Radius: 2px
```

## Volume Control

**Volume Slider:**
```
Track Color: #2A2A2A
Fill Color: #D4AF37
Thumb Color: #FFD700
Thumb Size: 12px
Height: 4px
```

## Additional Components

### Lyrics Display (ESLyric)

```
Background: #121212
Text Color: #F5F5DC
Highlight Color: #FFD700 (current line)
Font: Segoe UI, 10pt
Alignment: Center
Line Spacing: 1.5
Scroll Animation: Smooth
```

### Library Browser

```
Background: #1A1A1A
Text: #F5F5DC
Selection Background: #2A2A2A
Selection Text: #FFD700
Hover Background: #1E1E1E
Tree Lines: #3D3D3D
Expand Icons: #C9B037
```

### Playlist Columns

**Recommended Columns:**
1. Playing Indicator (▶) - Gold when active
2. Track # - Right aligned, muted gold
3. Title - Primary text color
4. Artist - Secondary gold
5. Album - Secondary gold
6. Duration - Right aligned, muted
7. Codec - Small, muted (FLAC, MP3, etc.)
8. Bitrate - Small, muted

**Column Styling:**
```
Header Background: #1E1E1E
Header Text: #D4AF37
Border: 1px solid #2A2A2A
Sort Indicator: Gold arrow
```

## Performance Optimization

**For smooth visuals:**

1. **Waveform Settings:**
   - Cache waveforms: Enabled
   - Quality: High
   - Update rate: 30 FPS

2. **Spectrum Settings:**
   - FFT Size: 4096 (balanced)
   - Update rate: 60 FPS
   - Hardware acceleration: Enabled

3. **UI Settings:**
   - Smooth scrolling: Enabled
   - Animation duration: 200ms
   - Fade transitions: Enabled

## Installation Steps

1. **Apply Color Scheme:**
   - Copy color values to Georgia-Reborn theme settings
   - Save as custom preset "Premium Gold Executive"

2. **Configure Visualizers:**
   - Set waveform and spectrum colors
   - Enable effects (glow, reflection, peak hold)

3. **Arrange Layout:**
   - Set up panel layout as described
   - Adjust panel sizes to preference

4. **Fine-tune Typography:**
   - Set fonts and sizes
   - Adjust line spacing

5. **Test Playback:**
   - Play various genres
   - Adjust EQ if needed
   - Verify all visualizers working

## Keyboard Shortcuts

**Recommended for executive workflow:**

```
Ctrl+P: Play/Pause
Ctrl+Right: Next Track
Ctrl+Left: Previous Track
Ctrl+E: Toggle Equalizer
Ctrl+L: Toggle Lyrics
Ctrl+V: Toggle Visualizer
F11: Fullscreen
Ctrl+T: Search Library
```

## Tips for Premium Look

1. **Use high-quality album art** (minimum 500x500px)
2. **Enable font smoothing** in Windows settings
3. **Use lossless audio** (FLAC) for best quality indicator
4. **Keep UI clean** - hide unnecessary elements
5. **Adjust monitor brightness** for optimal gold contrast
6. **Use dark desktop wallpaper** to complement theme

## Troubleshooting

**If gold colors look washed out:**
- Increase monitor contrast
- Adjust gamma settings
- Use sRGB color profile

**If visualizers lag:**
- Reduce FFT size
- Lower update rate
- Disable reflection effects

**If text is hard to read:**
- Increase font size
- Adjust text color brightness
- Enable font smoothing
