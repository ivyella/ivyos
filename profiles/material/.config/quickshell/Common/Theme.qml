pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs.Common
import qs.Config

Singleton {
    id: root

    property var _c: ({})
    property var _f: ({})

    function applyVariant() {
        const raw = themeFile.text()
        if (!raw) return
        let pack
        try { pack = JSON.parse(raw) } catch (e) { return }
        const variant = pack.variants?.[Config.currentVariant]
        if (!variant) return
        root._c = variant.color ?? {}
        root._f = variant.font  ?? {}
    }

    readonly property QtObject color: QtObject {
        // backgrounds
        readonly property color bg0: root._c.bg0 ?? "#161615" //base
        readonly property color bg1: root._c.bg1 ?? "#1c1b1a" //surfacelow
        readonly property color bg2: root._c.bg2 ?? "#222120" //surface
        readonly property color bg3: root._c.bg3 ?? "#3d3a38" //surfacemid
        readonly property color bg4: root._c.bg4 ?? "#4a4644" //surfacehigh

        // foregrounds
        readonly property color fg0: root._c.fg0 ?? "#f2eadd" //text
        readonly property color fg1: root._c.fg1 ?? "#c7c9a7" //subtext
        readonly property color fg2: root._c.fg2 ?? "#929283" //muted text

        // accent
        readonly property color accent0: root._c.accent0 ?? "#868868" //accent
        readonly property color accent1: root._c.accent1 ?? "#cad193" //accent bright

        // borders
        readonly property color border0: root._c.border0 ?? "#3d3a38" //outline
        readonly property color border1: root._c.border1 ?? "#47483b"

        // grays
        readonly property color gray0: root._c.gray0 ?? "#494a39"
        readonly property color gray1: root._c.gray1 ?? "#3d3a38"

        // absolutes
        readonly property color white: root._c.white ?? "#f2eadd"
        readonly property color black: root._c.black ?? "#161615"

        // named colors
        readonly property color yellow0:  root._c.yellow0  ?? "#c29f5e"
        readonly property color yellow1:  root._c.yellow1  ?? "#e0bc7a"
        readonly property color orange0:  root._c.orange0  ?? "#a67d52"
        readonly property color orange1:  root._c.orange1  ?? "#c49a6a"
        readonly property color red0:     root._c.red0     ?? "#b86161"
        readonly property color red1:     root._c.red1     ?? "#d47a7a"
        readonly property color magenta0: root._c.magenta0 ?? "#a06080"
        readonly property color magenta1: root._c.magenta1 ?? "#c07898"
        readonly property color violet0:  root._c.violet0  ?? "#7a6898"
        readonly property color violet1:  root._c.violet1  ?? "#9a88b8"
        readonly property color blue0:    root._c.blue0    ?? "#5a7a98"
        readonly property color blue1:    root._c.blue1    ?? "#7a9ab8"
        readonly property color cyan0:    root._c.cyan0    ?? "#5a8a80"
        readonly property color cyan1:    root._c.cyan1    ?? "#7aaaa0"
        readonly property color green0:   root._c.green0   ?? "#668e37"
        readonly property color green1:   root._c.green1   ?? "#88b850"
    }

    readonly property QtObject font: QtObject {
        readonly property string ui:   root._f.ui   ?? "Noto Serif"
        readonly property string mono: root._f.mono ?? "JetBrains Mono"

        readonly property int xs: 10
        readonly property int sm: 12
        readonly property int md: 14
        readonly property int lg: 16
        readonly property int xl: 20

        readonly property int regular: Font.Normal
        readonly property int light:   500
        readonly property int normal:  600
        readonly property int medium:  700
        readonly property int bold:    Font.Bold
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: 2
        readonly property int sm: 4
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    readonly property QtObject height: QtObject {
        readonly property int sm: 22
        readonly property int md: 26
        readonly property int lg: 30
        readonly property int bar: 30
    }

    readonly property QtObject padding: QtObject {
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    readonly property QtObject margin: QtObject {
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    readonly property QtObject icon: QtObject {
        readonly property int sm: 14
        readonly property int md: 16
        readonly property int lg: 18
    }

    readonly property QtObject radius: QtObject {
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    FileView {
        id: themeFile
        path: {
            const p = Config.currentTheme
            return p.startsWith("file://") ? p.slice(7) : p
        }
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyVariant()
    }

    Connections {
        target: Config
        function onCurrentVariantChanged() { root.applyVariant() }
    }
}
