pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    
    property string currentTime: formatTime()
    property string currentDate: formatDate()

    function formatTime() {
        return Qt.formatDateTime(new Date(), "hh:mm AP")
    }
    function formatDate() {
        return Qt.formatDateTime(new Date(), "ddd, MMM dd")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = root.formatTime();
            root.currentDate = root.formatDate();
        }
    }
}