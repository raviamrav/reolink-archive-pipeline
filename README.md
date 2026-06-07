# Reolink Archive Pipeline

> Automated CCTV cloud archival pipeline that moves yesterday's Reolink 
> camera recordings from local PC to MEGA cloud daily and sends a 
> real-time Telegram notification.

---

## The Problem

Reolink IP cameras support local SD card recording, but SD cards have 
limitations:
- SD card storage fills up quickly and overwrites old footage
- SD cards can corrupt or fail — recordings lost permanently
- Viewing and managing footage directly from SD card is unreliable

**FTP was configured as a backup solution** — camera uploads recordings 
to local PC automatically. However this introduced a new problem:

- PC local storage fills up fast as camera dumps footage continuously
- Manual cleanup is time consuming and easy to forget
- Risk of losing new recordings when disk is full

---

## The Solution

An automated pipeline that:
- Receives Reolink recordings via FTP to local PC
- Syncs recordings to MEGA cloud automatically as backup
- Moves previous day's footage to a cloud Archive folder daily
- Frees up local PC storage automatically
- Sends a Telegram notification confirming the archive completed
- Runs silently every day without any manual intervention

```
SD Card issue
      ↓ (unreliable, corrupts)
FTP backup to local PC
      ↓ (fills up local storage)
Auto sync to MEGA cloud
      ↓ (archive old footage daily)
Local storage freed automatically ✅
Cloud archive preserved permanently ✅
```

---

## Architecture

```
Reolink Camera
      ↓ FTP
Local PC (MEGA sync folder)
      ↓ MEGA Desktop App (auto sync)
MEGA Cloud → /MEGA/Reolink_cams
      ↓ mega_archive.bat (runs daily)
MEGA Cloud → /MEGA/Camera_Archive
      ↓ Telegram Bot API
Your Phone (notification ✅)
```

### Daily Trigger Flow

```
PC Boot
    ↓
Task Scheduler → starts n8n
Task Scheduler → starts server.js
    ↓
10:00AM → n8n Schedule Trigger fires
    ↓
n8n HTTP Request → http://localhost:3000/run-archive
    ↓
server.js → runs mega_archive.bat
    ↓
MEGAclient.exe → moves /Reolink_cams/YYYY/MM/DD → /Camera_Archive/
    ↓
n8n Telegram node → sends report to phone
    ↓
10:15AM → Windows Task Scheduler backup bat runs (failsafe)
    ↓
"Already archived" → exits cleanly
```

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Reolink FTP | Camera recording upload to local PC |
| MEGA Desktop App | Syncs local folder to MEGA cloud automatically |
| MEGAcmd / MEGAclient.exe | Cloud storage CLI for move operations |
| Windows Batch Script | Archive logic and dynamic date calculation |
| Node.js | Local REST API bridge for n8n |
| n8n | Visual workflow orchestration and scheduling |
| Telegram Bot API | Real time notifications to phone |
| Windows Task Scheduler | Auto start n8n and server.js on boot + failsafe |

---

## Prerequisites

Install all tools before setup:

| # | Tool | Download |
|---|---|---|
| 1 | MEGA Desktop App | https://mega.io/desktop |
| 2 | MEGAcmd | https://mega.io/cmd |
| 3 | Node.js (v20+) | https://nodejs.org |
| 4 | n8n | `npm install -g n8n` |
| 5 | Telegram | via @BotFather in Telegram app |
| 6 | Git | https://git-scm.com |

---

## Installation Guide

### Step 1 — MEGA Desktop App

1. Download and install from https://mega.io/desktop
2. Login with your MEGA account
3. Set your sync folder to a local path e.g:
```
C:\Users\<yourname>\Documents\MEGA
```

---

### Step 2 — MEGAcmd

MEGAcmd gives you command line control over your MEGA cloud storage.
It works as two parts:

```
MEGAcmd server  = runs in background, manages MEGA connection
MEGAclient.exe  = sends commands to the server from scripts
```

**Install:**
- Download from https://mega.io/cmd
- Install — MEGAclient.exe will be available at:
```
C:\Users\<yourname>\AppData\Local\MEGAcmd\MEGAclient.exe
```

**Verify installation:**
```powershell
C:\Users\<yourname>\AppData\Local\MEGAcmd\MEGAclient.exe version
```

**Login to MEGA via CMD:**
```powershell
MEGAclient.exe login your@email.com
```

**Register your sync folder:**
```powershell
MEGAclient.exe sync "C:\Users\<yourname>\Documents\MEGA\Reolink_cams" "/MEGA/Reolink_cams"
```

**Verify sync is active:**
```powershell
MEGAclient.exe sync
```
You should see status: `ACTIVE`

**Verify cloud folders exist:**
```powershell
MEGAclient.exe ls /MEGA/
```

---

### Step 3 — Node.js

1. Download LTS version from https://nodejs.org
2. Install with default settings
3. Verify:
```powershell
node --version
npm --version
```

---

### Step 4 — n8n

n8n is a visual workflow automation tool. It orchestrates the daily 
archive trigger and Telegram notification.

**Install:**
```powershell
npm install -g n8n
```

**Verify:**
```powershell
n8n --version
```

**Start n8n:**
```powershell
n8n start
```

**Open in browser:**
```
http://localhost:5678
```

- Register with email and password (free, stays on your PC)
- Activate your free license key when prompted

**Import the workflow:**
1. Click **+** New workflow
2. Click **⋮** menu (top right)
3. Click **Import from file**
4. Select `n8n_workflow.json` from this repo
5. Click **Save**
6. Click **Activate** toggle (top right) — turns workflow ON

> **Important:** The workflow must be **Active** to trigger automatically.
> Inactive workflows do not fire even if n8n is running.

---

### Step 5 — Telegram Bot

A Telegram bot sends you a notification every time the archive runs.

**Create your bot:**
1. Open Telegram → search `@BotFather`
2. Send `/newbot`
3. Choose a display name e.g. `Home Automation`
4. Choose a username e.g. `home_auto_ravi_bot` (must end in `bot`)
5. BotFather gives you a **Bot Token** — save it safely:
```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

> ⚠️ Never share your Bot Token publicly — treat it like a password.

**Get your Chat ID:**
1. Search your bot in Telegram → click **Start** → send `hello`
2. Open this URL in your browser (replace with your token):
```
https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
```
3. Find this in the response:
```json
"chat": { "id": 123456789 }
```
4. Save that number — it is your **Chat ID**

**Configure in n8n:**
1. Open the workflow in n8n
2. Click the **Telegram node**
3. Credential → **Create new**
4. Paste your **Bot Token** → Save
5. Set **Chat ID** to your number
6. Save the workflow

**Test the bot:**
Click **Test step** on the Telegram node — you should receive a message 
on your phone immediately.

---

### Step 6 — Configure mega_archive.bat

Open `mega_archive.bat` and update the paths to match your PC:

```bat
SET "MEGACMD_DIR=C:\Users\<yourname>\AppData\Local\MEGAcmd"
SET "INCOMING=/MEGA/Reolink_cams"
SET "ARCHIVE=/MEGA/Camera_Archive"
```

Replace `<yourname>` with your Windows username.

---

### Step 7 — Configure server.js

Open `server.js` and verify the bat file path matches your PC:

```javascript
exec('cmd /c "C:\\dev\\portfolio\\reolink-archive-pipeline\\mega_archive.bat"')
```

---

### Step 8 — Run startup.bat

This registers all scheduled tasks automatically.

1. Right click `startup.bat`
2. Select **Run as Administrator**
3. Click **Yes** on UAC popup

You should see:
```
[1/3] Registering n8n auto start... Done.
[2/3] Registering server.js auto start... Done.
[3/3] Registering backup archive task... Done.
All tasks registered successfully!
```

This registers:

| Task | Trigger | Purpose |
|---|---|---|
| n8n Auto Start | PC Boot | Starts n8n automatically |
| n8n Runner Server | PC Boot | Starts server.js automatically |
| MEGA Reolink Archive Backup | Daily 10:15AM | Failsafe backup trigger |

> **Note:** The primary 10:00AM trigger is handled by n8n's internal 
> Schedule Trigger node — not Windows Task Scheduler.

---

### Step 9 — Test the full pipeline

**Manual test:**
1. Make sure n8n is running (`n8n start`)
2. Make sure server.js is running (`node server.js`)
3. Open browser:
```
http://localhost:3000/run-archive
```
4. You should see:
```json
{ "success": true, "message": "Archive completed" }
```
5. Check your Telegram — notification should arrive

**Test n8n workflow manually:**
1. Open http://localhost:5678
2. Open your workflow
3. Click **Test workflow**
4. All 3 nodes should turn green ✅
5. Telegram notification arrives on phone ✅

---
## Output - Screenshot
<img width="986" height="313" alt="image" src="https://github.com/user-attachments/assets/8ca2810c-4f9d-46de-bcd8-5989442381ef" />


## How It Works — Code Explained

### mega_archive.bat

```bat
:: Calculate yesterday's date dynamically
FOR /F "tokens=1-3 delims=/" %%A IN (
  'powershell -Command "Get-Date (Get-Date).AddDays(-1) -Format MM/dd/yyyy"'
) DO (
    SET "MONTH=%%A"
    SET "DAY=%%B"
    SET "YEAR=%%C"
)
```
👆 Uses PowerShell inside bat to calculate yesterday's date.
Result: `MONTH=05`, `DAY=03`, `YEAR=2026`

```bat
:: Check folder exists before moving
MEGAclient.exe ls "%YESTERDAY_PATH%" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Already archived or no recordings.
    goto :done
)
```
👆 Checks if folder exists first. If already moved → exits cleanly.
This is called **idempotent** behaviour — safe to run multiple times.

```bat
:: Move to archive
MEGAclient.exe mv "%YESTERDAY_PATH%" "%ARCHIVE_PATH%/"
```
👆 Moves folder inside MEGA cloud — no re-uploading, instant move.

---

### server.js

```javascript
const http = require('http');
const { exec } = require('child_process');
```
👆 `http` creates the web server. `exec` runs system commands.

```javascript
if (req.url === '/run-archive' && req.method === 'GET') {
```
👆 Only responds to our specific endpoint — basic security check.

```javascript
exec('cmd /c "C:\\dev\\portfolio\\reolink-archive-pipeline\\mega_archive.bat"',
  (error, stdout, stderr) => {
```
👆 Runs the bat file. Callback fires when bat finishes.

```javascript
res.end(JSON.stringify({ success: true, output: stdout }));
```
👆 Returns result as JSON — n8n reads this to know if it succeeded.

> **Why do we need server.js?**
> n8n's Code node sandboxes JavaScript for security and blocks 
> `child_process`. server.js runs outside that sandbox on your PC 
> and acts as a bridge between n8n and your system.

---

### n8n Workflow (3 nodes)

```
[Schedule Trigger: Daily 10AM]
            ↓
[HTTP Request: GET localhost:3000/run-archive]
            ↓
[Telegram: Send result to phone]
```

> **How n8n workflow runs automatically:**
> When n8n starts, it loads all Active workflows from its internal 
> database. The Schedule Trigger node watches the clock and fires 
> the workflow at 10AM daily — no manual intervention needed.
> `n8n_workflow.json` in this repo is a backup copy for version 
> control and restore purposes.

---

## Failsafe Architecture

```
Normal day:
10:00AM → n8n fires → archive done → Telegram sent ✅
10:15AM → backup bat runs → already archived → exits cleanly ✅

If n8n crashes:
10:00AM → n8n not running → nothing happens ❌
10:15AM → backup bat runs directly → archive done ✅
         (no Telegram but storage protected)
```

> If you stop receiving Telegram messages, check if n8n is running.
> Your recordings are still being archived by the failsafe.

---

## Project Structure

```
reolink-archive-pipeline/
├── README.md               ← this file
├── mega_archive.bat        ← daily archive logic
├── server.js               ← local REST API bridge
├── startup.bat             ← one click task registration
└── n8n_workflow.json       ← n8n workflow backup/restore
```

---

## Key Concepts Demonstrated

| Concept | Where used |
|---|---|
| FTP protocol | Reolink camera upload |
| Cloud storage CLI | MEGAclient.exe commands |
| REST API design | server.js endpoints |
| JSON data format | API responses between nodes |
| Workflow orchestration | n8n 3 node pipeline |
| Error handling | Idempotent bat script |
| Failsafe architecture | Primary + backup triggers |
| Infrastructure as Code | startup.bat registers all tasks |
| Bot API integration | Telegram notifications |
| Version control | Git + GitHub |

---

## Lessons Learned

- n8n Code node sandboxes `child_process` — use a local HTTP server as bridge
- MEGA CMD `mv` returns success even on empty paths — always check with `ls` first
- Batch scripts must be **non-interactive** for automation — remove all `pause` commands
- Always test each component independently before connecting end to end
- `git push -f` overwrites remote history — use carefully in team projects
- Windows Task Scheduler requires **Run as Administrator** to register system tasks

---

## Future Improvements

- [ ] Dockerise server.js for reliable auto start on boot
- [ ] Log each archive run to Google Sheets via n8n
- [ ] Camera offline detection — alert if no new recordings found
- [ ] Weekly summary report on Telegram
- [ ] Migrate batch script to Python for cross platform support
- [ ] Add n8n error workflow — notify if archive fails

---

## Author

**Ravivarma Singaravelu**  
Software Developer | Automation Enthusiast  
Dresden, Germany  
github.com/raviamrav
