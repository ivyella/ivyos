import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Bar

Capsule {
    readonly property var player: Mpris.players.values[0]
    width: mprisText.implicitWidth + Config.capsuleMargin

    RowLayout {
        id: mprisText
        anchors.centerIn: parent

        Text {
            text: player.trackTitle
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.bold: true
        }

        Text {
            text: player.trackArtist
            color: Config.fontColorSecondary
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSizeNormal
            font.bold: false
        }
    }
}
