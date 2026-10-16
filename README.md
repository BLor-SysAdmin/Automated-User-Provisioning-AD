# Automated Active Directory User Provisioning

## Homelab Network Topology
![Homelab Master Network Topology](https://raw.githubusercontent.com/BLor-SysAdmin/HTC-Network-Administration-Labs/main/homelab-topology-blueprint.png)

A PowerShell automation solution designed to streamline employee onboarding by parsing user data from a CSV file and dynamically provisioning them into Active Directory (AD).

This script eliminates manual entry errors by automatically building out target Organizational Unit (OU) structures based on departments and generating standardized enterprise accounts.

## 🚀 Features

* Automated Directory Structure: Creates a top-level CorpUsers OU automatically if it does not exist.
* Dynamic Departmental OUs: Reads the Department field for each employee and creates nested sub-OUs (e.g., OU=IT, OU=HR) on the fly.
* Standardized Account Generation: Enforces an enterprise username standard (firstname.lastname) and maps out matching User Principal Names (UPNs).
* Idempotent Logic: Checks for existing users and OUs prior to creation to prevent duplicate objects or script crashes.
* Secure Default Status: Generates accounts with a temporary password (TempPass2026!) and forces a password change at the user's very first logon.

## 📋 Prerequisites

Before running this script, ensure your environment meets the following requirements:

* Operating System: Windows Server running as a Domain Controller, or a Windows workstation with RSAT (Remote Server Administration Tools) installed.
* PowerShell Module: The native ActiveDirectory module must be available.
* Permissions: Must be executed from an elevated PowerShell console by an account with Domain Admin privileges or delegated rights to create OUs and Users.

## 🛠️ File Structure & Setup

Automated-User-Provisioning-AD/
│
├── onboard.ps1         # Main deployment script
├── new_hires.csv       # Sample data schema file
└── README.md           # Documentation

### 1. Configure the Data File

Ensure your csv data matches the following schema format and is saved to C:\LabAutomation\new_hires.csv:

Firstname,Lastname,Department,Title
John,Doe,IT,Helpdesk Technician
Jane,Smith,HR,HR Coordinator
Robert,Johnson,Finance,Accountant
Emily,Davis,Sales,Account Executive
Michael,Wilson,IT,Network Administrator

### 2. Update Environment Variables

Open onboard.ps1 and update the domain variables and Distinguished Names (DN) to match your target domain environment:

$Domain = "corp.local" # <--- Change this to match YOUR domain name

# Update the DC paths across the script to match your infrastructure
-Path "DC=corp,DC=local" 

## 💻 Usage

Run the provisioning script from an elevated PowerShell console:

.\onboard.ps1

### Expected Output

The script provides color-coded, real-time terminal feedback as it processes records:

* Green text: Indicates a new parent or Departmental sub-OU was successfully built.
* Cyan text: Confirms successful user account creation and exact OU placement.
* Yellow text: Alerts you if a username conflict exists, gracefully skipping that row to prevent overwrites.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
