pub struct BluetoothState {
    pub available: bool,
    pub enabled: bool,
    pub connected_device: String,
}

pub fn get_bluetooth() -> BluetoothState {
    let rfkill = std::process::Command::new("rfkill")
        .args(["list", "bluetooth"])
        .output()
        .unwrap();
    let available = !String::from_utf8_lossy(&rfkill.stdout).trim().is_empty();
    let enabled = if available {
        let output = std::process::Command::new("bluetoothctl")
            .args(["show"])
            .output()
            .unwrap();
        String::from_utf8_lossy(&output.stdout).contains("Powered: yes")
    } else {
        false
    };
    let connected_device = if enabled {
        let output = std::process::Command::new("bluetoothctl")
            .args(["info"])
            .output()
            .unwrap();
        let text = String::from_utf8_lossy(&output.stdout).to_string();
        text.lines()
            .find(|l| l.contains("Name:"))
            .map(|l| l.split("Name:").nth(1).unwrap_or("").trim().to_string())
            .unwrap_or_default()
    } else {
        String::new()
    };

    BluetoothState {
        available,
        enabled,
        connected_device,
    }
}

pub fn toggle(enable: bool) {
    let state = if enable { "on" } else { "off" };
    std::process::Command::new("bluetoothctl")
        .args(["power", state])
        .output()
        .unwrap();
}
