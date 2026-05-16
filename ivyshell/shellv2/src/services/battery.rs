pub struct BatteryState {
    pub available: bool,
    pub level: u32,
    pub charging: bool,
    pub is_low: bool
}

pub fn get_battery() -> BatteryState {
    let available = std::path::Path::new("/sys/class/power_supply/BAT1/capacity").exists();
    let level = if available {
        std::fs::read_to_string("/sys/class/power_supply/BAT1/capacity")
            .unwrap_or_default()
            .trim()
            .parse::<u32>()
            .unwrap_or(0)
    } else {
        0
    };
    let charging = if available {
        std::fs::read_to_string("/sys/class/power_supply/BAT1/status")
            .unwrap_or_default()
            .trim() == "Charging"
        } else {
            false
        };
    let is_low = available && level <= 20;

    BatteryState { 
        available,
        level, 
        charging, 
        is_low 
    }
}