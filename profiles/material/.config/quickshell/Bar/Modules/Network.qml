import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common
import QtQuick.Layouts

Rectangle {
    id: networkCapsule
    color: Theme.color.surface
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: networkLayout.implicitWidth + Theme.padding.md * 2

    property bool connected: activeConnectionType != ""
    property string activeConnectionType: ""

    RowLayout {
        id: networkLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        Text {
            id: networkIcon
            text: "󰈀"
            color: Theme.color.text
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            id: networkText
            text: networkCapsule.connected ? networkCapsule.activeConnectionType : "Disconnected"
            color: Theme.color.subtext
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    function refresh() {
        refreshProcess.running = true;
    }

    Process {
        id: refreshProcess
        command: ["nmcli", "-t", "-f", "TYPE", "con", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const types = this.text.split("\n");
                const firstType = types[0] || "";
                networkCapsule.activeConnectionType = refreshProcess.formatType(firstType);
            }
        }
        
        function formatType(type) {
            if (type.includes("ethernet")) return "Connected";
            if (type.includes("wireless")) return "Connected";
            return "";
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: networkCapsule.refresh()
        }
    }

    Component.onCompleted: refresh()
}