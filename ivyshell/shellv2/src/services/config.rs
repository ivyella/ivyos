use serde::Deserialize;
use serde_json;
use std::fs;

#[derive(Deserialize)]
pub struct FontConfig {
    pub ui: String,
    pub mono: String,
    pub scale: f32,
    pub weight: u32,
}
impl Default for FontConfig {
    fn default() -> Self {
        Self {
            ui: "IBM Plex Serif".to_string(),
            mono: "JetBrains Mono".to_string(),
            scale: 1.0,
            weight: 400,
        }
    }
}

#[derive(Deserialize)]
pub struct NightLightConfig {
    pub temp: u32,
}
impl Default for NightLightConfig {
    fn default() -> Self {
        Self { temp: 4000 }
    }
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Config {
    pub theme: String,
    pub variant: String,
    pub wallpaper: String,
    pub border_radius: u32,
    pub ui_scale: f32,
    pub font: FontConfig,
    pub night_light: NightLightConfig,
}
impl Default for Config {
    fn default() -> Self {
        Self {
            theme: "/home/ivy/ivyos/ivyshell/themes/colors/IvyTheme.json".to_string(),
            variant: "default".to_string(),
            wallpaper: "/home/ivy/ivyos/ivyshell/themes/wallpapers/a_close_up_of_water.png"
                .to_string(),
            border_radius: 12,
            ui_scale: 1.0,
            font: FontConfig::default(),
            night_light: NightLightConfig::default(),
        }
    }
}

pub fn load() -> Config {
    let home = std::env::var("HOME").unwrap_or_default();
    let path = format!("{}/.config/ivyshell/config.json", home);
    let contents = fs::read_to_string(&path).unwrap_or_default();
    serde_json::from_str(&contents).unwrap_or_else(|_| Config::default())
}
