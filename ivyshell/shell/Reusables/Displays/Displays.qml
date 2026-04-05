// Config/Displays.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string primary: adapter.primary ?? ""
    readonly property string secondary: adapter.secondary ?? ""

    function setPrimary(name) {
        if (adapter.secondary === name) adapter.secondary = ""
        adapter.primary = name
        file.writeAdapter()
    }

    function setSecondary(name) {
        if (adapter.primary === name) adapter.primary = ""
        adapter.secondary = name
        file.writeAdapter()
    }

    property var _file: FileView {
        id: file
        path: Quickshell.env("HOME") + "/ivyos/ivyshell/shell/Services/NiriOutputs/displays.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        JsonAdapter {
            id: adapter
            property string primary
            property string secondary
        }
        Component.onCompleted: reload()
    }
}