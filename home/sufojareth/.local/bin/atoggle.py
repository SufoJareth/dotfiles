#!/usr/bin/env python3

import subprocess
import time
import os

# Define your sink names
HEADPHONES = "alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y7G20GM3312CC3-00.HiFi__Line1__sink"
SPEAKERS = "alsa_output.usb-Bose_Corporation_Bose_USB_Audio-00.analog-surround-21"
STATE_FILE = os.path.expanduser("~/.gameaudio_output_state")

def get_sinks():
    result = subprocess.run(["pactl", "list", "short", "sinks"], capture_output=True, text=True)
    sinks = [line.split()[1] for line in result.stdout.strip().splitlines()]
    return sinks

def get_current_output():
    result = subprocess.run(["pactl", "list", "short", "modules"], capture_output=True, text=True)
    for line in result.stdout.strip().splitlines():
        if "module-loopback" in line and "source=GAMEAUDIO.monitor" in line:
            for part in line.split():
                if part.startswith("sink="):
                    return part.split("=")[1]
    return None

def unload_existing_loopbacks():
    result = subprocess.run(["pactl", "list", "short", "modules"], capture_output=True, text=True)
    for line in result.stdout.strip().splitlines():
        if "module-loopback" in line and "source=GAMEAUDIO.monitor" in line:
            module_id = line.split()[0]
            subprocess.run(["pactl", "unload-module", module_id])

def mute_sink(sink, mute=True):
    subprocess.run(["pactl", "set-sink-mute", sink, "1" if mute else "0"], stderr=subprocess.DEVNULL)

def load_loopback(sink):
    subprocess.run([
        "pactl", "load-module", "module-loopback",
        f"source=GAMEAUDIO.monitor",
        f"sink={sink}",
        "latency_msec=30",
        "use_smoother=1"
    ])

def main():
    sinks = get_sinks()
    hp_avail = HEADPHONES in sinks
    sp_avail = SPEAKERS in sinks

    if not (hp_avail or sp_avail):
        print("[ERROR] Neither output sink is currently available.")
        return

    current = get_current_output()
    if current == HEADPHONES and sp_avail:
        new_target = SPEAKERS
        with open(STATE_FILE, "w") as f:
            f.write("speakers\n")
    elif current == SPEAKERS and hp_avail:
        new_target = HEADPHONES
        with open(STATE_FILE, "w") as f:
            f.write("headphones\n")
    elif current is None:
        new_target = HEADPHONES if hp_avail else SPEAKERS
        with open(STATE_FILE, "w") as f:
            f.write("headphones\n" if new_target == HEADPHONES else "speakers\n")
    else:
        print("[INFO] No valid toggle path or already on correct sink.")
        return

    print(f"[INFO] Switching GAMEAUDIO output to: {new_target}")

    # Mute before switching
    mute_sink(HEADPHONES, True)
    mute_sink(SPEAKERS, True)
    time.sleep(0.3)

    unload_existing_loopbacks()
    load_loopback(new_target)
    time.sleep(0.3)

# Unmute both to ensure fallback works if a sink disappears
    mute_sink(HEADPHONES, False)
    mute_sink(SPEAKERS, False)

if __name__ == "__main__":
    main()
