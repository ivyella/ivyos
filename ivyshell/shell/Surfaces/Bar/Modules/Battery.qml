import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Rectangle {
    id: batteryCapsule
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: batteryAvailable ? batteryLayout.implicitWidth + Theme.padding.md : 0
    visible: batteryAvailable

    property int batteryLevel: 100
    property bool isCharging: false
    property bool isLow: batteryLevel <= 20
    property bool batteryAvailable: false

    RowLayout {
        id: batteryLayout
        spacing: Theme.spacing.sm

        Rectangle {
            id: batteryIconBackdrop
            color: Theme.color.bg3
            height: batteryCapsule.height
            radius: Theme.radius.lg
            implicitWidth: batteryIcon.implicitWidth + Theme.padding.sm * 2

            MdIcons {
                id: batteryIcon
                anchors.centerIn: parent
                iconSize: Theme.icon.sm
                fill: 1
                color: batteryCapsule.isLow && !batteryCapsule.isCharging
                    ? Theme.color.red0
                    : batteryCapsule.isCharging
                        ? Theme.color.green1
                        : Theme.color.accent0
                text: {
                    if (batteryCapsule.isCharging) return "battery_android_bolt"
                    const lvl = batteryCapsule.batteryLevel
                    if (lvl >= 95) return "battery_android_full"
                    if (lvl >= 80) return "battery_android_6"
                    if (lvl >= 65) return "battery_android_5"
                    if (lvl >= 50) return "battery_android_4"
                    if (lvl >= 35) return "battery_android_3"
                    if (lvl >= 20) return "battery_android_2"
                    if (lvl >= 10) return "battery_android_1"
                    return "battery_android_0"
                }
            }
        }

        Text {
            id: batteryText
            text: batteryCapsule.batteryLevel
            color: batteryCapsule.isLow && !batteryCapsule.isCharging
                ? Theme.color.red0
                : Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    // --- check battery exists ---
    Process {
        id: batCheckProc
        command: ["bash", "-c", "test -f /sys/class/power_supply/BAT1/capacity && echo yes || echo no"]
        stdout: SplitParser {
            onRead: data => {
                batteryCapsule.batteryAvailable = data.trim() === "yes"
            }
        }
        Component.onCompleted: running = true
    }

    // --- read battery level ---
    Process {
        id: batLevelProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT1/capacity"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const val = parseInt(data.trim())
                if (!isNaN(val)) batteryCapsule.batteryLevel = val
            }
        }
    }

    // --- read charging status ---
    Process {
        id: batStatusProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT1/status"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                batteryCapsule.isCharging = data.trim() === "Charging"
            }
        }
    }

    // --- poll every 30s ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!batteryCapsule.batteryAvailable) return
            batLevelProc.running = true
            batStatusProc.running = true
        }
    }
}
