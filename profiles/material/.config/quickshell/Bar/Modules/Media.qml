import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    id: mediaCapsule
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: mprisLayout.implicitWidth + Metrics.paddingMd * 2
    visible: title !== ""

    property var player: null
    readonly property string title: player ? (player.trackTitle ?? "") : ""
    readonly property string artist: player ? (player.trackArtist ?? "") : ""
    readonly property string preferredPlayer: "spotify"

    function findActivePlayer() {
        const players = Mpris.players.values;
        if (players.length === 0) return null;

        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) return players[i];
        }

        const spotify = players.find(p => p.identity.toLowerCase().includes(preferredPlayer));
        if (spotify) return spotify;

        if (player) {
            const stillExists = players.find(p => p.identity === player.identity);
            if (stillExists) return stillExists;
        }

        return players[0];
    }

    Component.onCompleted: player = findActivePlayer()

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            mediaCapsule.player = mediaCapsule.findActivePlayer();
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: mediaCapsule.player = mediaCapsule.findActivePlayer()
    }

    RowLayout {
        id: mprisLayout
        anchors.centerIn: parent
        spacing: Metrics.spacingSm

        Text {
            text: mediaCapsule.title
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
        }
        Text {
            text: "•"
            color: Config.accentDeep
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
        }
        Text {
            text: mediaCapsule.artist
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 500
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (mediaCapsule.player) mediaCapsule.player.togglePlaying()
        }
        onWheel: wheel => {
            if (!mediaCapsule.player) return
            if (wheel.angleDelta.y > 0) {
                if (mediaCapsule.player.canGoNext) mediaCapsule.player.next()
            } else {
                if (mediaCapsule.player.canGoPrevious) mediaCapsule.player.previous()
            }
        }
    }
}