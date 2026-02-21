import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    id: mediaCapsule
    color: Theme.color.surface
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: mprisLayout.implicitWidth + Theme.padding.md * 2
    visible: title !== ""

    property var player: null
    readonly property string title: player ? (player.trackTitle ?? "") : ""
    readonly property string artist: player ? (player.trackArtist ?? "") : ""
    readonly property string preferredPlayer: "spotify"
    readonly property bool isSpotify: player ? player.identity.toLowerCase().includes("spotify") : false
    readonly property bool isFirefox: player ? player.identity.toLowerCase().includes("firefox") : false

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
        spacing: Theme.spacing.sm

        Text {
        visible: mediaCapsule.isSpotify
        text: ""
        color: Theme.color.subtext
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        }
        Text {
        visible: mediaCapsule.isFirefox
        text: "󰖟"
        color: Theme.color.subtext
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        }

        Text {
            text: mediaCapsule.title
            color: Theme.color.text
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            text: "•"
            color: Theme.color.accentDim
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            text: mediaCapsule.artist
            color: Theme.color.subtext
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.light
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