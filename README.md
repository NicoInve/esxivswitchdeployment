# VMware ESXi vSwitch Deployment Script (PowerShell)

## 📌 Overview
This PowerShell script automates the creation of **vSwitches** on multiple **VMware ESXi hosts**. 
It takes two CSV files as input:
- **`hosts.csv`** → Contains the list of ESXi hosts where vSwitches will be created.
- **`vswitches.csv`** → Contains the vSwitch configurations, including MTU and associated NICs.

The script uses **PowerCLI** to connect to ESXi hosts and create the specified vSwitches.

---

## 🚀 Prerequisites
Before running the script, ensure you have the following:
1. **PowerShell 5.1 or later** installed on your system.
2. **VMware PowerCLI** module installed. If not, install it using:
   ```powershell
   Install-Module VMware.PowerCLI -Scope CurrentUser -Force
   ```
3. **Administrator privileges** on the ESXi hosts to create vSwitches.
4. **Place `hosts.csv` and `vswitches.csv` in the same directory as the script.**

---

## 📂 CSV File Format
The script requires two CSV files:

### `hosts.csv` (List of ESXi Hosts)
```csv
ESXiHost
esxi01.domain.local
esxi02.domain.local
esxi03.domain.local
```

### `vswitches.csv` (vSwitch Configuration)
```csv
VSwitch,MTU,NICs
vSwitch0,1500,vmnic0,vmnic1
vSwitch1,9000,
```
💡 If the **NICs** column is empty, the vSwitch will be created **without physical NICs** (internal-only network).

---

## 📜 How to Use
1. **Place the script and CSV files** in the same directory.
2. **Open PowerShell as Administrator**.
3. **Navigate to the script folder**:
   ```powershell
   cd "C:\Path\To\Script"
   ```
4. **Run the script**:
   ```powershell
   .\vswitch_deploy.ps1
   ```
5. **Enter credentials** when prompted (ESXi administrator account).

---

## 🛠️ Script Functionality
- Connects to each **ESXi host** listed in `hosts.csv`.
- Reads the **vSwitch configurations** from `vswitches.csv`.
- **Checks if the vSwitch already exists** to avoid duplicates.
- Creates the vSwitch with the specified **MTU and assigned NICs**.
- If **NICs are empty**, the vSwitch will be created **without NICs**.
- **Outputs success messages in green** when a vSwitch is created successfully.
- **Disconnects** from each host after configuration.

---

## ⚠️ Error Handling
| Issue | Solution |
|--------|----------|
| Missing CSV files | Ensure `hosts.csv` and `vswitches.csv` exist in the script directory. |
| Connection failed to ESXi | Check if the ESXi host is reachable and credentials are correct. |
| vSwitch already exists | The script will **skip** existing vSwitches to avoid conflicts. |
| Invalid NICs | Ensure NIC names match those available on the ESXi host. |

---

## 📢 Notes
- The script **requires PowerCLI** to be installed before running.
- It is recommended to **test on a single ESXi host** before deploying on multiple hosts.
- If running on **Windows Server**, ensure **PowerShell Execution Policy** allows scripts:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope Process -Force
  ```

---

## 📄 License
This script is provided "as-is" without warranty. Use at your own risk.
