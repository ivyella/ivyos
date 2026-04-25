pragma ComponentBehavior: Bound
pragma Singleton
import Quickshell.Services.Notifications
import QtQuick
import Quickshell

NotificationServer {
    id: notiDaemon
    bodyMarkupSupported: true
    persistenceSupported: true
    imageSupported: true

    property var history: []
    property bool dnd: false

    onNotification: notification => {
        const name = (notification.appName || "").toLowerCase();

        // 🚫 Fully ignore Spotify notifications
        if (name === "spotify") {
            return;
        }

        // Only now allow tracking
        notification.tracked = true;

        history.unshift({
            id: notification.id,
            appName: notification.appName,
            summary: notification.summary,
            body: notification.body,
            timestamp: new Date().toISOString()
        });

        if (history.length > 100)
            history.pop();

        historyChanged();
    }

    onDndChanged: {
        if (!dnd) {
            for (const n of trackedNotifications.values) {
                n.expire();
            }
        }
    }
}