# App icon assets

Drop the following files here before running
`dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` :

- `app_icon.png`            — 1024×1024 PNG, no transparency, no rounded corners
- `app_icon_foreground.png` — 1024×1024 transparent PNG (centered logo,
                              ~66 % canvas) for Android adaptive icons
- `splash.png`              — 1152×1152 PNG centered logo for the native
                              splash screen

Then:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Regenerate whenever the branding changes.
