pub struct NetworkState {
    pub enabled: bool,
    pub ssid: String,
    pub connection_type: String
}

pub fn get_network() -> NetworkState {
    let output = std::process::Command::new("nmcli")
        .args(["-t", "-f","TYPE","con","show","--active"])
        .output()
        .unwrap();
    let text = String::from_utf8_lossy(&output.stdout).to_string();
    let connection_type = if text.contains("ethernet") {
        "ethernet".to_string()
        } else if text.contains("wireless") {
            "wifi".to_string()
        } else {
            "".to_string()
        };
    let enabled = connection_type != "";

    let ssid = if connection_type == "wifi" {
        let output = std::process::Command::new("nmcli")
            .args(["-t", "-f", "ACTIVE,SSID", "dev", "wifi"])
            .output()
            .unwrap();
        let text = String::from_utf8_lossy(&output.stdout).to_string();
        text.lines()
            .find(|l| l.starts_with("yes:"))
            .and_then(|l| l.split(':').nth(1))
            .unwrap_or("Disconnected")
            .to_string()
    } else {
        "Disconnected".to_string()
    };

    NetworkState {
        enabled,
        ssid,
        connection_type
        }

    }

pub fn toggle(enable: bool) {
    let state = if enable { "on" } else { "off" };
    std::process::Command::new("nmcli")
        .args(["radio", "wifi", state])
        .output()
        .unwrap();
}