# TelemetryReport.ps1 - HTML report generation module

class TelemetryReport {
    [string]$OutputDirectory
    $ReportConfig
    [string]$ReportFile
    $SystemInfo
    $NetworkInfo
    $PrinterInfo
    $PathInfo
    [hashtable]$Themes = @{
        "Modern" = @{
            "PrimaryColor" = "#2196F3"
            "SecondaryColor" = "#FFC107"
            "BackgroundColor" = "#FFFFFF"
            "TextColor" = "#212121"
            "AccentColor" = "#4CAF50"
            "ErrorColor" = "#F44336"
            "WarningColor" = "#FF9800"
            "SuccessColor" = "#4CAF50"
            "FontFamily" = "'Segoe UI', Arial, sans-serif"
        }
        "Classic" = @{
            "PrimaryColor" = "#000080"
            "SecondaryColor" = "#808080"
            "BackgroundColor" = "#FFFFFF"
            "TextColor" = "#000000"
            "AccentColor" = "#008000"
            "ErrorColor" = "#FF0000"
            "WarningColor" = "#FFA500"
            "SuccessColor" = "#008000"
            "FontFamily" = "Arial, sans-serif"
        }
        "Dark" = @{
            "PrimaryColor" = "#BB86FC"
            "SecondaryColor" = "#03DAC6"
            "BackgroundColor" = "#121212"
            "TextColor" = "#FFFFFF"
            "AccentColor" = "#CF6679"
            "ErrorColor" = "#CF6679"
            "WarningColor" = "#FFB74D"
            "SuccessColor" = "#81C784"
            "FontFamily" = "'Segoe UI', Arial, sans-serif"
        }
        "Light" = @{
            "PrimaryColor" = "#6200EE"
            "SecondaryColor" = "#03DAC6"
            "BackgroundColor" = "#FFFFFF"
            "TextColor" = "#000000"
            "AccentColor" = "#03DAC6"
            "ErrorColor" = "#B00020"
            "WarningColor" = "#FFB74D"
            "SuccessColor" = "#81C784"
            "FontFamily" = "'Segoe UI', Arial, sans-serif"
        }
    }

    TelemetryReport($OutputDir, $Config, $SysInfo, $NetInfo, $PrintInfo, $PthInfo) {
        $this.OutputDirectory = $OutputDir
        $this.ReportConfig = $Config
        $this.SystemInfo = $SysInfo
        $this.NetworkInfo = $NetInfo
        $this.PrinterInfo = $PrintInfo
        $this.PathInfo = $PthInfo
        $this.ReportFile = Join-Path $OutputDir "TelemetryReport.html"
    }

    [void] GenerateReport() {
        try {
            $html = $this.GenerateHTMLReport()
            $html | Out-File -FilePath $this.ReportFile -Encoding UTF8
            if ($this.ReportConfig.AutoOpen) {
                Start-Process $this.ReportFile
            }
        }
        catch {
            Write-Error "Error generating report: $_"
            throw
        }
    }

    [string] GenerateHTMLReport() {
        $systemCount = 1
        $diskCount = $this.SystemInfo.DiskInfo.Count
        $networkCount = $this.NetworkInfo.NetworkAdapters.Count
        $securityCount = 1 # You can make this dynamic if you wish
        $hardwareCount = 1 # You can make this dynamic if you wish
        $softwareCount = $this.SystemInfo.InstalledSoftware.Count
        $eventsCount = $this.SystemInfo.RecentErrors.Count
        $summaryCount = 1
        $printerCount = $this.PrinterInfo.Printers.Count
        $sharesCount = $this.NetworkInfo.NetworkShares.Count
        $pathsCount = $this.PathInfo.PathAccessResults.Count
        $dnsCount = $this.NetworkInfo.DNSResults.Count
        $pingCount = $this.NetworkInfo.PingResults.Count

        # --- HEADER ---
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Satellite by Dvlncl - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
    <link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css' rel='stylesheet'>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600&family=Roboto:wght@400;700&display=swap');
        body, .container, table, th, td, h1, h2, h3, h4, h5, h6, button, input {
            font-family: 'Inter', 'Roboto', 'Segoe UI', Arial, sans-serif !important;
        }
        :root {
            --primary: #3498db;
            --success: #2ecc71;
            --danger: #e74c3c;
            --gray: #f9f9f9;
            --dark-bg: #1a1a1a;
            --dark-container: #2d2d2d;
            --dark-header: #2c3e50;
            --dark-summary: #34495e;
            --dark-text: #e0e0e0;
            --light-bg: #f5f5f5;
            --light-container: #fff;
            --light-header: #3498db;
            --light-summary: #f5f5f5;
            --light-text: #222;
        }
        body[data-theme="dark"] {
            background-color: var(--dark-bg);
            color: var(--dark-text);
        }
        body[data-theme="light"] {
            background-color: var(--light-bg);
            color: var(--light-text);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: var(--dark-container);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            transition: background 0.3s, color 0.3s;
        }
        body[data-theme="light"] .container {
            background-color: var(--light-container);
            color: var(--light-text);
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 20px;
            background-color: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            color: #222;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: var(--dark-header);
            color: #fff;
            position: sticky;
            top: 0;
        }
        body[data-theme="light"] th {
            background-color: var(--light-header);
            color: #fff;
        }
        tr:nth-child(even) { background-color: var(--gray); }
        tr:hover {
            background-color: #333a45 !important;
            color: #fff !important;
        }
        body[data-theme="light"] tr:hover {
            background-color: #e0eaff !important;
            color: #222 !important;
        }
        h1 {
            color: var(--primary);
            border-bottom: 2px solid var(--primary);
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 2.2em;
            letter-spacing: 1px;
        }
        .summary {
            background-color: var(--dark-summary);
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        body[data-theme="light"] .summary {
            background-color: var(--light-summary);
            color: var(--light-text);
        }
        .summary h2 {
            color: var(--primary);
            margin-top: 0;
        }
        .summary p {
            margin: 8px 0;
            font-size: 14px;
        }
        .status-success { color: var(--success); }
        .status-failed, .status-offline { color: var(--danger); }
        .status-normal { color: var(--primary); }
        /* Accordion Styles */
        .accordion {
            background-color: var(--dark-header);
            color: #fff;
            cursor: pointer;
            padding: 18px;
            width: 100%;
            text-align: left;
            border: none;
            outline: none;
            transition: background-color 0.3s ease;
            margin-bottom: 2px;
            border-radius: 4px;
            font-size: 16px;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
        }
        body[data-theme="light"] .accordion {
            background-color: var(--light-header);
            color: #fff;
        }
        .accordion:hover {
            background-color: #34495e;
        }
        body[data-theme="light"] .accordion:hover {
            background-color: #2980b9;
        }
        .accordion:after {
            content: '\002B';
            color: #fff;
            font-weight: bold;
            float: right;
            margin-left: 5px;
            transition: transform 0.3s ease;
            position: absolute;
            right: 20px;
        }
        .accordion.active:after {
            content: '\2212';
            transform: rotate(180deg);
        }
        .panel {
            padding: 0;
            background-color: #fff;
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease-out, padding 0.3s ease-out;
            margin-bottom: 10px;
            border-radius: 0 0 4px 4px;
            color: #222;
        }
        .panel.active {
            padding: 18px;
            max-height: 2000px;
        }
        /* Control Buttons */
        .control-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .control-button {
            background-color: var(--primary);
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .control-button:hover {
            background-color: #2980b9;
        }
        /* Theme Toggle Button */
        .theme-toggle {
            position: absolute;
            top: 30px;
            right: 40px;
            z-index: 10;
        }
        .theme-toggle-btn {
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 20px;
            padding: 8px 18px;
            font-size: 15px;
            cursor: pointer;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: background 0.3s;
        }
        .theme-toggle-btn:hover {
            background: #2980b9;
        }
        /* Section Counter */
        .section-counter {
            background-color: rgba(255, 255, 255, 0.2);
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin-left: 16px;
            margin-right: 0;
            display: inline-block;
            min-width: 24px;
            text-align: center;
        }
        /* Search Box */
        .search-box {
            width: 100%;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #34495e;
            border-radius: 4px;
            font-size: 14px;
            background-color: var(--dark-container);
            color: var(--dark-text);
        }
        body[data-theme="light"] .search-box {
            background-color: var(--light-container);
            color: var(--light-text);
            border: 1px solid #ccc;
        }
        .search-box::placeholder {
            color: #95a5a6;
        }
        /* Print Button */
        .print-button {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 50px;
            height: 50px;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5em;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1000;
        }
        .print-button:hover {
            transform: scale(1.1);
            background: #2980b9;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }
        .print-button:active {
            transform: scale(0.95);
        }
        .print-button::before {
            content: "Print Report";
            position: absolute;
            right: 60px;
            background: var(--dark-container);
            color: var(--dark-text);
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            white-space: nowrap;
            opacity: 0;
            transform: translateX(10px);
            transition: all 0.3s ease;
            pointer-events: none;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .print-button:hover::before {
            opacity: 1;
            transform: translateX(0);
        }
        body[data-theme="light"] .print-button::before {
            background: var(--light-container);
            color: var(--light-text);
        }
        @media print {
            .print-button {
                display: none;
            }
        }
        @media (max-width: 600px) {
            .print-button {
                width: 40px;
                height: 40px;
                font-size: 1.2em;
            }
            .print-button::before {
                display: none;
            }
        }
        .floating-nav {
            position: fixed;
            left: 24px;
            top: 90px;
            background: var(--dark-container);
            border-radius: 16px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.18);
            z-index: 3000;
            padding: 8px 0;
            min-width: 180px;
            cursor: move;
            transition: background 0.3s, opacity 0.3s, visibility 0.3s, border 0.3s;
        }
        body[data-theme="light"] .floating-nav {
            background: #fff;
            border: 1.5px solid #e0e0e0;
            box-shadow: 0 4px 24px rgba(52,152,219,0.10), 0 1.5px 6px rgba(0,0,0,0.06);
        }
        .floating-nav.hide {
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
        }
        .floating-nav.minimized {
            width: 48px;
            min-width: 48px;
            height: 48px;
            padding: 0;
            overflow: hidden;
            border-radius: 50%;
            background: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 12px rgba(52,152,219,0.18);
            border: 2px solid #fff;
        }
        body[data-theme="light"] .floating-nav.minimized {
            background: var(--primary);
            border: 2px solid #fff;
            box-shadow: 0 4px 24px rgba(52,152,219,0.10), 0 1.5px 6px rgba(0,0,0,0.06);
        }
        .floating-nav .nav-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        .floating-nav.minimized .nav-list {
            display: none;
        }
        .floating-nav-toggle {
            position: absolute;
            top: 8px;
            right: 8px;
            background: none;
            border: none;
            color: #fff;
            font-size: 1.3em;
            cursor: pointer;
            z-index: 10;
            transition: color 0.2s;
        }
        .floating-nav.minimized .floating-nav-toggle {
            left: 8px;
            right: auto;
            color: #fff;
        }
        .nav-item {
            margin: 0;
            padding: 0;
        }
        .nav-badge {
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--primary);
            color: #fff;
            border-radius: 50%;
            min-width: 22px;
            min-height: 22px;
            width: 22px;
            height: 22px;
            font-size: 0.8em;
            font-weight: bold;
            box-shadow: 0 2px 6px rgba(0,0,0,0.10);
            margin-left: auto;
            margin-right: 0;
            text-align: center;
            transition: background 0.2s, color 0.2s;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 22px 12px 18px;
            color: var(--dark-text);
            text-decoration: none;
            font-size: 1.08em;
            border-radius: 8px;
            transition: background 0.18s, color 0.18s, box-shadow 0.18s;
            position: relative;
            cursor: pointer;
            font-weight: 500;
        }
        .nav-link i {
            font-size: 1.2em;
            width: 22px;
            text-align: center;
        }
        .nav-link:hover, .nav-link:focus {
            background: var(--primary);
            color: #fff;
            box-shadow: 0 2px 8px rgba(52,152,219,0.10);
        }
        .nav-link:hover .nav-badge, .nav-link:focus .nav-badge {
            background: #fff;
            color: var(--primary);
            border: 1.5px solid var(--primary);
        }
        body[data-theme="light"] .nav-link {
            color: var(--light-text);
        }
        body[data-theme="light"] .nav-link:hover, body[data-theme="light"] .nav-link:focus {
            background: var(--primary);
            color: #fff;
        }
        body[data-theme="light"] .nav-badge {
            background: var(--primary);
            color: #fff;
            border: 1.5px solid #fff;
        }
        body[data-theme="light"] .nav-link:hover .nav-badge, body[data-theme="light"] .nav-link:focus .nav-badge {
            background: #fff;
            color: var(--primary);
            border: 1.5px solid var(--primary);
        }
        @media (max-width: 600px) {
            .floating-nav {
                left: 4px;
                top: 56px;
                min-width: 120px;
                padding: 4px 0;
            }
            .nav-link {
                font-size: 0.98em;
                padding: 8px 10px 8px 10px;
            }
            .nav-badge {
                min-width: 22px;
                min-height: 22px;
                width: 22px;
                height: 22px;
                font-size: 0.85em;
            }
        }
        /* Table responsiveness */
        .table-responsive { overflow-x: auto; width: 100%; }
        @media (max-width: 800px) {
            .table-responsive, table { font-size: 13px; }
        }
        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            color: #fff;
        }
        .status-running { background: #2ecc71; }
        .status-stopped { background: #e74c3c; }
        .status-warning { background: #f1c40f; color: #222; }
        .status-unknown { background: #b2bec3; color: #222; }
    </style>
    <script>
        // Theme toggle logic
        function setTheme(theme) {
            document.body.setAttribute('data-theme', theme);
            localStorage.setItem('satellite-theme', theme);
        }
        function toggleTheme() {
            var current = document.body.getAttribute('data-theme');
            setTheme(current === 'dark' ? 'light' : 'dark');
        }
        window.onload = function() {
            // Set theme from localStorage or default to dark
            var saved = localStorage.getItem('satellite-theme') || 'dark';
            setTheme(saved);
            // Open the summary section by default
            var summaryAccordion = document.getElementsByClassName('accordion')[0];
            if (summaryAccordion) toggleAccordion(summaryAccordion);
            // Add click event listeners to all accordions
            var acc = document.getElementsByClassName('accordion');
            for (var i = 0; i < acc.length; i++) {
                acc[i].addEventListener('click', function() {
                    toggleAccordion(this);
                });
            }
            // Initialize draggable navigation
            const nav = document.querySelector('.floating-nav');
            if (nav) makeDraggable(nav);
        }
        // Accordion logic
        function toggleAccordion(element) {
            element.classList.toggle('active');
            var panel = element.nextElementSibling;
            panel.classList.toggle('active');
            if (panel.classList.contains('active')) {
                panel.style.maxHeight = panel.scrollHeight + 'px';
            } else {
                panel.style.maxHeight = '0';
            }
        }
        function expandAll() {
            var acc = document.getElementsByClassName('accordion');
            var panels = document.getElementsByClassName('panel');
            for (var i = 0; i < acc.length; i++) {
                if (!acc[i].classList.contains('active')) {
                    acc[i].classList.add('active');
                    panels[i].classList.add('active');
                    panels[i].style.maxHeight = panels[i].scrollHeight + 'px';
                }
            }
        }
        function collapseAll() {
            var acc = document.getElementsByClassName('accordion');
            var panels = document.getElementsByClassName('panel');
            for (var i = 0; i < acc.length; i++) {
                if (acc[i].classList.contains('active')) {
                    acc[i].classList.remove('active');
                    panels[i].classList.remove('active');
                    panels[i].style.maxHeight = '0';
                }
            }
        }
        function searchSections() {
            var input = document.getElementById('searchBox');
            var filter = input.value.toUpperCase();
            var acc = document.getElementsByClassName('accordion');
            var panels = document.getElementsByClassName('panel');
            for (var i = 0; i < acc.length; i++) {
                var txtValue = acc[i].textContent || acc[i].innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    acc[i].style.display = '';
                    panels[i].style.display = '';
                    if (filter !== '') {
                        if (!acc[i].classList.contains('active')) {
                            toggleAccordion(acc[i]);
                        }
                    }
                } else {
                    acc[i].style.display = 'none';
                    panels[i].style.display = 'none';
                }
            }
        }
        function printReport() {
            window.print();
        }
        // Draggable Navigation Menu
        function makeDraggable(element) {
            let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
            element.onmousedown = dragMouseDown;

            function dragMouseDown(e) {
                e.preventDefault();
                pos3 = e.clientX;
                pos4 = e.clientY;
                document.onmouseup = closeDragElement;
                document.onmousemove = elementDrag;
            }

            function elementDrag(e) {
                e.preventDefault();
                pos1 = pos3 - e.clientX;
                pos2 = pos4 - e.clientY;
                pos3 = e.clientX;
                pos4 = e.clientY;
                element.style.top = (element.offsetTop - pos2) + "px";
                element.style.left = (element.offsetLeft - pos1) + "px";
            }

            function closeDragElement() {
                document.onmouseup = null;
                document.onmousemove = null;
            }
        }
        document.addEventListener('DOMContentLoaded', function() {
            var nav = document.querySelector('.floating-nav');
            var toggle = document.createElement('button');
            toggle.className = 'floating-nav-toggle';
            toggle.innerHTML = '<i class="fas fa-chevron-left"></i>';
            nav.appendChild(toggle);
            toggle.addEventListener('click', function(e) {
                e.stopPropagation();
                nav.classList.toggle('minimized');
                if (nav.classList.contains('minimized')) {
                    toggle.innerHTML = '<i class="fas fa-chevron-right"></i>';
                } else {
                    toggle.innerHTML = '<i class="fas fa-chevron-left"></i>';
                }
            });
            // Make draggable
            var isDown = false, offsetX = 0, offsetY = 0;
            nav.addEventListener('mousedown', function(e) {
                if (e.target.closest('.floating-nav-toggle')) return;
                isDown = true;
                offsetX = e.clientX - nav.offsetLeft;
                offsetY = e.clientY - nav.offsetTop;
                document.body.style.userSelect = 'none';
            });
            document.addEventListener('mousemove', function(e) {
                if (!isDown) return;
                nav.style.left = (e.clientX - offsetX) + 'px';
                nav.style.top = (e.clientY - offsetY) + 'px';
            });
            document.addEventListener('mouseup', function() {
                isDown = false;
                document.body.style.userSelect = '';
            });
            // Nav click expands accordion
            var navLinks = document.querySelectorAll('.nav-link');
            navLinks.forEach(function(link) {
                link.addEventListener('click', function(e) {
                    var id = this.getAttribute('href').replace('#','');
                    var acc = document.getElementById(id);
                    if(acc && !acc.classList.contains('active')) {
                        toggleAccordion(acc);
                    }
                });
            });
        });
    </script>
</head>
<body>
    <div class="theme-toggle">
        <button class="theme-toggle-btn" onclick="toggleTheme()">Toggle Theme</button>
    </div>
    <nav class="floating-nav">
        <ul class="nav-list">
            <li class="nav-item"><a href="#summary" class="nav-link"><i class="fas fa-info-circle"></i> Summary <span class="nav-badge">$summaryCount</span></a></li>
            <li class="nav-item"><a href="#system" class="nav-link"><i class="fas fa-desktop"></i> System Information <span class="nav-badge">$systemCount</span></a></li>
            <li class="nav-item"><a href="#disk" class="nav-link"><i class="fas fa-hdd"></i> Disk Information <span class="nav-badge">$diskCount</span></a></li>
            <li class="nav-item"><a href="#network" class="nav-link"><i class="fas fa-network-wired"></i> Network Adapters <span class="nav-badge">$networkCount</span></a></li>
            <li class="nav-item"><a href="#security" class="nav-link"><i class="fas fa-shield-alt"></i> Security Status <span class="nav-badge">$securityCount</span></a></li>
            <li class="nav-item"><a href="#hardware" class="nav-link"><i class="fas fa-microchip"></i> Hardware Health <span class="nav-badge">$hardwareCount</span></a></li>
            <li class="nav-item"><a href="#software" class="nav-link"><i class="fas fa-box"></i> Software Inventory <span class="nav-badge">$softwareCount</span></a></li>
            <li class="nav-item"><a href="#events" class="nav-link"><i class="fas fa-exclamation-triangle"></i> System Events <span class="nav-badge">$eventsCount</span></a></li>
        </ul>
    </nav>
    <div class="container">
        <h1><i class="fas fa-satellite"></i> Satellite by Dvlncl</h1>
        <div class="control-buttons">
            <button class="control-button" onclick="expandAll()">Expand All</button>
            <button class="control-button" onclick="collapseAll()">Collapse All</button>
        </div>
        <input type="text" id="searchBox" class="search-box" placeholder="Search sections..." onkeyup="searchSections()">
"@
        # --- SUMMARY SECTION ---
        $html += @"
        <div id="summary" class="summary">
            <h2><i class="fas fa-info-circle"></i> Summary</h2>
            <p>Script Execution Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
            <p>Total TargetHosts Pinged: $($this.NetworkInfo.PingResults.Count)</p>
            <p>Total DNS Queries: $($this.NetworkInfo.DNSResults.Count)</p>
            <p>Total Printers: $($this.PrinterInfo.Printers.Count)</p>
            <p>Total Network Shares: $($this.NetworkInfo.NetworkShares.Count)</p>
            <p>Total Paths Checked: $($this.PathInfo.PathAccessResults.Count)</p>
            <p>Critical Services: $($this.SystemInfo.ServiceStatus.Count) Running, 0 Stopped</p>
        </div>
"@
        # --- SYSTEM INFO ACCORDION ---
        $systemSummary = "<div><strong>OS:</strong> $($this.SystemInfo.OSName), <strong>Uptime:</strong> $($this.SystemInfo.Uptime)</div>"
        $systemRows = "<tr><th>Property</th><th>Value</th></tr>"
        $systemRows += "<tr><td>OS Name</td><td>$($this.SystemInfo.OSName)</td></tr>"
        $systemRows += "<tr><td>Computer Name</td><td>$($this.SystemInfo.ComputerName)</td></tr>"
        $systemRows += "<tr><td>Manufacturer</td><td>$($this.SystemInfo.Manufacturer)</td></tr>"
        $systemRows += "<tr><td>Model</td><td>$($this.SystemInfo.Model)</td></tr>"
        $systemRows += "<tr><td>Serial Number</td><td>$($this.SystemInfo.SerialNumber)</td></tr>"
        $systemRows += "<tr><td>OS Version</td><td>$($this.SystemInfo.OSVersion)</td></tr>"
        $systemRows += "<tr><td>OS Architecture</td><td>$($this.SystemInfo.OSArchitecture)</td></tr>"
        $systemRows += "<tr><td>Last Boot Time</td><td>$($this.SystemInfo.LastBootTime)</td></tr>"
        $systemRows += "<tr><td>Uptime</td><td>$($this.SystemInfo.Uptime)</td></tr>"
        $systemRows += "<tr><td>Total Physical Memory</td><td>$($this.SystemInfo.TotalPhysicalMemory)</td></tr>"
        $systemRows += "<tr><td>Processor Name</td><td>$($this.SystemInfo.ProcessorName)</td></tr>"
        $systemRows += "<tr><td>Processor Cores</td><td>$($this.SystemInfo.ProcessorCores)</td></tr>"
        $systemRows += "<tr><td>Processor Threads</td><td>$($this.SystemInfo.ProcessorThreads)</td></tr>"
        $systemRows += "<tr><td>Last Update Check</td><td>$($this.SystemInfo.LastUpdateCheck)</td></tr>"
        $systemRows += "<tr><td>Windows Defender Status</td><td>$($this.SystemInfo.WindowsDefenderStatus)</td></tr>"
        $systemRows += "<tr><td>Join Type</td><td>$($this.SystemInfo.JoinType)</td></tr>"
        $systemRows += "<tr><td>Join Name</td><td>$($this.SystemInfo.JoinName)</td></tr>"
        $html += "<table aria-label=\"System Information Table\">$systemRows</table>"
        # --- DISK INFO ACCORDION ---
        $diskSummary = "<div><strong>Total Disks:</strong> $diskCount</div>"
        $diskRows = ""
        foreach ($disk in $this.SystemInfo.DiskInfo) {
            $freePercent = if ($disk.Size -gt 0) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }
            $diskRows += "<tr><td>$($disk.Drive)</td><td>$($disk.Size)</td><td>$($disk.FreeSpace)</td><td>$freePercent%</td></tr>"
        }
        if (-not $diskRows) { $diskRows = '<tr><td colspan="4">No data available</td></tr>' }
        $html += @"
<button id="disk" class="accordion" aria-expanded="false" aria-controls="disk-panel"><i class="fas fa-hdd"></i> Disk Information <span class="section-counter">$diskCount</span></button>
<div class="panel" id="disk-panel" tabindex="0">
    $diskSummary
    <div class="table-responsive">
    <table aria-label="Disk Information Table">
        <tr><th>Drive</th><th>Size</th><th>Free Space</th><th>Free %</th></tr>
        $diskRows
    </table>
    </div>
</div>
"@
        # --- NETWORK ADAPTERS ACCORDION ---
        $networkSummary = "<div><strong>Adapters:</strong> $networkCount</div>"
        $adapterRows = ""
        foreach ($adapter in $this.NetworkInfo.NetworkAdapters) {
            $statusClass = switch ($adapter.Status) {
                'Up' { 'status-badge status-running' }
                'Down' { 'status-badge status-stopped' }
                default { 'status-badge status-unknown' }
            }
            $adapterRows += "<tr><td>$($adapter.Name)</td><td>$($adapter.InterfaceDescription)</td><td><span class='$statusClass'>$($adapter.Status)</span></td><td>$($adapter.MacAddress)</td><td>$($adapter.IPAddress)</td><td>$($adapter.DNSServers)</td><td>$($adapter.Gateway)</td><td>$($adapter.DHCP)</td></tr>"
        }
        if (-not $adapterRows) { $adapterRows = '<tr><td colspan="8">No data available</td></tr>' }
        $html += @"
<button id="network" class="accordion" aria-expanded="false" aria-controls="network-panel"><i class="fas fa-network-wired"></i> Network Adapters <span class="section-counter">$networkCount</span></button>
<div class="panel" id="network-panel" tabindex="0">
    $networkSummary
    <div class="table-responsive">
    <table aria-label="Network Adapters Table">
        <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Status</th>
            <th>MAC Address</th>
            <th>IP Address</th>
            <th>DNS Servers</th>
            <th>Gateway</th>
            <th>DHCP/Static</th>
        </tr>
        $adapterRows
    </table>
    </div>
</div>
"@
        # --- TRACEROUTE SECTION ---
        $html += @"
<button id="traceroute" class="accordion" aria-expanded="false" aria-controls="traceroute-panel"><i class="fas fa-route"></i> Traceroute (8.8.8.8)</button>
<div class="panel" id="traceroute-panel" tabindex="0">
    <pre style='background:#222;color:#fff;padding:10px;border-radius:6px;max-height:400px;overflow:auto;'>$($this.NetworkInfo.Traceroute)</pre>
</div>
"@
        # --- SECURITY STATUS ACCORDION ---
        $html += @"
<button id="security" class="accordion" aria-expanded="false" aria-controls="security-panel"><i class="fas fa-shield-alt"></i> Security Status <span class="section-counter">5</span></button>
<div class="panel" id="security-panel" tabindex="0">
    <div><strong>Security Overview</strong></div>
    <div class="table-responsive">
    <h3>BitLocker Status</h3>
    <table aria-label="BitLocker Status Table">
        <tr><th>Drive</th><th>Protection Status</th><th>Conversion Status</th><th>Encryption Method</th></tr>
        <tr><td>N/A</td><td>Not Available</td><td>Not Available</td><td>Not Available</td></tr>
    </table>
    <h3>Firewall Status</h3>
    <table aria-label="Firewall Status Table">
        <tr><th>Profile</th><th>Status</th></tr>
        <tr><td>Domain</td><td></td></tr>
        <tr><td>Private</td><td></td></tr>
        <tr><td>Public</td><td></td></tr>
    </table>
    <h3>Windows Defender Details</h3>
    <table aria-label="Windows Defender Details Table">
        <tr><th>Feature</th><th>Status</th></tr>
        <tr><td>Antivirus</td><td>False</td></tr>
        <tr><td>Antispyware</td><td>False</td></tr>
        <tr><td>Real-time Protection</td><td>False</td></tr>
        <tr><td>Last Full Scan</td><td></td></tr>
        <tr><td>Last Quick Scan</td><td></td></tr>
        <tr><td>Last Update</td><td></td></tr>
    </table>
    <h3>UAC Level</h3>
    <p>Enabled</p>
    <h3>Local Administrators</h3>
    <p>Administrator, Dvinci</p>
    </div>
</div>
"@
        # --- HARDWARE HEALTH ACCORDION ---
        $html += @"
<button id="hardware" class="accordion" aria-expanded="false" aria-controls="hardware-panel"><i class="fas fa-microchip"></i> Hardware Health <span class="section-counter">3</span></button>
<div class="panel" id="hardware-panel" tabindex="0">
    <div><strong>Hardware Overview</strong></div>
    <div class="table-responsive">
    <h3>SMART Status</h3>
    <table aria-label="SMART Status Table">
        <tr><th>Device</th><th>Predict Failure</th><th>Reason</th></tr>
        <tr><td>N/A</td><td>Not Available</td><td>Feature not supported or access denied</td></tr>
    </table>
    <h3>Battery Information</h3>
    <table aria-label="Battery Information Table">
        <tr><th>Name</th><th>Charge</th><th>Status</th><th>Design Capacity</th><th>Current Capacity</th></tr>
        <tr><td>BIF0_9</td><td>97%</td><td>2</td><td></td><td></td></tr>
    </table>
    <h3>Temperature Sensors</h3>
    <table aria-label="Temperature Sensors Table">
        <tr><th>Sensor</th><th>Temperature</th><th>Type</th></tr>
        <tr><td>N/A</td><td>Not Available°C</td><td>Temperature</td></tr>
    </table>
    </div>
</div>
"@
        # --- SOFTWARE INVENTORY ACCORDION ---
        $softwareSummary = "<div><strong>Installed:</strong> $softwareCount</div>"
        $softwareRows = ""
        foreach ($sw in $this.SystemInfo.InstalledSoftware) {
            $softwareRows += "<tr><td>$($sw.Name)</td><td>$($sw.Version)</td><td>$($sw.Vendor)</td><td>$($sw.InstallDate)</td></tr>"
        }
        if (-not $softwareRows) { $softwareRows = '<tr><td colspan="4">No data available</td></tr>' }
        $html += @"
<button id="software" class="accordion" aria-expanded="false" aria-controls="software-panel"><i class="fas fa-box"></i> Software Inventory <span class="section-counter">$softwareCount</span></button>
<div class="panel" id="software-panel" tabindex="0">
    $softwareSummary
    <div class="table-responsive">
    <table aria-label="Software Inventory Table">
        <tr><th>Name</th><th>Version</th><th>Vendor</th><th>Install Date</th></tr>
        $softwareRows
    </table>
    </div>
</div>
"@
        # --- EVENTS ACCORDION ---
        $eventsSummary = "<div><strong>Critical Errors:</strong> $eventsCount</div>"
        $eventRows = ""
        foreach ($err in $this.SystemInfo.RecentErrors) {
            $eventRows += "<tr><td>$($err.TimeGenerated)</td><td>$($err.Source)</td><td>$($err.EventID)</td><td>$($err.Message)</td></tr>"
        }
        if (-not $eventRows) { $eventRows = '<tr><td colspan="4">No data available</td></tr>' }
        [string]$bsodRows = ""
        foreach ($bsod in $this.SystemInfo.BSODHistory) {
            $bsodRows += "<tr><td>$($bsod.TimeCreated)</td><td>$($bsod.Message)</td></tr>"
        }
        if (-not $bsodRows) { $bsodRows = '<tr><td colspan="2">No data available</td></tr>' }
        $html += @"
<button id="events" class="accordion" aria-expanded="false" aria-controls="events-panel"><i class="fas fa-exclamation-triangle"></i> System Events <span class="section-counter">$eventsCount</span></button>
<div class="panel" id="events-panel" tabindex="0">
    $eventsSummary
    <div class="table-responsive">
    <h3>Recent Critical Errors</h3>
    <table aria-label="Recent Critical Errors Table">
        <tr><th>Time</th><th>Source</th><th>Event ID</th><th>Message</th></tr>
        $eventRows
    </table>
    <h3>BSOD History</h3>
    <table aria-label="BSOD History Table">
        <tr><th>Time</th><th>Message</th></tr>
        $bsodRows
    </table>
    </div>
</div>
"@
        # --- PRINT BUTTON ---
        $html += '<button class="print-button" onclick="printReport()" title="Print Report"><i class="fas fa-print"></i></button>'
        # --- FOOTER ---
        $html += "</div></body></html>"
        return $html
    }
} 