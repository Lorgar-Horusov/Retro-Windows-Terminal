
# CRT Shader Effect for Windows Terminal

This shader simulates a CRT (Cathode Ray Tube) screen effect by applying several post-processing techniques, including scanlines, lens distortion, chromatic aberration, noise, and blur. It creates a retro, analog display effect often associated with older television and computer screens.
<img src="images/crt_terminal.gif" alt="CRT Shader" width="1280" height="720">

## Features

- **Lens Distortion**: Adds a curved distortion effect to simulate a CRT screen's lens.
- **Noise**: Adds a random noise effect for a more retro feel.
<img src="images/noise.gif" alt="CRT Shader noice" width="640" height="360">

- **Chromatic Aberration**: Shifts the RGB color channels slightly to simulate color fringing.
- **Scanlines**: Adds horizontal scanlines to replicate the appearance of old CRT monitors.
- **Blur**: Applies a blur effect to give a softer, vintage look.

## Installation Instructions

### 1. Install Windows Terminal
If you don't already have Windows Terminal, you can download it from the [Microsoft Store](https://apps.microsoft.com/detail/9n0dx20hk701?hl=en-US&gl=US).

### 2. Open Windows Terminal Settings
1. Open Windows Terminal.
2. Go to settings by clicking the down arrow in the top pane and selecting ‘Settings’, or press `Ctrl + ,`.

### 3. Open JSON File with Settings
In the settings menu, select the 'Open JSON file' tab, or navigate manually to the configuration file.

### 4. Edit JSON File
Locate your terminal profile and add the following configuration:

```json
{
  "profiles": {
    "defaults": {},
    "list": [
      {
        "commandline": "%SystemRoot%\\System32\\cmd.exe",
        "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
        "name": "CMD",
        "background": "#000000",
        "foreground": "#FFBF00",
        "cursorColor": "#FFBF00",
        "cursorShape": "vintage",
        "experimental.pixelShaderPath": "C:\\path\\to\\your\\crt.hlsl",  // Update this with your file path
        "experimental.retroTerminalEffect": true,
        "hidden": false,
        "opacity": 100
      }
    ]
  }
}
```

Replace `"C:\\path\\to\\your\\crt.hlsl"` with the actual file path to your `crt.hlsl` shader file.

### 5. Save Changes
After editing the file, save the changes.

### 6. Restart Windows Terminal
Restart Windows Terminal to apply the changes.

## Customizing Effects

The shader supports customization via preprocessor directives. You can enable or disable various effects and adjust their intensity by modifying the settings below in the `crt.hlsl` shader file.

### Preprocessor Directives
```hlsl
// Enable/disable effects (1 = enabled, 0 = disabled)
#define DISTORTION_ENABLED 1      // Enable distortion
#define NOISE_ENABLED 1           // Enable noise effect
#define CHROMATIC_ENABLED 1       // Enable chromatic aberration
#define BLUR_ENABLED 1            // Enable blur effect
#define SCANLINE_ENABLED 1        // Enable scanlines
```

### Settings for Effects

```hlsl
// Effect settings
#define DISTORTION_AMOUNT 0.06f    // Strength of lens distortion
#define NOISE_AMOUNT 0.2f          // Amount of noise
#define CHROMATIC_SPREAD 0.8f      // Chromatic aberration strength
#define SCANLINE_FACTOR 0.7f       // Scanline intensity
#define SCALED_SCANLINE_PERIOD Scale  // Period for scanlines
#define SCALED_GAUSSIAN_SIGMA (1.5f * Scale)  // Sigma for Gaussian blur
#define LINE_SPEED 0.3f            // Speed of scanlines
#define LINE_WIDTH 20.0f           // Width of the scanlines
```

### Effect Descriptions
- **DISTORTION_ENABLED**: If enabled, this effect applies lens distortion to the image, simulating the curved nature of a CRT screen.
- **NOISE_ENABLED**: Introduces random noise to the image, adding a grainy retro look.
- **CHROMATIC_ENABLED**: Applies chromatic aberration, shifting the RGB color channels for a more authentic CRT look.
- **BLUR_ENABLED**: Applies a blur effect to soften the image, making it look more vintage.
- **SCANLINE_ENABLED**: Adds horizontal scanlines to simulate the appearance of old CRT monitors.

You can fine-tune each effect by adjusting the corresponding settings like `DISTORTION_AMOUNT`, `NOISE_AMOUNT`, and others. Experiment with different values to achieve the desired look.

## Troubleshooting

- **Shader not applied**: Ensure that you have correctly specified the path to your `.hlsl` file in the `experimental.pixelShaderPath` setting.
- **Effects not visible**: Double-check that the effects are enabled by setting their corresponding preprocessor directives to `1`.


---

Enjoy your retro CRT effect in Windows Terminal!
