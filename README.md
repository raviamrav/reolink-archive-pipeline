\## Prerequisites — Tools Required



All tools must be installed before running the pipeline.



\---



\### 1. Reolink Camera

Any Reolink camera with FTP support.

Configure FTP settings in the Reolink app:

\- Server: your local PC IP address

\- Port: 21

\- Username/Password: your FTP credentials

\- Upload path: point to your MEGA sync folder



\---



\### 2. MEGA Desktop App + MEGAcmd



MEGA provides two separate tools:



Tool | Purpose

\-----|---------

MEGA Desktop App | Syncs local folder to MEGA cloud automatically

MEGAcmd | Command line interface to control MEGA from scripts



\*\*Install MEGA Desktop App:\*\*

\- Download from: https://mega.io/desktop

\- Install and login with your MEGA account

\- Set sync folder to: `C:\\Users\\<yourname>\\Documents\\MEGA`



\*\*Install MEGAcmd:\*\*

\- Download from: https://mega.io/cmd

\- Install — this adds MEGAclient.exe to:

```

C:\\Users\\<yourname>\\AppData\\Local\\MEGAcmd\\

```

\- Verify installation:

```powershell

C:\\Users\\<yourname>\\AppData\\Local\\MEGAcmd\\MEGAclient.exe version

```



\*\*How MEGAcmd works:\*\*

```

MEGAcmd = background server process

MEGAclient.exe = sends commands to MEGAcmd server



Example:

MEGAclient.exe ls /MEGA/          → lists cloud folders

MEGAclient.exe mv /src /dst       → moves cloud folders

MEGAclient.exe sync local cloud   → registers sync pair

```



\*\*Register your sync folder:\*\*

```powershell

C:\\Users\\<yourname>\\AppData\\Local\\MEGAcmd\\MEGAclient.exe sync "C:\\Users\\<yourname>\\Documents\\MEGA\\Reolink\_cams" "/MEGA/Reolink\_cams"

```



\*\*Verify sync is active:\*\*

```powershell

C:\\Users\\<yourname>\\AppData\\Local\\MEGAcmd\\MEGAclient.exe sync

```



\---



\### 3. Node.js

Required to run server.js and n8n.



\- Download from: https://nodejs.org

\- Install LTS version (v20 or higher)

\- Verify installation:

```powershell

node --version

npm --version

```



\---



\### 4. n8n

Visual workflow automation tool.



\- Install globally via npm:

```powershell

npm install -g n8n

```

\- Verify installation:

```powershell

n8n --version

```

\- Start n8n:

```powershell

n8n start

```

\- Open in browser: http://localhost:5678

\- Register and activate your free license

\- Import `n8n\_workflow.json`:

&#x20; - Click \*\*+\*\* New workflow

&#x20; - Click \*\*3 dots menu\*\* top right

&#x20; - Click \*\*Import from file\*\*

&#x20; - Select `n8n\_workflow.json`



\---



\### 5. Telegram Bot

Required for notifications.



\*\*Create your bot:\*\*

1\. Open Telegram → search `@BotFather`

2\. Send `/newbot`

3\. Follow prompts → save your \*\*Bot Token\*\*



\*\*Get your Chat ID:\*\*

1\. Search your bot in Telegram → click Start → send any message

2\. Open in browser:

```

https://api.telegram.org/bot<YOUR\_TOKEN>/getUpdates

```

3\. Find `"chat":{"id": XXXXXXXXXX}` → save that number



\*\*Configure in n8n:\*\*

\- Open Telegram node in workflow

\- Credential → Create new → paste Bot Token

\- Chat ID → paste your Chat ID



\---



\### 6. Git (optional — for cloning this repo)

\- Download from: https://git-scm.com

\- Verify:

```powershell

git --version

```



\---



\## Installation Summary



| Step| Tool | Download |

|-----|------|----------|

|  1  | MEGA Desktop App | https://mega.io/desktop |

|  2  | MEGAcmd | https://mega.io/cmd |

|  3  | Node.js | https://nodejs.org |

|  4  | n8n     | `npm install -g n8n` |

|  5  | Telegram Bot | via @BotFather in Telegram |

|  6  | Git     | https://git-scm.com |

