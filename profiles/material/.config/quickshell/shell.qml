import Quickshell
import Quickshell.Wayland
import qs.Bar
import qs.Notification
import Quickshell.Io  

ShellRoot {
    
  
// No GUI components - pure IPC handler  
    IpcHandler {  
    id: cliHandler  
    target: "ivy"  // Unique target name for command-line access  
      
    // Echo function - returns whatever text is sent  
        function notify(message: string): string {  
            return message  
        }  
      
    // Math operations  
        function add(a: int, b: int): int {  
            return a + b  
        }  
      
     function multiply(a: int, b: int): int {  
            return a * b  
        }  
      
    // System info  
        function getStatus(): string {  
            return "CLI IPC Handler is running"  
        }  
      
        function getUptime(): string {  
            return "Uptime: " + new Date().toString()  
        }  
    }
}
