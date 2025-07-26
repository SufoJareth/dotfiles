#!/bin/bash

set -e

# === Configurable Values ===
NETNS="mwo-vpn"
WG_CONFIG="/home/sufojareth/Scripts/wireguard/mwo.conf"
VETH_HOST="veth-host"
VETH_NS="veth-mwo"
BRIDGE_SUBNET="10.200.200.0/24"
VETH_HOST_IP="10.200.200.1"
VETH_NS_IP="10.200.200.2"

# Automatically detect your main internet interface (e.g., enp5s0, eth0)
OUT_IF=$(ip route get 1.1.1.1 | awk '{print $5; exit}')

# === Create Namespace and Veth Pair ===
echo "[+] Creating network namespace: $NETNS"
sudo ip netns add "$NETNS"

echo "[+] Creating veth pair"
sudo ip link add "$VETH_HOST" type veth peer name "$VETH_NS"
sudo ip link set "$VETH_NS" netns "$NETNS"

# === Configure Host Side ===
echo "[+] Configuring host side of veth"
sudo ip addr add "$VETH_HOST_IP/24" dev "$VETH_HOST"
sudo ip link set "$VETH_HOST" up

# === Configure Namespace Side ===
echo "[+] Configuring namespace side"
sudo ip netns exec "$NETNS" ip addr add "$VETH_NS_IP/24" dev "$VETH_NS"
sudo ip netns exec "$NETNS" ip link set "$VETH_NS" up
sudo ip netns exec "$NETNS" ip link set lo up
sudo ip netns exec "$NETNS" ip route add default via "$VETH_HOST_IP"

# === Set Up NAT ===
echo "[+] Enabling IP forwarding and NAT"
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -A POSTROUTING -s "$BRIDGE_SUBNET" -o "$OUT_IF" -j MASQUERADE

# === Start WireGuard ===
echo "[+] Starting WireGuard inside namespace"
sudo ip netns exec "$NETNS" wg-quick up "$WG_CONFIG"

# === Launch Game ===
echo "[+] Launching MechWarrior Online via Steam"
sudo ip netns exec "$NETNS" "$@"

# === Cleanup ===
echo "[+] Game exited. Shutting down WireGuard and tearing down namespace"

sudo ip netns exec "$NETNS" wg-quick down "$WG_CONFIG"
sudo ip link delete "$VETH_HOST"
sudo ip netns delete "$NETNS"
sudo iptables -t nat -D POSTROUTING -s "$BRIDGE_SUBNET" -o "$OUT_IF" -j MASQUERADE

echo "[✓] Clean shutdown complete"
