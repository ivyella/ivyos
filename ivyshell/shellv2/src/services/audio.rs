pub struct AudioState {
    pub volume: u32,
    pub muted: bool,
}

pub fn get_audio() -> AudioState {
    let output = std::process::Command::new("wpctl")
        .args(["get-volume", "@DEFAULT_AUDIO_SINK@"])
        .output()
        .unwrap();

    let text = String::from_utf8_lossy(&output.stdout).to_string();
    let muted = text.contains("[MUTED]");
    let volume_str = text.split_whitespace().nth(1).unwrap_or("0");
    let volume: u32 = (volume_str.parse::<f32>().unwrap_or(0.0) * 100.0) as u32;

    AudioState { volume, muted }
}
