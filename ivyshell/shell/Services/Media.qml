pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // ── State ─────────────────────────────────────────────────────────────────
    property var    player:    null
    property string title:     ""
    property string artist:    ""
    property string artUrl:    ""
    property bool   isPlaying: false
    property bool   isSpotify: false
    property bool   isFirefox: false
    property bool   canNext:   false
    property bool   canPrev:   false

    readonly property string preferredPlayer: "spotify"
    readonly property bool   hasPlayer: player !== null && title !== ""

    // ── Player resolution ─────────────────────────────────────────────────────
    function findActivePlayer() {
        const players = Mpris.players.values
        if (players.length === 0) return null

        // prefer currently playing
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i]
        }

        // prefer spotify
        const spotify = players.find(p => p.identity.toLowerCase().includes(preferredPlayer))
        if (spotify) return spotify

        // keep current if still alive
        if (root.player) {
            const stillExists = players.find(p => p.identity === root.player.identity)
            if (stillExists) return stillExists
        }

        return players[0] ?? null
    }

    function refresh() {
        const p = findActivePlayer()
        root.player    = p
        root.title     = p?.trackTitle  ?? ""
        root.artist    = p?.trackArtist ?? ""
        root.artUrl    = p?.trackArtUrl ?? ""
        root.isPlaying = p?.playbackState === MprisPlaybackState.Playing
        root.isSpotify = p ? p.identity.toLowerCase().includes("spotify")  : false
        root.isFirefox = p ? p.identity.toLowerCase().includes("firefox")  : false
        root.canNext   = p?.canGoNext     ?? false
        root.canPrev   = p?.canGoPrevious ?? false
    }

    // ── Controls ──────────────────────────────────────────────────────────────
    function togglePlaying() { if (root.player) root.player.togglePlaying() }
    function next()          { if (root.canNext) root.player.next() }
    function previous()      { if (root.canPrev) root.player.previous() }

    // ── Update triggers ───────────────────────────────────────────────────────
    Connections {
        target: Mpris.players
        function onValuesChanged() { root.refresh() }
    }

    Timer {
        interval: 2000
        repeat:   true
        running:  true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}