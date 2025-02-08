# 🖧 Uptime Monitor (Local & External)

This project was created to **monitor random internet disconnections** (in my case, the unreliable OpenFiber Italy) and provide **documented proof** to your ISP, including timestamps and downtime duration.

## 🔹 How It Works
The script comes in **two versions**:
- **Internal Network Monitoring:** Runs inside your local network, checking connectivity from your machine.
- **External Monitoring:** Runs from a **remote VPS or another location**, pinging your **public IP**.  
  - This allows you to **cross-check logs** from both locations, proving that the issue lies with your ISP and **not** your local network (LAN).

## 💡 Why Use This?

✅ Prove to your ISP that the issue is not your LAN, the main excuse for not investigating is "WiFi coverage or interference" or "cabling issues".

✅ Monitor uptime/downtime with exact timestamps.

✅ Receive instant notifications via Telegram or Gotify.

✅ Works on Windows (PowerShell) & Linux (Bash).

### 📢 **Notifications (Gotify & Telegram)**
The **external monitoring version** supports **Gotify** and **Telegram** notifications.  
- Get **real-time alerts** when your connection **goes down** or is **restored**.
- Fully **configurable** with simple parameters.

---

## 🚀 **Installation & Usage**
### **1️⃣ Choose Your Version**
- **Internal Monitoring:** Runs on your local machine.
- **External Monitoring:** Runs on a VPS or another remote system.

### **2️⃣ Configure the Script**
Modify the following parameters in the script to suit your setup.

# 🔹 **For PowerShell (Windows)**
```powershell
# 🌐 Monitoring Target (IP to check for internet reachability)
$TARGET_IP = "8.8.8.8"
```
Use for example 8.8.8.8 for internal check and your public IP address for the external.

#### 📢 Gotify parameters
```powershell
$GotifyToken = "CHANGE_ME"
$GotifyServer = "CHANGE_ME"
$GotifyPort = "CHANGE_ME"
$NOTIFY_ENABLED = $true  # Enable (true) or disable (false) Gotify notifications
```

#### 📬 Telegram parameters
```powershell
$TELEGRAM_ENABLED = $true  # Enable (true) or disable (false) Telegram notifications
$TELEGRAM_BOT_TOKEN = "CHANGE_ME"
$TELEGRAM_CHAT_ID = "CHANGE_ME"
```

# 🔹 **For Bash (Linux)**

#### 🌐 Monitoring Target (IP to check for internet reachability)
```bash
TARGET_IP="8.8.8.8"
```
Use for example 8.8.8.8 for internal check and your public IP address for the external.

#### 📢 Gotify parameters (modifiable for easy future management)
```bash
GotifyToken="CHANGE_ME"
GotifyServer="CHANGE_ME"
GotifyPort="CHANGE_ME"
```

#### Enable (true) or disable (false) Gotify notifications
```bash
NOTIFY_ENABLED=true
```

#### 📬 Telegram parameters
```bash
TELEGRAM_ENABLED=true
TELEGRAM_BOT_TOKEN="CHANGE_ME"
TELEGRAM_CHAT_ID="CHANGE_ME"
```
---

# 📜 How It Works

- The script continuously checks internet connectivity by pinging the target IP (default: 8.8.8.8 for internal).
- If a disconnection is detected:
  - The timestamp is logged.
  - A Gotify/Telegram notification is sent (for the outside script if enabled).
  - The script waits for reconnection.
- Once reconnected:
  - The recovery timestamp and downtime duration are logged.
  - A Gotify/Telegram notification is sent (for the outside script if enabled).
  - Loop repeats indefinitely.

# 📝 Log Example
```text
Disconnection detected: 10-02-2024 14:35:22
Reconnected at 10-02-2024 14:40:50 - Downtime duration: 00:05:28
```
