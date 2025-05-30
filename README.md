# 🏴‍☠️ Dvinci's MSToolbox: The Grand Line of PowerShell Tools

Welcome to **Dvinci's MSToolbox** — your treasure chest of PowerShell tools, inspired by the epic journey of the Straw Hat Pirates from One Piece! Set sail on the Grand Line of system telemetry, reporting, and more, as you collect powerful tools and discover new islands (features) along the way.

## 🌊 What is This?
This repository is your very own "pirate toolbox" — a modular collection of PowerShell scripts, starting with the mighty **satellite** tool for system telemetry and reporting. The adventure has just begun: more tools (islands) will be added as the crew grows!

## 🗺️ Toolbox Structure

```
dvincis-mstoolbox/
  satellite/           # The Satellite telemetry tool (your first island)
    sattelite.ps1
    TelemetryReport.ps1
    TelemetryConfig.ps1
    TelemetryLogger.ps1
    TelemetryClasses.ps1
    config.csv
    telemetry.log
    ...
  shambles.ps1         # The "Shambles" launcher (your navigation log pose)
  README.md            # This very map
```

## ⚓ Usage: Navigate Like Law!

The **shambles.ps1** script is your "Ope Ope no Mi" — it lets you teleport between tools (islands) in your toolbox.

### Enter the Satellite Tool (your first adventure):
```powershell
# From the root of the repo
./shambles.ps1 satellite
```
Or, set an alias for quick travel:
```powershell
Set-Alias room "$PWD/shambles.ps1"
room satellite
```

### Return to the Root (the Sunny):
```powershell
./shambles.ps1 root
# or just
./shambles.ps1
```

### See All Available Tools (Islands):
```powershell
./shambles.ps1
```

## 🛰️ Satellite: Your All-Seeing Eye
The **satellite** tool collects system, network, printer, and path access info, then generates a beautiful HTML report with:
- Dark/Light mode
- Accordion UI
- Search, print, and navigation
- System, network, disk, software, and event info
- ...and more!

## 🏝️ Adding New Tools (Islands)
Just drop a new folder in the root, add your scripts, and update `shambles.ps1` to recognize your new tool. The Grand Line awaits!

## 🏴‍☠️ Contributing: Join the Crew!
Pull requests and new tools are welcome! If you have a devil fruit power (feature) to share, open an issue or PR. All pirates are welcome aboard.

## ⚠️ Requirements
- Windows PowerShell 5.1+ or PowerShell 7+
- Run as Administrator for full telemetry
- Internet for some features (e.g., logo, fonts)

## 🛠️ Setup
1. Clone the repo:
   ```powershell
   git clone https://github.com/dvlncl/dvincis-mstoolbox.git
   cd dvincis-mstoolbox
   ```
2. Run the launcher:
   ```powershell
   ./shambles.ps1 satellite
   ```
3. Enjoy your journey!

## 📜 License
MIT — Free for all pirates and marines alike.

---

> "I'm gonna be King of the Toolbox!" — Dvinci 