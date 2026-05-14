#!/bin/bash
# Open5GS 2.7.x + MongoDB 8.0 + WebUI install script
# Tested on Ubuntu 24.04 LTS (Noble)
# Usage: sudo bash install.sh [SERVER_IP]

set -euo pipefail

SERVER_IP="${1:-$(hostname -I | awk '{print $1}')}"
OPEN5GS_VERSION="2.7.7~noble"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info()  { echo "[INFO]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || error "Run as root: sudo bash install.sh"
[[ -n "$SERVER_IP" ]] || error "Could not determine server IP. Pass it as argument: sudo bash install.sh 192.168.1.10"

info "=== Open5GS installer ==="
info "Server IP  : $SERVER_IP"
info "Open5GS ver: $OPEN5GS_VERSION"
info "Ubuntu ver : $(lsb_release -rs)"

# ─── 1. System prerequisites ────────────────────────────────────────────────
info "Installing prerequisites..."
apt-get update -qq
apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release \
    software-properties-common apt-transport-https \
    git wget iptables net-tools

# ─── 2. MongoDB 8.0 ─────────────────────────────────────────────────────────
info "Setting up MongoDB 8.0 repository..."
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
    > /etc/apt/sources.list.d/mongodb-org-8.0.list

apt-get update -qq
apt-get install -y mongodb-org

systemctl enable --now mongod
info "MongoDB started."

# ─── 3. Open5GS ─────────────────────────────────────────────────────────────
info "Setting up Open5GS repository..."
add-apt-repository -y ppa:open5gs/latest
apt-get update -qq
apt-get install -y open5gs

# ─── 4. Apply custom configuration ──────────────────────────────────────────
info "Applying custom configuration files..."
CONFIG_SRC="$REPO_DIR/configs"

for yaml in "$CONFIG_SRC"/*.yaml; do
    dest="/etc/open5gs/$(basename "$yaml")"
    cp "$yaml" "$dest"
    # Replace placeholder IP with actual server IP
    sed -i "s/10\.5\.100\.95/$SERVER_IP/g" "$dest"
done

install -m 644 "$CONFIG_SRC/99-open5gs.conf" /etc/sysctl.d/99-open5gs.conf
sysctl -p /etc/sysctl.d/99-open5gs.conf

# freeDiameter configs (EPC: MME, HSS, SMF, PCRF)
for conf in "$CONFIG_SRC/freeDiameter"/*.conf; do
    install -m 640 "$conf" /etc/freeDiameter/
done

# ─── 5. NAT / iptables ──────────────────────────────────────────────────────
info "Configuring NAT for UE traffic..."
IFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
iptables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE

# Persist iptables rules
apt-get install -y iptables-persistent
netfilter-persistent save

info "NAT configured on interface: $IFACE"

# ─── 6. Open5GS WebUI ───────────────────────────────────────────────────────
info "Installing Node.js for WebUI..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

info "Installing Open5GS WebUI..."
curl -fsSL https://open5gs.org/open5gs/assets/webui/install | bash -

# ─── 7. Restart all services ────────────────────────────────────────────────
info "Restarting Open5GS services..."
systemctl restart \
    open5gs-nrfd open5gs-scpd open5gs-amfd open5gs-smfd open5gs-upfd \
    open5gs-ausfd open5gs-udmd open5gs-udrd open5gs-pcfd open5gs-bsfd \
    open5gs-nssfd open5gs-mmed open5gs-sgwcd open5gs-sgwud \
    open5gs-hssd open5gs-pcrfd open5gs-seppd open5gs-webui

info ""
info "=== Installation complete ==="
info "WebUI: http://$SERVER_IP:9999  (admin / 1423)"
info "PLMN:  MCC=999, MNC=70, TAC=1"
info ""
info "All services:"
systemctl is-active open5gs-*.service mongod.service | paste - <(systemctl list-units --type=service --no-legend | grep -E "open5gs|mongod" | awk '{print $1}') || true
