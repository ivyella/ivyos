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
    property bool dnd:     false

    onNotification: notification => {  
        const name = (notification.appName || "").toLowerCase();  
        // Always track so the notification can pop up  
        notification.tracked = true 
    
        // Only add to history (used for unread count) if not Spotify  
        if (name !== "spotify") {  
            history.unshift({  
                id: notification.id,  
                appName: notification.appName,  
                summary: notification.summary,  
                body: notification.body,  
                timestamp: new Date().toISOString()  
            });  
            if (history.length > 100) history.pop();  
            historyChanged();  
        }  
    }
    
    onDndChanged: {
    if (!dnd) {
        // expire all currently tracked notifications so they
        // don't flood in as popups when DND is disabled
        for (const n of trackedNotifications.values) {
            n.expire()
        }
    }
}
}