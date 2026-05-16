pub struct BrightnessState {
    pub available: bool,
    pub level: u32,
}

pub fn get_brightness() -> BrightnessState {
    let output = std::process::Command::new("brightnessctl")
        .args(["-l", "-c", "backlight"])
        .output()
        .unwrap();
    let available = !String::from_utf8_lossy(&output.stdout).trim().is_empty();
    let level = if available {
        let m_output = std::process::Command::new("brightnessctl")
            .args(["-m"])
            .output()
            .unwrap();
        let text = String::from_utf8_lossy(&m_output.stdout).to_string();
        text.lines()
            .next()
            .and_then(|l| l.split(',').nth(3))
            .and_then(|s| s.trim_end_matches('%').parse::<u32>().ok())
            .unwrap_or(0)
    } else {
        0
    };
    BrightnessState { available, level }
}

pub fn set_level(val: u32) {
    std::process::Command::new("brightnessctl")
        .args(["s", &format!("{}%", val)])
        .output()
        .unwrap();
}
