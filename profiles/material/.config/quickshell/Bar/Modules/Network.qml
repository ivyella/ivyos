import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common
import QtQuick.Layouts

Rectangle {
    id: networkCapsule
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: networkLayout.implicitWidth + Metrics.paddingMd * 2

    property bool connected: activeConnectionType != ""
    property string activeConnectionType: ""

    RowLayout {
        id: networkLayout
        anchors.centerIn: parent
        spacing: Metrics.spacingSm
        Text {
            id: networkIcon
            text: "󰈀"
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            
            font.weight: 600
        }
        Text {
            id: networkText
            text: networkCapsule.connected ? networkCapsule.activeConnectionType : "Disconnected"
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
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
            if (type.includes("wireless")) return "Wireless";
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