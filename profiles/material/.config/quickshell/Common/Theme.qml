pragma Singleton  
import Quickshell  
import Quickshell.Io  
import QtQuick
import qs.Common  
import qs.Config  
  
Singleton {  
  id: root  
  
  // JSON-driven colors  
  readonly property QtObject color: QtObject {  
    readonly property color base:        themeAdapter.color?.base ?? "#161615"  
    readonly property color surfaceLow:  themeAdapter.color?.surfaceLow ?? "#1c1b1a"  
    readonly property color surface:     themeAdapter.color?.surface ?? "#222120"  
    readonly property color surfaceMid:  themeAdapter.color?.surfaceMid ?? "#3d3a38"  
    readonly property color surfaceHigh: themeAdapter.color?.surfaceHigh ?? "#4a4644"  
    readonly property color text:        themeAdapter.color?.text ?? "#f2eadd"  
    readonly property color subtext:     themeAdapter.color?.subtext ?? "#c7c9a7"  
    readonly property color accent:       themeAdapter.color?.accent ?? "#868868"  
    readonly property color accentDim:    themeAdapter.color?.accentDim ?? "#727459"  
    readonly property color accentDeep:   themeAdapter.color?.accentDeep ?? "#494a39"  
    readonly property color accentWarm:   themeAdapter.color?.accentWarm ?? "#a67d52"  
    readonly property color accentBright: themeAdapter.color?.accentBright ?? "#cad193"  
    readonly property color error:   themeAdapter.color?.error ?? "#b86161"  
    readonly property color success: themeAdapter.color?.success ?? "#668e37"  
    readonly property color warning: themeAdapter.color?.warning ?? "#c29f5e"  
    readonly property color outline:        themeAdapter.color?.outline ?? "#47483b"  
    readonly property color outlineVariant: themeAdapter.color?.outlineVariant ?? "#929283"  
  }  
  
  // JSON-driven font families + hard-coded sizes/weights  
  readonly property QtObject font: QtObject {  
    readonly property string ui:   themeAdapter.font?.ui ?? "Noto Serif"  
    readonly property string mono: themeAdapter.font?.mono ?? "JetBrains Mono"  
  
    readonly property int xs: 10  
    readonly property int sm: 12  
    readonly property int md: 14  
    readonly property int lg: 16  
    readonly property int xl: 20  
  
    readonly property int regular: Font.Normal  
    readonly property int light: 500  
    readonly property int normal: 600  
    readonly property int medium: 700  
    readonly property int bold:    Font.Bold  
  }  
  
  // Hard-coded spacing  
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
  
  // Load theme JSON from Config.currentTheme  
  FileView {  
    id: themeFile  
    path: {  
      const p = Config.currentTheme;  
      return p.startsWith("file://") ? p.slice(7) : p;  
    }  
    blockLoading: true  
    watchChanges: true  
    onFileChanged: reload()  
  
    JsonAdapter {  
      id: themeAdapter  
      property string name  
      property JsonObject color: JsonObject {  
        property string base  
        property string surfaceLow  
        property string surface  
        property string surfaceMid  
        property string surfaceHigh  
        property string text  
        property string subtext  
        property string accent  
        property string accentDim  
        property string accentDeep  
        property string accentWarm  
        property string accentBright  
        property string error  
        property string success  
        property string warning  
        property string outline  
        property string outlineVariant  
      }  
      property JsonObject font: JsonObject {  
        property string ui  
        property string mono  
      }  
    }  
  
    onLoaded: themeAdapter.reload()  
    onAdapterUpdated: writeAdapter()  
  }  
}