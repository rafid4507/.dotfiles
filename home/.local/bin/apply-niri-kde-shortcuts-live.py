#!/usr/bin/env python3
"""Apply the custom Niri-style shortcut set live through KGlobalAccel D-Bus."""
import json
import subprocess
import sys

META = 0x10000000
CTRL = 0x04000000
SHIFT = 0x02000000
ALT = 0x08000000

LETTERS = {c: ord(c) for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"}
DIGITS = {str(n): 0x30 + n for n in range(10)}
RETURN = 0x01000004
TAB = 0x01000001
ESC = 0x01000000
KRUNNER_ALT_F2 = 16777362  # existing KRunner shortcut, preserved as alternative


def k(m=False, c=False, s=False, a=False, key=0):
    return (META if m else 0) | (CTRL if c else 0) | (SHIFT if s else 0) | (ALT if a else 0) | key


COMPONENTS = {
    "kwin": "/component/kwin",
    "ksmserver": "/component/ksmserver",
    "plasmashell": "/component/plasmashell",
    "org.kde.krunner.desktop": "/component/org_kde_krunner_desktop",
    "org.kde.konsole.desktop": "/component/org_kde_konsole_desktop",
    "systemsettings.desktop": "/component/systemsettings_desktop",
    "org.kde.plasma-systemmonitor.desktop": "/component/org_kde_plasma_systemmonitor_desktop",
}

wanted = {}


def add(component, action, keys):
    wanted.setdefault(component, {})[action] = keys


# ---- Meta: switch to the window left / right in the current workspace ----
add("kwin", "Switch Window Left", [k(m=True, key=LETTERS["H"])])
add("kwin", "Switch Window Right", [k(m=True, key=LETTERS["L"])])
add("kwin", "karousel-column-move-left", [])
add("kwin", "karousel-column-move-right", [])
add("kwin", "karousel-focus-previous", [])
add("kwin", "karousel-focus-next", [])

# ---- Karousel: tile the monitor that currently has focus ----
add("kwin", "karousel-screen-switch",
    [k(m=True, key=LETTERS["M"]), k(m=True, c=True, key=RETURN)])

# ---- Alt: focus column / window ----
add("kwin", "karousel-focus-left", [k(a=True, key=LETTERS["H"])])
add("kwin", "karousel-focus-right", [k(a=True, key=LETTERS["L"])])

# ---- Alt: focus window above / below in the column ----
add("kwin", "karousel-focus-up", [k(a=True, key=LETTERS["J"])])
add("kwin", "karousel-focus-down", [k(a=True, key=LETTERS["K"])])

# ---- Workspace navigation and moving columns ----
add("kwin", "Switch to Previous Desktop", [k(m=True, key=LETTERS["J"])])
add("kwin", "Switch to Next Desktop", [k(m=True, key=LETTERS["K"])])
add("kwin", "karousel-column-move-to-previous-desktop", [k(m=True, key=LETTERS["U"])])
add("kwin", "karousel-column-move-to-next-desktop", [k(m=True, key=LETTERS["I"])])

for n in range(1, 10):
    add("kwin", f"karousel-focus-{n}", [])

# ---- Keep the existing window-moving keys ----
for name, letter in [
    ("karousel-window-move-left", "H"),
    ("karousel-window-move-right", "L"),
    ("karousel-window-move-up", "K"),
    ("karousel-window-move-down", "J"),
]:
    add("kwin", name, [k(m=True, c=True, key=LETTERS[letter])])

add("kwin", "karousel-window-toggle-floating", [k(m=True, key=LETTERS["V"])])
add("kwin", "karousel-cycle-preset-widths", [k(m=True, key=LETTERS["R"])])
add("kwin", "Window Maximize", [k(m=True, key=LETTERS["F"])])
add("kwin", "Window Close", [k(m=True, key=LETTERS["Q"])])

# Karousel Overview owns Meta+O; Plasma's built-in Overview gets no shortcut.
add("kwin", "Karousel Overview",
    [k(m=True, key=LETTERS["O"]), k(m=True, c=True, key=LETTERS["O"])])
add("kwin", "Overview", [])
add("kwin", "Walk Through Windows",
    [k(a=True, key=TAB), k(m=True, key=TAB), k(m=True, key=LETTERS["Z"])])
add("kwin", "Walk Through Windows (Reverse)",
    [k(a=True, s=True, key=TAB), k(m=True, s=True, key=TAB)])

# Desktop 4 uses Meta+9, desktop 5 uses Meta+0, desktop 9 has no direct key.
SWITCH_DIGITS = {1: "1", 2: "2", 3: "3", 4: "9", 5: "0", 6: "6", 7: "7", 8: "8", 9: None}
for n, digit in SWITCH_DIGITS.items():
    keys = [k(m=True, key=DIGITS[digit])] if digit is not None else []
    add("kwin", f"Switch to Desktop {n}", keys)
    add("kwin", f"Window to Desktop {n}", [k(m=True, c=True, key=DIGITS[str(n)])])
add("kwin", "Switch to Desktop 10", [])

# ---- Session / Plasma ----
add("ksmserver", "Lock Session", [k(c=True, a=True, key=LETTERS["L"])])
add("plasmashell", "show-on-mouse-pos", [k(m=True, s=True, key=LETTERS["V"])])
add("plasmashell", "activate widget 190", [])
add("plasmashell", "activate widget 4", [])
add("plasmashell", "manage activities", [])
for n in (1, 2, 3, 9):
    add("plasmashell", f"activate task manager entry {n}", [k(m=True, a=True, key=DIGITS[str(n)])])
for n in (4, 5, 6, 7, 8):
    add("plasmashell", f"activate task manager entry {n}", [])

# ---- Launchers ----
add("org.kde.krunner.desktop", "_launch", [KRUNNER_ALT_F2, k(m=True, key=LETTERS["D"])])
add("org.kde.konsole.desktop", "_launch",
    [k(m=True, key=RETURN), k(m=True, key=LETTERS["T"])])
add("systemsettings.desktop", "_launch", [k(m=True, key=LETTERS["S"])])
add("org.kde.plasma-systemmonitor.desktop", "_launch", [k(c=True, s=True, key=ESC)])


def busctl_json(*args):
    res = subprocess.run(
        ["busctl", "--user", *args, "--json=short"],
        check=True, capture_output=True, text=True,
    )
    return json.loads(res.stdout)


def descriptor(component, unique):
    data = busctl_json(
        "call", "org.kde.kglobalaccel", COMPONENTS[component],
        "org.kde.kglobalaccel.Component", "allShortcutInfos",
    )["data"][0]
    for entry in data:
        if entry[0] == unique:
            return [entry[2], entry[0], entry[3], entry[1]]
    raise RuntimeError(f"Action {unique!r} not found in {component}")


def set_shortcut(desc, keys):
    args = ["call", "org.kde.kglobalaccel", "/kglobalaccel",
            "org.kde.KGlobalAccel", "setShortcut", "asaiu"]
    args += [str(len(desc)), *desc]
    args += [str(len(keys)), *(str(x) for x in keys)]
    args += ["4"]  # LoadFlag: no autoload, keep this setting
    return busctl_json(*args)["data"][0]


def ensure_karousel_overview():
    """The effect must be loaded before its global shortcut action exists."""
    res = subprocess.run(
        ["qdbus6", "org.kde.KWin", "/Effects",
         "org.kde.kwin.Effects.isEffectLoaded", "karousel_overview"],
        capture_output=True, text=True,
    )
    if res.stdout.strip() != "true":
        subprocess.run(
            ["qdbus6", "org.kde.KWin", "/Effects",
             "org.kde.kwin.Effects.loadEffect", "karousel_overview"],
            check=True, capture_output=True, text=True,
        )
        print("Loaded Karousel Overview effect.")


ensure_karousel_overview()

applied = 0
for component, actions in wanted.items():
    for unique, keys in actions.items():
        try:
            desc = descriptor(component, unique)
        except RuntimeError as exc:
            print(f"WARN {exc}; skipping", file=sys.stderr)
            continue
        result = set_shortcut(desc, keys)
        expected = sorted(keys)
        if sorted(result) != expected:
            print(f"WARN {component}:{unique} -> {result}, expected {keys}", file=sys.stderr)
        applied += 1

print(f"Applied {applied} shortcuts live via KGlobalAccel.")
