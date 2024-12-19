#!/bin/bash

# Compliance Check for Firewall Configuration
echo "Checking firewall configuration..."

# Get the firewall status
firewall_status=$(sudo ufw status | grep "Status" | awk '{print $2}')
if [[ "$firewall_status" == "active" ]]; then
    echo "✔ Firewall is enabled."
else
    echo "❌ Firewall is NOT enabled. Please enable the firewall."
fi

# Checking if no ports are allowed by default (should not allow any)
allowed_ports=$(sudo ufw status | grep -E "80|443|23|21")
if [[ -z "$allowed_ports" ]]; then
    echo "✔ No ports are allowed by default."
else
    echo "❌ Some ports are allowed by default. Ensure that no ports are allowed except those explicitly required."
fi

# Compliance Check for User Password Policy
echo "Checking user password policy..."
password_policy=$(grep -E "^minlen|^minclass" /etc/security/pwquality.conf)
if [[ "$password_policy" == *"minlen=8"* && "$password_policy" == *"minclass=0"* ]]; then
    echo "✔ Password policy is compliant (minlen=8, minclass=0)."
else
    echo "❌ Password policy is non-compliant. Ensure minlen=8 and minclass=0 in /etc/security/pwquality.conf."
fi

# Compliance Check for Disk Encryption (Root Partition)
echo "Checking disk encryption configuration..."
encrypted_root=$(lsblk -f | grep '/$' | awk '{print $2}')
if [[ "$encrypted_root" == "LUKS" ]]; then
    echo "✔ Root partition is encrypted."
else
    echo "❌ Root partition is NOT encrypted. Please consider encrypting the root partition."
fi

# Checking if /home is encrypted
encrypted_home=$(lsblk -f | grep '/home' | awk '{print $2}')
if [[ "$encrypted_home" == "LUKS" ]]; then
    echo "✔ /home partition is encrypted."
else
    echo "❌ /home partition is NOT encrypted. /home should be encrypted for compliance."
fi

# Checking if multi-factor authentication (MFA) is enabled for admin users
echo "Checking if MFA is enabled for admin users..."
mfa_status=$(grep pam_google_authenticator /etc/pam.d/sshd)
if [[ "$mfa_status" == *"pam_google_authenticator"* ]]; then
    echo "✔ MFA is enabled for administrative users."
else
    echo "❌ MFA is NOT enabled for admin users. Please enable MFA for admin users in /etc/pam.d/sshd."
fi

# Checking if unattended-upgrades is enabled for automatic updates
echo "Checking if unattended-upgrades is configured..."
unattended_upgrades_status=$(dpkg-query -l | grep unattended-upgrades)
if [[ -n "$unattended_upgrades_status" ]]; then
    echo "✔ Automatic updates are enabled."
else
    echo "❌ Automatic updates are NOT enabled. Please install and configure unattended-upgrades."
fi

# Checking USB Restrictions (USB storage should be blocked)
echo "Checking USB storage restrictions..."
usb_storage_status=$(lsmod | grep usb_storage)
if [[ -z "$usb_storage_status" ]]; then
    echo "✔ USB storage is restricted."
else
    echo "❌ USB storage is NOT restricted. Please block USB storage by blacklisting the usb-storage module."
fi

# Checking Antivirus (ClamAV)
echo "Checking Antivirus (ClamAV) configuration..."
clamav_status=$(systemctl is-active clamav-freshclam)
if [[ "$clamav_status" == "inactive" ]]; then
    echo "❌ ClamAV is installed but not running. Please start ClamAV service for regular scans."
else
    echo "✔ ClamAV is active and running."
fi

# Checking AuditD (Activity Logging)
echo "Checking AuditD configuration..."
auditd_status=$(systemctl is-active auditd)
if [[ "$auditd_status" == "active" ]]; then
    echo "✔ AuditD is running."
else
    echo "❌ AuditD is NOT running. Please start the AuditD service for logging activities."
fi

echo "Compliance check complete."