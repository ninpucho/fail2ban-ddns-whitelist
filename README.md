# fail2ban-ddns-whitelist.sh
This script monitor a list of ddns urls and add them to a jail ignoreip if they change. This is usefull for securing a server in the cloud with fail2ban and ensuring that the home dhcp ip does not get banned.
save file to
```
sudo wget -O /usr/local/bin/fail2ban-ddns-whitelist.sh https://raw.githubusercontent.com/ninpucho/fail2ban-ddns-whitelist/refs/heads/main/fail2ban-ddns-whitelist.sh
```
make the script exicutable.
```
sudo chmod +x /usr/local/bin/fail2ban-ddns-whitelist.sh
```
### Requirements:
The dig package is required.
```
sudo dnf install bind-utils
```
# fail2ban-ddns.service
save file to
```
sudo wget -O /etc/systemd/system/fail2ban-ddns.service https://raw.githubusercontent.com/ninpucho/fail2ban-ddns-whitelist/refs/heads/main/fail2ban-ddns.service
```
# fail2ban-ddns.timer
This time will run the script at certain intervals.
```
sudo wget -O /etc/systemd/system/fail2ban-ddns.timer https://raw.githubusercontent.com/ninpucho/fail2ban-ddns-whitelist/refs/heads/main/fail2ban-ddns.timer
```

# Enable Systemd Services
```
sudo systemctl daemon-reload
sudo systemctl enable --now fail2ban-ddns.timer
```

# Check Logging
```
journalctl -u fail2ban-ddns.service
```
### Follow Logging
```
journalctl -fu fail2ban-ddns.service
```
