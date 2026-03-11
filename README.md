# PSD Razor (macOS GUI)

PSD Razor is a native macOS application designed to give a friendly face to the powerful psd_ockham command-line utility. It allows graphic designers and artists to drastically reduce Photoshop file sizes without ever needing to open the Terminal.

## Key Features

- **Drag & Drop Interface:** Simply drag your .psd or .psb files directly onto the app window.
- **Batch Processing:** Supports dropping multiple files at once to process them in a queue.
- **Automated Permissions:** Automatically handles macOS security hurdles (like chmod +x and removing quarantine attributes) so the script runs instantly without "Permission Denied" errors.
- **Real-Time Feedback:** Features a built-in console window so you can see the reduction progress and results live.
- **Native Performance:** Built with Swift and SwiftUI for a lightweight, responsive experience on Apple Silicon and Intel Macs.
- **Universal Binary:** Runs natively on both Intel (x86_64) and Apple Silicon (arm64) Macs — no Rosetta required.
- **Hardened Runtime:** Signed with Apple's Hardened Runtime for macOS security compliance and notarization support.

## Download

Download the latest release from the [Releases](../../releases) page.

## How to Use

1. Launch PSD Razor.
2. Drag one or more Photoshop files onto the drop zone.
3. Click "Reduce File Size".

The app will generate a smaller version of your file (suffixed with `_cut`) in the same folder.

## Troubleshooting

### "Permission Denied" or "Unidentified Developer"

1. Open **System Settings** (or System Preferences).
2. Go to **Privacy & Security**.
3. Scroll down to the **Security** section.
4. Click **Open Anyway** next to the app name.
5. Enter your password to confirm and launch the app.

### "Bad CPU type in executable"

This means the app was built for a different CPU architecture. Download the latest release which includes a universal binary, or rebuild from source using the development instructions below.

---

## Development

### Prerequisites

- macOS 13.0 or later
- Xcode or Command Line Tools (`xcode-select --install`)
- [Homebrew](https://brew.sh)

### Setup

After cloning the repo, run the setup script to compile `psd_ockham` from source and generate the Xcode project:

```bash
./setup.sh
```

This will:
1. Install [xcodegen](https://github.com/yonaskolb/XcodeGen) via Homebrew (if not already installed)
2. Compile the `psd_ockham` C tool from source as a universal binary (arm64 + x86_64)
3. Generate the Xcode project at `Photoshop Reducer GUI/PSD Razor.xcodeproj`

Then open the project:

```bash
open "Photoshop Reducer GUI/PSD Razor.xcodeproj"
```

### Building without Xcode

```bash
cd "Photoshop Reducer GUI"
bash build_native_app.sh
```

This produces a standalone `build/PSD Razor.app` you can run directly or move to Applications.

### Signing for Distribution

By default the build uses ad-hoc signing. To sign with a Developer ID for notarization:

```bash
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" bash build_native_app.sh
```

---

## About psd_ockham

**psd_ockham** is a command-line utility that reduces Photoshop .psd and .psb file size by removing parts of excessive XMP metadata.

Latter versions of Photoshop have an issue when XMP gets bloated with numerous identifiers in the `<photoshop:DocumentAncestors>` element ([Adobe Forums thread](https://forums.adobe.com/thread/1983397)). These tags don't contain any useful information and can be safely removed. Sometimes PSD files get extremely large and the size of bloated metadata exceeds the size of the rest of the file multiple times.

psd_ockham removes all `DocumentAncestors`, `rdf:Bag` and `rdf:li` tags from metadata in PSD and included smart-objects. It doesn't change PSD structure, contents of the file or graphical layers.

The utility does not require Photoshop and can be run on Windows and macOS.

### Usage from command line

```
psd_ockham SOURCE_FILE [DESTINATION_FILE]
```

Results will be written to the destination file. If no destination file is provided, results will be written to a new file near the source file with suffix `_cut`.

Running psd_ockham without parameters prints the help message and version.

### Usage from GUI

Graphical user interfaces are provided for both **Windows** and **macOS**:
- **macOS:** PSD Razor (this app) — drag-and-drop files onto the window.
- **Windows:** A standalone GUI is included in the `src-gui/win` directory.

## Copyright

Copyright © 2017-2023 Playrix.

psd_ockham is based on [libpsd](https://sourceforge.net/projects/libpsd/)

Copyright © 2004-2007 Graphest Software.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
