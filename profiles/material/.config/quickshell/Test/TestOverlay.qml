// TestOverlay.qml  
import Quickshell  
import Quickshell.Io  
import QtQuick  
  
FloatingWindow {  
  id: overlay  
  visible: false  
  
  Rectangle {  
    anchors.fill: parent  
    color: "black"  
    opacity: 0.8  
    Text {  
      anchors.centerIn: parent  
      text: "Test Overlay"  
      color: "white"  
    }  
  }  
  
  IpcHandler {  
    target: "testoverlay"  
    function toggle(): void {  
      overlay.visible = !overlay.visible;  
    }  
  }  
}