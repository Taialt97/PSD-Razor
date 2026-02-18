# PSD Razor (macOS GUI)
PSD Razor is a native macOS application designed to give a friendly face to the powerful psd_ockham command-line utility. It allows graphic designers and artists to drastically reduce Photoshop file sizes without ever needing to open the Terminal.

## Key Features

- Drag & Drop Interface: Simply drag your .psd or .psb files directly onto the app window.
- Batch Processing: Supports dropping multiple files at once to process them in a queue.
- Automated Permissions: Automatically handles macOS security hurdles (like chmod +x and removing quarantine attributes) so the script runs instantly without "Permission Denied" errors.
- Real-Time Feedback: Features a built-in console window so you can see the reduction progress and results live.
- Native Performance: Built with Swift and SwiftUI for a lightweight, responsive experience on Apple Silicon and Intel Macs.

## How to Use

1. Launch PSD Razor
2. Drag one or more Photoshop files onto the drop zone.
3. Click "Reduce File Size".

>[!NOTE]
>If you see a "Permission Denied" or "Unidentified Developer" error:
1. Open System Settings (or System Preferences).
2. Go to Privacy & Security.
3. Scroll down to the Security section.
4. Click Open Anyway next to the app name.
5. Enter your password to confirm and launch the app.

The app will generate a smaller version of your file (suffixed with _cut) in the same folder.

---

## Original psd_ockham Documentation
**psd_ockham** is a command-line utility that reduces Photoshop .psd and .psb file size by removing parts of excessive XMP metadata.

Latter versions of Photoshop have issue when XMP gets bloated with numerous identifiers in the `<photoshop:DocumentAncestors>` element (https://forums.adobe.com/thread/1983397). These tags doesn't contain any useful information and can be safely removed. Sometimes psd files get extremely large and the size of bloated metadata exceeds the size of the rest of the file multiple times.

psd_ockham removes all `DocumentAncestors`, `rdf:Bag` and `rdf:li` tags from metadata in psd and included smart-objects. It doesn't change psd structure, contents of the file or graphical layers.

Utility does not require Photoshop and can be run on Windows, MacOS and Unix.

## Usage from command line

```
psd_ockham SOURCE_FILE [DESTINATION_FILE]
```

Results will be written to destination file. If there's no destination file provided, results will be written to new file near source file with suffix `_cut`.

Running psd_ockham without parameters prints help message and version.

## Usage from GUI

Version with graphical user interface is provided for Windows only. It is simple and straightforward, just drag-n-drop files and folders onto main window. GUI version is independent and doesn't require command-line executable.

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
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
