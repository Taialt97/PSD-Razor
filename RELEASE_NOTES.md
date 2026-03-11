# PSD Razor v1.1 — Universal Binary + Hardened Runtime

## What's New

- **Universal Binary:** Both the macOS app and the underlying `psd_ockham` tool now run natively on Intel (x86_64) and Apple Silicon (arm64). No Rosetta 2 required.
- **Hardened Runtime:** All executables in the app bundle are signed with Apple's Hardened Runtime, enabling notarization and improving Gatekeeper compatibility.
- **Proper Asset Catalog:** App icon is now provided at all macOS-required sizes (16px–1024px) via a standard Xcode asset catalog.
- **Xcode Project Support:** Developers can generate an Xcode project with a single command (`./setup.sh`) after cloning the repo.
- **Entitlements & Info.plist:** The app now declares proper entitlements, document type support for PSD files, and a complete Info.plist with all standard macOS app metadata.

## Fixes

- **Fixed "Bad CPU type in executable"** error on Apple Silicon Macs (M1/M2/M3/M4) that did not have Rosetta 2 installed. The bundled `psd_ockham` binary was previously x86_64-only.
- **Fixed architecture mismatch** where the Swift app was arm64-only but the C tool was x86_64-only. Both are now universal.
- **Fixed signing** — the `psd_ockham` helper binary is now individually signed with Hardened Runtime before being embedded in the app bundle, resolving notarization rejection.

## Requirements

- macOS 13.0 (Ventura) or later
- Works on both Intel and Apple Silicon Macs (M1, M2, M3, M4 and newer)
