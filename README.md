# Reolink Archive Pipeline

Automated CCTV cloud archival pipeline that moves yesterday's Reolink 
camera recordings from local storage to MEGA cloud daily and sends a 
real-time Telegram notification.

---

## Architecture

```
Reolink Camera → FTP → Local PC → MEGA Sync → MEGA Cloud (Reolink_cams)
                                                        ↓
                                                mega_archive.bat
                                                        ↓
                                          MEGA Cloud (Camera_Archive)
                                                        ↓
                                             Telegram Notification
```

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Reolink FTP | Camera recording upload to local PC |
| MEGA Desktop App | Syncs local folder to MEGA cloud |
| MEGAcmd / MEGAclient | Cloud storage CLI for move operations |
| Windows Batch Script | Archive logic and date calculation |
| Node.js | Local REST API bridge for n8n |
| n8n | Workflow orchestration and scheduling |
| Telegram Bot API | Real time notifications |
| Windows Task Scheduler | Backup daily trigger and auto start |

---

## Prerequisites

| Step | Tool | Download |
|---|---|---|
| 1 | MEGA Desktop App | https://mega.io/desktop |
| 2 | MEGAcmd | https://mega.io/cmd |
| 3 | Node.js | https://nodejs.org |
| 4 | n8n | `npm install -g n8n` |
| 5 | Telegram Bot | via @BotFather in Telegram |
| 6 | Git | https://git-scm.com |

---

## Installation

### 1. MEGA Desktop App + MEGAcmd

- Install MEGA Desktop App and login with your MEGA account
- Set sync folder to your local MEGA folder
- Install MEGAcmd separately from https://mega.io/cmd
- Verify MEGAclient is available:

```powershell
C:\Users\<yourname>\AppData\Local\MEGAcmd\MEGAclient.exe version
```

- Register your sync folder:

```powershell
MEGAclient.exe sync "C:\Users\<yourname>\Documents\MEGA\Reolink_cams" "/MEGA/Reolink_cams"
```

- Verify sync is active:

```powershell
MEGAclient.exe sync
```

> **Note:** MEGAcmd runs as a background server. MEGAclient.exe is the 
> command line tool that sends instructions to it.

---

### 2. Node.js

```powershell
# Verify after installing from nodejs.org
node --version
npm --version
```

---

### 3. n8n

```powershell
# Install globally
npm install -g n8n

# Start n8n
n8n start

# Open in browser
http://localhost:5678
```

- Register and activate your free license
- Import `n8n_workflow.json`:
  - Click **+** New workflow
  - Click **⋮** menu top right
  - Click **Import from file**
  - Select `n8n_workflow.json`

---

### 4. Telegram Bot

1. Open Telegram → search `@BotFather`
2. Send `/newbot` → follow prompts → save your **Bot Token**
3. Search your bot → click **Start** → send any message
4. Get your Chat ID:

```
https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
```

5. Find `"chat":{"id": XXXXXXXXXX}` → save that number
6. In n8n Telegram node → Credential → paste Bot Token and Chat ID

---

### 5. Register All Scheduled Tasks

Right click `startup.bat` → **Run as Administrator**

This registers:

| Task | Trigger | Purpose |
|---|---|---|
| n8n Auto Start | PC Boot | Starts n8n automatically |
| n8n Runner Server | PC Boot | Starts server.js automatically |
| MEGA Reolink Archive | Daily 10:00AM | Primary archive trigger |
| MEGA Reolink Archive Backup | Daily 10:15AM | Failsafe backup trigger |

---

## How It Works

### 1. Camera Recording
Reolink camera uploads recordings via FTP to local MEGA sync folder 
in `YYYY/MM/DD` folder structure.

### 2. Cloud Sync
MEGA Desktop App watches the local folder and automatically syncs 
new files to MEGA cloud under `/MEGA/Reolink_cams`.

### 3. Daily Archive Script
`mega_archive.bat` runs daily at 10AM and:
- Calculates yesterday's date dynamically
- Checks if yesterday's folder exists in MEGA cloud
- Moves it from `Reolink_cams` to `Camera_Archive` via MEGAclient.exe
- If already archived → exits cleanly with no error
- Frees up local PC space automatically as MEGA syncs the change

### 4. Local REST API
`server.js` runs a Node.js HTTP server on port 3000.
n8n cannot execute local commands directly due to sandbox restrictions,
so this server acts as a bridge.

```
GET http://localhost:3000/run-archive
→ runs mega_archive.bat
→ returns JSON result to n8n
```

### 5. n8n Workflow
Three node workflow:

```
Schedule Trigger (10AM)
        ↓
HTTP Request → http://localhost:3000/run-archive
        ↓
Telegram → sends result to phone
```

### 6. Telegram Notification
Sends daily archive report directly to your phone via Telegram Bot API.

---

## Key Concepts Demonstrated

- **REST API** design and consumption
- **CLI automation** using MEGAcmd
- **Error handling** and idempotent script execution
- **Workflow orchestration** with n8n
- **Failsafe architecture** — primary + backup triggers
- **Infrastructure as Code** — startup.bat registers all tasks
- **Real time notifications** via Telegram Bot API

---

## Lessons Learned

- n8n Code node sandboxes `child_process` for security
- MEGA CMD `mv` returns success even on empty folders
- Batch scripts must be **non-interactive** for automation
- Always test each component independently before connecting
- `git push -f` overwrites remote — use carefully in team projects

---

## Future Improvements

- [ ] Dockerise server.js for reliable auto start on boot
- [ ] Log each run to Google Sheets via n8n
- [ ] Alert if no new recordings found (camera offline detection)
- [ ] Weekly summary report on Telegram
- [ ] Migrate batch script to Python for cross platform support

---

## Author
**Ravivarma Singaravelu**  
Software Developer | Automation Enthusiast  
Dresden, Germany
