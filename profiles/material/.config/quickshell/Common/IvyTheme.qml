pragma Singleton
import Quickshell
import QtQuick

QtObject {
    // =============
    // Surfaces
    // =============
    readonly property color base:        "#161615"
    readonly property color surface:     "#222120"
    readonly property color surfaceMid:  "#3d3a38"
    readonly property color surfaceHigh: "#4a4644"

    // =============
    // Text
    // =============
    readonly property color text:    "#f2eadd"
    readonly property color subtext: "#c7c9a7"

    // =============
    // Accents
    // =============
    readonly property color accent:      "#868868"
    readonly property color accentDim:   "#727459"
    readonly property color accentDeep:  "#494a39"
    readonly property color accentWarm:  "#a67d52"
    readonly property color accentBright:"#cad193"

    // =============
    // Semantic
    // =============
    readonly property color error:   "#b86161"
    readonly property color success: "#668e37"
    readonly property color warning: '#c29f5e'


    // =============
    // Families
    // =============
    readonly property string ui:   "Noto Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"

    // =============
    // Sizes
    // =============
    readonly property int xs: 10
    readonly property int sm: 12
    readonly property int md: 14
    readonly property int lg: 16
    readonly property int xl: 20

    // =============
    // Weights
    // =============
    readonly property int regular: Font.Normal
    readonly property int medium:  Font.Medium
    readonly property int bold:    Font.Bold
}
