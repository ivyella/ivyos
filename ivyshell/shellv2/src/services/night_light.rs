pub struct NightLightState {
    pub enabled: bool,
}

pub fn enable(){
    let mut child = std::process::Command::new("wlsunset")
        .args(["-t", "4000", "-T", "4001"])
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .stdin(std::process::Stdio::null())
        .spawn()
        .unwrap();
    
    std::thread::spawn(move || {
        child.wait().unwrap();
    });
}
pub fn disable(){
    std::process::Command::new("pkill")
        .args(["-x", "wlsunset"])
        .output()
        .unwrap();
    std::thread::sleep(std::time::Duration::from_millis(100));
    }

pub fn get_status() -> NightLightState {
    let status = std::process::Command::new("pgrep")
        .args(["-x", "wlsunset"])
        .output()
        .unwrap();
    NightLightState {
        enabled: status.status.success()
    }
}