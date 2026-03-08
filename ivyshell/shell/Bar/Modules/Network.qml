import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common
import QtQuick.Layouts

Rectangle {
    id: networkCapsule
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: networkLayout.implicitWidth + Theme.padding.md

    property string activeConnectionType: ""

    RowLayout {
        id: networkLayout
        
        spacing: Theme.spacing.sm

        Rectangle{
            id: networkIconBackdrop
            color: Theme.color.bg3
            width: networkIcon.iconSize
            height: Theme.height.sm
            radius: Theme.radius.lg  // optional, if you want it round
            implicitWidth: networkIcon.implicitWidth + Theme.padding.sm * 2
            MdIcons {
                id: networkIcon
                anchors.centerIn: parent
                fill: 1
                iconSize: Theme.font.sm
                text: networkCapsule.activeConnectionType === "ethernet" ? "router" :
                    networkCapsule.activeConnectionType === "wifi" ? "wifi" : "wifi_off"
            }
        }

        Text {
            text: networkCapsule.activeConnectionType === "ethernet" ? "Ethernet" :
                  networkCapsule.activeConnectionType === "wifi" ? "Wi-Fi" : "Disconnected"
            color: Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    Process {
        id: refreshProcess
        command: ["nmcli", "-t", "-f", "TYPE", "con", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const types = this.text.split("\n");
                const firstType = types[0] || "";
                if (firstType.includes("ethernet")) networkCapsule.activeConnectionType = "ethernet";
                else if (firstType.includes("wireless")) networkCapsule.activeConnectionType = "wifi";
                else networkCapsule.activeConnectionType = "wifi_off";
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: refreshProcess.running = true
        }
    }

    Component.onCompleted: refreshProcess.running = true
}