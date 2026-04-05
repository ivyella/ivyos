import QtQuick
import Quickshell
import Quickshell.Io
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

Rectangle {
    id: windowCapsule
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: windowRow.implicitWidth + Theme.padding.md

    property string activeWindow: ""
    property string activeAppId: ""
    property var iconMap: ({})

    Row {
        id: windowRow
        spacing: Theme.spacing.sm

        Rectangle {
            id: appIconBackdrop
            color: Theme.color.bg3
            radius: Theme.radius.lg
            width: appIcon.width + Theme.padding.sm * 2
            height: Theme.height.sm
            visible: windowCapsule.activeAppId !== ""

            Item {
                id: appIcon
                width: Theme.icon.sm
                height: Theme.icon.sm
                anchors.centerIn: parent

                Image {
                    id: iconImg
                    anchors.fill: parent
                    source: {
                        const icon = windowCapsule.iconMap[windowCapsule.activeAppId] ?? ""
                        return icon !== "" ? Quickshell.iconPath(icon, true) : ""
                    }
                    sourceSize: Qt.size(Theme.icon.sm, Theme.icon.sm)
                    asynchronous: true
                    smooth: true
                    visible: status === Image.Ready || status === Image.Loading
                }

                Text {
                    anchors.centerIn: parent
                    visible: iconImg.status === Image.Error
                          || iconImg.status === Image.Null
                          || iconImg.source === ""
                    text: windowCapsule.activeAppId
                        ? windowCapsule.activeAppId.charAt(0).toUpperCase()
                        : "?"
                    color: Theme.color.accent0
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        Text {
            id: activeWindowText
            anchors.verticalCenter: parent.verticalCenter
            text: windowCapsule.activeWindow
            color: Theme.color.fg0
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    Process {
        id: iconScanner
        command: [
            "bash", "-c",
            "find /run/current-system/sw/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null" +
            " | while read f; do" +
            "   id=$(basename \"$f\" .desktop);" +
            "   icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-);" +
            "   [ -n \"$icon\" ] && echo \"$id|$icon\";" +
            " done"
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split("|")
                if (parts.length === 2) {
                    const map = Object.assign({}, windowCapsule.iconMap)
                    map[parts[0].trim()] = parts[1].trim()
                    windowCapsule.iconMap = map
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "niri msg focused-window | grep 'App ID:' | awk -F '\"' '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return;
                const appId = data.trim();

                const names = {
                    "kitty": "Terminal",
                    "librewolf": "LibreWolf",
                    "dev.zed.Zed": "Zed",
                    "org.gnome.Nautilus": "Files",
                    "org.vinegarhq.Sober": "Roblox",
                    "spotify": "Spotify",
                    "steam": "Steam",
                    "krita": "Krita",
                    "com.github.neithern.g4music": "Music",
                    "org.prismlauncher.PrismLauncher": "Prism Launcher",
                    "aseprite": "Aseprite",
                    "obsidian": "Obsidian",
                    "vesktop": "Discord",
                    "org.quickshell":"IvyShell"
                };

                windowCapsule.activeWindow = names[appId] ?? appId;
                windowCapsule.activeAppId = appId;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }
}