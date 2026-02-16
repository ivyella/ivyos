import QtQuick
import Quickshell.Io
import Quickshell

Item {
    IpcHandler {
        target: "shell"
        function reload(): void {
            Quickshell.reload(true);
        }
    }
}
