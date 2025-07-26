#!/usr/bin/env python3

import subprocess
import time
import json

# Configuration
TARGET_FL = "GAMEAUDIO:playback_FL"
TARGET_FR = "GAMEAUDIO:playback_FR"
CHECK_INTERVAL = 5  # seconds
VERBOSE = False

# List of game names (exclude "MechWarrior Online")
GAMES = [
    "Monster Hunter Rise"
]

def log(msg):
    if VERBOSE:
        print(msg, flush=True)

def get_ports():
    try:
        output = subprocess.check_output(["pw-dump"], text=True)
        data = json.loads(output)
    except Exception as e:
        log(f"[ERROR] Failed to run pw-dump: {e}")
        return []

    ports = []
    for item in data:
        if item.get("type") != "PipeWire:Interface:Port":
            continue
        props = item.get("info", {}).get("props", {})
        port_name = props.get("port.name")
        port_alias = props.get("port.alias", "")
        if port_name in ["output_FL", "output_FR"]:
            for game in GAMES:
                if port_alias.startswith(f"{game}:"):
                    ports.append((item["id"], port_name))
                    break
    return ports

def get_links():
    links = {}
    try:
        output = subprocess.check_output(["pw-cli", "ls", "Link"], text=True)
    except subprocess.CalledProcessError as e:
        log(f"[ERROR] Failed to list links: {e}")
        return links

    current_id = None
    output_port = None
    input_port = None
    for line in output.splitlines():
        line = line.strip()
        if line.startswith("id "):
            current_id = int(line.split()[1].strip(','))
        elif "link.output.port" in line:
            output_port = int(line.split()[-1].strip('"'))
        elif "link.input.port" in line:
            input_port = int(line.split()[-1].strip('"'))
        if current_id is not None and output_port is not None and input_port is not None:
            links[(output_port, input_port)] = current_id
            current_id = output_port = input_port = None
    return links

def relink_ports(ports):
    links = get_links()
    any_changes = False

    for port_id, port_name in ports:
        target = TARGET_FL if port_name == "output_FL" else TARGET_FR
        target_id = get_port_id_by_alias(target)
        if target_id is None:
            log(f"[WARN] Could not find target port ID for {target}")
            continue

        already_linked = False
        for (out, inp), link_id in links.items():
            if out == port_id:
                if inp == target_id:
                    already_linked = True
                    break
                else:
                    subprocess.run(["pw-cli", "destroy", str(link_id)],
                                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    break

        if not already_linked:
            result = subprocess.run(
                ["pw-link", f"{port_id}.{port_name}", target],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
            )
            if result.returncode == 0:
                log(f"[OK] Linked {port_id}.{port_name} → {target}")
                any_changes = True
            else:
                log(f"[WARN] Failed to link {port_id}.{port_name} → {target}")
                log(f"[DEBUG] stderr: {result.stderr.strip()}")
    return any_changes

def get_port_id_by_alias(alias):
    try:
        output = subprocess.check_output(["pw-dump"], text=True)
        data = json.loads(output)
    except Exception:
        return None

    for item in data:
        if item.get("type") != "PipeWire:Interface:Port":
            continue
        props = item.get("info", {}).get("props", {})
        if props.get("port.alias") == alias:
            return item["id"]
    return None

def main():
    while True:
        ports = get_ports()
        if not ports:
            log("[DEBUG] No matching game ports found.")
        else:
            changed = relink_ports(ports)
            if not changed:
                log("[INFO] No relinking needed.")
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
