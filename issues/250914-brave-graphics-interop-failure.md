> https://www.perplexity.ai/search/im-running-nixos-on-framework-zdKDbIPlRfacUv0bEzr7sw

Brave’s GPU errors came from backend selection and display stack mismatch: X11 vsync/GL issues and Wayland rejecting legacy EGL, plus harmless Vulkan/EGL probes during diagnostics. The stable fix was to run Brave natively on **Wayland** and let Chromium pick its ANGLE backend, avoiding forced EGL or Vulkan.

### The problem
- Chromium/Brave printed “vkCreateInstance: Found no drivers,” EGL config/context errors, and X11 vsync failures; pages like brave://gpu exacerbated these probes.  
- Initial config also disabled GPU features via flags, and a sandbox could have hidden driver paths; both contributed noise and confusion.  

### What was tried
- Removed GPU‑disabling flags and launched Brave outside the sandbox with nix run.  
- Exported LD_LIBRARY_PATH and tried explicit Vulkan/EGL env (VK_ICD_FILENAMES, __EGL_VENDOR_LIBRARY_DIRS, LIBGL_DRIVERS_PATH).  
- Switched between X11 and Wayland: --ozone-platform=x11 vs --ozone-platform=wayland, with and without NIXOS_OZONE_WL=1.  
- Forced various GL backends: --use-gl=egl, --use-gl=desktop, --use-gl=angle/egl-angle with --use-angle=opengl/opengles.  
- Verified the stack: glxinfo showed radeonsi acceleration; vulkaninfo showed RADV working (skipping dzn ICD is normal).  

### What worked
- Native Wayland with Ozone and no extra GL flags: env NIXOS_OZONE_WL=1 brave --ozone-platform=wayland.  
- Accepting benign diagnostic logs on brave://gpu while actual rendering runs via ANGLE; optionally add --disable-features=Vulkan to silence Vulkan probes.  
- Ensuring hardware.graphics.enable (+ enable32Bit) is set so /run/opengl-driver is present; avoid sandbox profiles that hide those paths.  

### What didn’t work
- Forcing --use-gl=egl on Wayland: Chromium rejects non‑ANGLE EGL on Ozone Wayland, leading to “Requested version is not supported/EGL_BAD_ATTRIBUTE.”  
- Some ANGLE flag combos resulted in “Requested GL implementation … not found,” e.g., gl=none, angle=none, when flags didn’t match allowed Wayland implementations.  
- X11 path (--ozone-platform=x11) repeatedly logged GetVSyncParametersIfAvailable() failed and EGL adapter discovery errors; it’s more brittle here.  
- Relying only on LD_LIBRARY_PATH or over‑specifying Vulkan/EGL env didn’t fix Chromium’s Wayland backend selection behavior.  

### Final guidance
- Use native **Wayland**: set NIXOS_OZONE_WL=1 and run with --ozone-platform=wayland; don’t force legacy EGL on Wayland.  
- If logs are noisy, add --disable-features=Vulkan on Wayland; Vulkan isn’t used in Brave’s Wayland path.  
- If needing X11 temporarily, prefer --use-gl=desktop and expect some vsync warnings.  
- If re‑enabling a sandbox, whitelist /run/opengl-driver and related dirs so drivers remain visible.

[1](https://community.brave.app/t/latest-brave-does-not-work-with-ubuntu-wayland/642318)
[2](https://github.com/brave/brave-browser/issues/35953)
[3](https://www.reddit.com/r/hyprland/comments/18tteue/brave_wont_launch_with_gpu/)
[4](https://forums.freebsd.org/threads/unable-to-properly-run-chrome-or-brave-with-linux-browser-installer.92994/)
[5](https://community.brave.app/t/graphical-glitches-on-arch-linux-wayland-and-kde-6-2-6-3/599243)
[6](https://github.com/brave/brave-browser/issues/47596)
[7](https://forum.manjaro.org/t/unable-to-use-prime-run-with-brave/150690)
[8](https://forum.endeavouros.com/t/chromium-based-browsers-not-launching-in-wayland/63453)
[9](https://bugs.launchpad.net/bugs/2016870)
[10](https://discuss.getsol.us/d/10523-brave-browser-and-mpv-issues-on-wayland-after-update)