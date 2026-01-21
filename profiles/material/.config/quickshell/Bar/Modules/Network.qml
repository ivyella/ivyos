import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Bar

Capsule {
    id: networkCapsule
    width: networkText.implicitWidth + 18

    property bool connected: activeConnectionType != ""
    property string activeConnection: ""
    property string activeConnectionType: ""
    property string activeConnectionIcon: ""


    Text {
        id: networkText
        anchors.centerIn: networkCapsule
        text: networkCapsule.connected ? networkCapsule.activeConnection + "" + networkCapsule.activeConnectionType : "Disconnected"
        color: Config.fontColorSecondary
        font.pixelSize: Config.fontSizeNormal
        font.family: Config.fontFamily
        font.bold: true
    }
    
    function refresh() {
        refreshProcess.running = true;
    }

    Process {
        id: refreshProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "con", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const interfaces = this.text.split("\n");
                const activeInterface = interfaces[0];
                const fields = activeInterface.split(":");
                const connectionType = refreshProcess.getConnectionType(fields[1]);
                networkCapsule.activeConnectionType = connectionType;
                networkCapsule.activeConnectionIcon = refreshProcess.getConnectionIcon(connectionType);
                networkCapsule.activeConnection = connectionType != "" ? fields[0] : "N/A";
            }
        }

        function getConnectionType(nmcliOutput: string): string {
            if (nmcliOutput.includes("ethernet")) {
                return "󰈀   Ethernet";
            } else if (nmcliOutput.includes("wireless")) {
                return "󰖩   Wireless";
            }
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
}
