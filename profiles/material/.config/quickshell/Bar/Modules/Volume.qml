import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common
import QtQuick.Layouts

Rectangle {
    id: volumeCapsule
    color: Theme.color.surface
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: volumeLayout.implicitWidth + Theme.padding.md * 2

    property int volumeLevel: 0

    RowLayout {
        id: volumeLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        Text {
            id: volumeIcon
            text: "󰕾"
            color: Theme.color.text
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            
            font.weight: Theme.font.normal
        }
        Text {
            id: volumeText
            text: volumeLevel
            color: Theme.color.subtext
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
        
            font.weight: Theme.font.normal
        }
    }

    Process {
        id: volControl
    }

    function changeVolume(isUp) {
        const step = 5;
        if (isUp) {
            volumeLevel = Math.min(100, volumeLevel + step);
        } else {
            volumeLevel = Math.max(0, volumeLevel - step);
        }
        const arg = isUp ? "5%+" : "5%-";
        volControl.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", arg, "-l", "1.0"];
        volControl.running = true;
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            changeVolume(wheel.angleDelta.y > 0);
        }
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var match = data.match(/Volume:\s*([\d.]+)/);
                if (match) {
                    let serverVol = Math.round(parseFloat(match[1]) * 100);
                    if (Math.abs(volumeLevel - serverVol) > 2) {
                        volumeLevel = serverVol;
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: volProc.running = true
    }
}