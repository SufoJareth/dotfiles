#!/usr/bin/env python3

import subprocess
import time

# Sink and port definitions
NULL_SINK_NAME = "GAMEAUDIO"
NULL_SINK_DESC = "GAMEAUDIO"
HEADPHONES_SINK_NAME = "alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y7G20GM3312CC3-00.HiFi__Line1__sink"
LOOPBACK_LATENCY = 30


def sink_exists(name):
    result = subprocess.run(["pactl", "list", "short", "sinks"], capture_output=True, text=True)
    return any(name in line for line in result.stdout.strip().split("\n"))


def unload_existing_null_sink():
    result = subprocess.run(["pactl", "list", "short", "modules"], capture_output=True, text=True)
    for line in result.stdout.strip().split("\n"):
        if "module-null-sink" in line and NULL_SINK_NAME in line:
            module_id = line.split("\t")[0]
            subprocess.run(["pactl", "unload-module", module_id])
            break


def load_null_sink():
    subprocess.run([
        "pactl", "load-module", "module-null-sink",
        f"sink_name={NULL_SINK_NAME}",
        f"sink_properties=device.description={NULL_SINK_DESC}"
    ])


def wait_for_sink(name, timeout=5):
    for _ in range(timeout * 10):  # check every 0.1s
        if sink_exists(name):
            return True
        time.sleep(0.1)
    return False


def remove_existing_loopbacks():
    result = subprocess.run(["pactl", "list", "short", "modules"], capture_output=True, text=True)
    for line in result.stdout.strip().split("\n"):
        if "module-loopback" in line and f"source={NULL_SINK_NAME}.monitor" in line:
            module_id = line.split("\t")[0]
            subprocess.run(["pactl", "unload-module", module_id])


def load_loopback(source, sink):
    subprocess.run([
        "pactl", "load-module", "module-loopback",
        f"source={source}",
        f"sink={sink}",
        f"latency_msec={LOOPBACK_LATENCY}"
    ])


# --- Main execution ---
unload_existing_null_sink()
load_null_sink()

if not wait_for_sink(NULL_SINK_NAME):
    print("[ERROR] GAMEAUDIO sink not available after creation.")
    exit(1)

remove_existing_loopbacks()
load_loopback(f"{NULL_SINK_NAME}.monitor", HEADPHONES_SINK_NAME)
print(f"[OK] GAMEAUDIO created and routed to {HEADPHONES_SINK_NAME}.")
