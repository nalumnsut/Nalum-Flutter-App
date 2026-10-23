# Setup

From a fresh laptop to the app running on your own Android phone, over a
USB cable or over Wi-Fi. Cited as `SETUP.md §N`. Rules for working in the
repo are in [AGENTS.md](AGENTS.md); how PRs and reviews work is in
[docs/WORKFLOW.md](docs/WORKFLOW.md).

## §1 Install the tools

1. **Git.** On Windows, use **Git Bash** (comes with Git for Windows) for every
   command below; PowerShell can't run the repo's scripts.
2. **Flutter 3.41.7**, the version pinned in `.fvmrc`:
   - Recommended: install [FVM](https://fvm.app), then run `fvm install` and
     `fvm use` in the repo, and type `fvm flutter …` instead of `flutter …`.
   - Or install Flutter 3.41.7 directly from flutter.dev and add `flutter/bin`
     to your `PATH`.
3. **Android Studio** (it brings the Android SDK, `adb` and Java 17). In its
   SDK Manager install *Android SDK Platform-Tools* and *Command-line Tools*.
   Then accept the licenses:

   ```bash
   flutter doctor --android-licenses
   ```

4. Add the SDK's `platform-tools` folder to your `PATH` so `adb` works in the
   terminal (Windows: `%LOCALAPPDATA%\Android\Sdk\platform-tools`).
5. Check everything:

   ```bash
   flutter doctor
   adb version
   ```

   The Flutter, Android toolchain and Android Studio lines must be green.
   Xcode errors on Windows are expected (iOS needs a Mac, §6).

## §2 Clone and first run of the checks

```bash
git clone https://github.com/nalumnsut/nalum-app.git
cd nalum-app
git config core.autocrlf input          # keep LF line endings (Windows)
git config core.hooksPath tool/hooks    # turn on the commit-message check
flutter pub get
bash tool/check.sh                      # must end with "All checks passed."
```

The hook rejects long commit messages and any `Co-authored-by` or
"Generated with" lines (AGENTS.md "Conventions" → Git).

## §3 A backend to talk to

The dev flavor talks to the website backend running on **your laptop**:

```bash
# in a clone of the website repo (nalumnsut/nalum)
npm run dev:up        # API on http://localhost:2478
```

Its Docker port is bound to `127.0.0.1` only, so your phone can't reach it
through your laptop's Wi-Fi IP. The setup below uses **`adb reverse`**
instead: it makes `localhost:2478` *on the phone* point to port 2478 on your
laptop, over USB or over wireless debugging.

Create your personal config once (it is gitignored):

```bash
cat > apps/mobile/config/local.json <<'JSON'
{
  "FLAVOR": "dev",
  "API_BASE_URL": "http://localhost:2478/api",
  "SOCKET_URL": "http://localhost:2478",
  "WEB_BASE_URL": "http://localhost:5173"
}
JSON
```

On the **Android emulator** you don't need any of this: `config/dev.json`
already points to `10.0.2.2`, the emulator's name for your laptop.

## §4 Turn on developer options and USB debugging (phone)

1. **Developer options:** Settings → About phone → tap **Build number** seven
   times until it says "You are now a developer". Where Build number lives:
   - Samsung: About phone → Software information → Build number
   - Xiaomi / Redmi / POCO: About phone → tap **OS version** (or MIUI version)
   - OnePlus / Realme / Oppo: About device → Version → Build number
   - Pixel / Motorola / Nothing: About phone → Build number
2. **USB debugging:** Settings → System → Developer options → turn on
   **USB debugging**. On Xiaomi phones also turn on **Install via USB** and
   **USB debugging (Security settings)** (these may ask you to sign in to a
   Mi account).
3. While you're there, turning on **Stay awake** stops the screen locking
   while the cable is plugged in.

## §5 Run the app on your phone

### §5.1 Over a USB cable

1. Plug the phone in with a **data** cable (some cheap cables only charge).
   If the phone asks what the USB connection is for, pick **File transfer**.
2. Accept **"Allow USB debugging?"** on the phone and tick *Always allow
   from this computer*.
3. Check the phone is seen:

   ```bash
   adb devices          # shows "<serial>   device" (not "unauthorized")
   ```

4. Forward the backend port and run:

   ```bash
   adb reverse tcp:2478 tcp:2478
   cd apps/mobile
   flutter run --flavor dev --dart-define-from-file=config/local.json
   ```

   With several devices attached, pick one with `flutter devices` and
   `flutter run -d <device-id> …`. In VS Code, use the launch configuration
   *"NALUM local (physical phone, config/local.json)"*.

5. While it runs: `r` hot reload, `R` hot restart, `q` quit. The first build
   takes a few minutes (Gradle); later ones are much faster.

The app installs as **NALUM Dev** with a "DEV" corner banner, next to any
store version.

### §5.2 Over Wi-Fi (wireless debugging, Android 11+)

No cable after the first pairing. The phone and laptop must be on the
**same Wi-Fi network**. College networks often block devices from seeing
each other; a phone hotspot or home Wi-Fi works.

1. Developer options → **Wireless debugging** → turn on → open it.
2. Tap **Pair device with pairing code**. The phone shows an IP:port and a
   six-digit code. On the laptop:

   ```bash
   adb pair 192.168.1.23:37185 482915      # the IP:port and code from the pairing dialog
   ```

3. Close the dialog. The main Wireless debugging screen shows **IP address &
   Port**. It's a different port from the pairing one:

   ```bash
   adb connect 192.168.1.23:41237
   adb devices                              # the phone appears as 192.168.1.23:41237  device
   ```

4. Then run exactly as over USB (`adb reverse` works over wireless too):

   ```bash
   adb reverse tcp:2478 tcp:2478
   cd apps/mobile
   flutter run --flavor dev --dart-define-from-file=config/local.json
   ```

Notes:

- Pairing is remembered. After a reboot or Wi-Fi change, only step 3 is
  needed, with the new port shown on the phone.
- Android Studio can do the pairing with a QR code: Device Manager → *Pair
  devices using Wi-Fi*.
- **Android 10 or older:** connect by USB once, run `adb tcpip 5555`,
  unplug, then `adb connect <phone-ip>:5555` (phone IP: Settings → About
  phone → Status). Redo it after every phone reboot.

### §5.3 Without a local backend

To see the app against the real server, use the staging flavor (once
staging exists) or prod: `--flavor staging --dart-define-from-file=config/staging.json`.
Use test accounts only, never your real alumni account, when trying
unfinished features.

## §6 iPhone

iOS builds need a Mac with Xcode; they can't be done on Windows or Linux.
On a Mac: open `apps/mobile/ios/Runner.xcworkspace` once in Xcode, pick a
signing team under *Signing & Capabilities*, turn on **Developer Mode** on the
iPhone (Settings → Privacy & Security), then run
`flutter run --dart-define-from-file=config/dev.json`. Without a Mac, rely
on the CI iOS build and TestFlight ([docs/WORKFLOW.md §7](docs/WORKFLOW.md)).

## §7 Troubleshooting

| Problem | Fix |
|---|---|
| `adb devices` shows `unauthorized` | Unplug, revoke USB debugging authorizations in Developer options, plug in again and accept the prompt |
| Phone not listed at all | Try another cable/port, switch USB mode to File transfer; on Windows install the phone maker's USB driver (or *Google USB Driver* from the SDK Manager) |
| App opens to "Could not reach NALUM" | Backend not running, or `adb reverse tcp:2478 tcp:2478` not run since the phone reconnected (`adb reverse --list` to check) |
| `StateError: Missing build config` | You forgot `--dart-define-from-file=config/…json` |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | An older build signed differently is installed: `adb uninstall in.ac.nsut.alumni.dev` |
| Xiaomi: install blocked | Turn on *Install via USB* (§4) and accept the on-phone prompt during install |
| `adb pair` fails | Code expired (they're short-lived) or different networks; reopen the pairing dialog |
| Wireless device disappears | Phone locked Wi-Fi or changed port; `adb connect` again with the port now shown |
| Format check fails on files you didn't change | CRLF line endings: `git config core.autocrlf input`, then `git rm --cached -r . && git reset --hard` (commit your work first) |
