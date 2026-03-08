import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    id: mediaCapsule
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: mprisLayout.implicitWidth + Theme.padding.md
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
        spacing: Theme.spacing.sm

        
        Rectangle {
            id: spotifyIconBackdrop
            visible: mediaCapsule.isSpotify
            color: Theme.color.bg3
            height: Theme.height.sm
            radius: Theme.radius.lg  // optional, if you want it round
            implicitWidth: spotifyIcon.implicitWidth + Theme.padding.sm * 2
            MdIcons {
                id: spotifyIcon
                anchors.centerIn: parent
                text: "music_note_2"
                iconSize: Theme.icon.sm
                fill: 1
            }
        }
        Rectangle {
            id: firefoxIconBackdrop
            visible: mediaCapsule.isFirefox
            color: Theme.color.bg3
            height: Theme.height.sm
            radius: Theme.radius.lg  // optional, if you want it round
            implicitWidth: firefoxIcon.implicitWidth + Theme.padding.sm * 2
            MdIcons {
                id: firefoxIcon
                anchors.centerIn: parent
                text: "language"
                iconSize: Theme.icon.sm
                fill: 1
            }
        }

        Text {
            text: mediaCapsule.title
            color: Theme.color.fg0
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            text: "•"
            color: Theme.color.accent0
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            text: mediaCapsule.artist
            color: Theme.color.fg1
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