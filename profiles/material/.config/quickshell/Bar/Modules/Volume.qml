import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar

Capsule {
    id: volumeCapsule
    width: volumeLevelText.implicitWidth + Config.capsuleMargin

    property int volumeLevel: 0

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var match = data.match(/Volume:\s*([\d.]+)/);
                if (match) {
                    volumeLevel = Math.round(parseFloat(match[1]) * 100);
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Fast timer for window/layout/workspace (sway doesn't have event hooks in quickshell)
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            volProc.running = true;
        }
    }
    

    Text {
        id: volumeLevelText
        text: "󰕾  " + volumeLevel + ""
        color: Config.fontColorSecondary
        font.pixelSize: Config.fontSizeNormal
        font.family: Config.fontFamily
        font.bold: true
        anchors.centerIn: parent
    }
    
}
