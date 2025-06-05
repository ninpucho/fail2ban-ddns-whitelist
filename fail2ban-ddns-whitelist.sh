#!/bin/bash

# ==============================
# CONFIGURATION
# ==============================
# Fail2Ban Jails Separate multiples a by space. i.e. ("sshd" "nginx")
JAILS=("sshd")
# hostnames Separate multiples by a space. i.e. ("home1.dyndns.org" "cabin.noip.com")
HOSTNAMES=("home1.example.com" "home2.example.com")
# Stores last known IPs
IP_FILE_DIR="/var/run/fail2ban-ddns-whitelist"

mkdir -p "$IP_FILE_DIR"

log() {
    logger -t fail2ban-ddns "$*"
}

declare -A CURRENT_IPS

# STEP 1: Resolve all hostnames
for HOSTNAME in "${HOSTNAMES[@]}"; do
    IP=$(dig +short "$HOSTNAME" | grep -E '^[0-9.]+' | head -n 1)
    if [[ -n "$IP" ]]; then
        CURRENT_IPS["$HOSTNAME"]="$IP"
    else
        log "Failed to resolve $HOSTNAME"
    fi
done

# STEP 2: Apply updates per hostname
for HOSTNAME in "${!CURRENT_IPS[@]}"; do
    IP="${CURRENT_IPS[$HOSTNAME]}"
    SAFE_HOSTNAME="${HOSTNAME//[^a-zA-Z0-9]/_}"
    IP_FILE="$IP_FILE_DIR/$SAFE_HOSTNAME.ip"

    if [[ -f "$IP_FILE" ]]; then
        OLD_IP=$(cat "$IP_FILE")
    else
        OLD_IP=""
    fi

    if [[ "$IP" != "$OLD_IP" ]]; then
        for JAIL in "${JAILS[@]}"; do
            [[ -n "$OLD_IP" ]] && fail2ban-client set "$JAIL" delignoreip "$OLD_IP" && log "Removed $OLD_IP from $JAIL"
            fail2ban-client set "$JAIL" addignoreip "$IP" && log "Added $IP to $JAIL"
        done
        echo "$IP" > "$IP_FILE"
    else
        log "IP for $HOSTNAME unchanged: $IP"
    fi
done
