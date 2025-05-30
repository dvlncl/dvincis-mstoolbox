# Dvinci's MSToolbox

Dvinci's MSToolbox is a modular collection of PowerShell tools for system telemetry, reporting, and future extensibility. Designed for IT professionals and enthusiasts, this toolbox provides a robust foundation for gathering and reporting on system, network, printer, and path access information, with a modern and user-friendly interface.

---

## Features
- **Modular Design:** Easily add new tools as your needs grow.
- **Satellite Tool:**
  - Collects system, network, printer, and path access data
  - Generates a modern HTML report with dark/light mode, accordion UI, search, print, and navigation
  - Enhanced error handling, logging, and configuration
- **Launcher Script (`shambles.ps1`):** Quickly switch between available tools
- **Ready for Expansion:** Add new tools by simply creating a new folder and updating the launcher

---

## Project Structure
```
dvincis-mstoolbox/
  satellite/           # Satellite telemetry tool
    sattelite.ps1
    TelemetryReport.ps1
    TelemetryConfig.ps1
    TelemetryLogger.ps1
    TelemetryClasses.ps1
    config.csv
    telemetry.log
    ...
  shambles.ps1         # Toolbox launcher
  README.md            # Project documentation
```

---

## Getting Started

### Requirements
- Windows PowerShell 5.1+ or PowerShell 7+
- Administrator privileges recommended for full telemetry
- Internet connection for some features (e.g., logo, fonts)

### Setup
1. Clone the repository:
   ```powershell
   git clone https://github.com/dvlncl/dvincis-mstoolbox.git
   cd dvincis-mstoolbox
   ```
2. Launch the Satellite tool:
   ```powershell
   ./shambles.ps1 satellite
   ```
   Or set an alias for convenience:
   ```powershell
   Set-Alias room "$PWD/shambles.ps1"
   room satellite
   ```
3. To return to the root or list available tools:
   ```powershell
   ./shambles.ps1
   ./shambles.ps1 root
   ```

---

## Adding New Tools
- Create a new folder in the root directory for your tool
- Add your scripts to the folder
- Update `shambles.ps1` to recognize and launch your new tool

---

## Contributing
Contributions are welcome! If you have ideas for new tools or improvements, feel free to open an issue or submit a pull request. Let's build a toolbox worthy of the Grand Line together.

---

## License
MIT License

---

> "The world's greatest treasure is the journey itself." — Inspired by One Piece 