use serde::Deserialize;
use std::collections::HashMap;
use std::fs;

#[derive(Deserialize, Clone)]
pub struct ColorTokens {
    pub bg0: String,
    pub bg1: String,
    pub bg2: String,
    pub bg3: String,
    pub bg4: String,
    pub fg0: String,
    pub fg1: String,
    pub fg2: String,
    pub accent0: String,
    pub accent1: String,
    pub border0: String,
    pub border1: String,
    pub gray0: String,
    pub gray1: String,
    pub white: String,
    pub black: String,
    pub yellow0: String,
    pub yellow1: String,
    pub orange0: String,
    pub orange1: String,
    pub red0: String,
    pub red1: String,
    pub magenta0: String,
    pub magenta1: String,
    pub violet0: String,
    pub violet1: String,
    pub blue0: String,
    pub blue1: String,
    pub cyan0: String,
    pub cyan1: String,
    pub green0: String,
    pub green1: String,
}
#[derive(Deserialize, Clone)]
pub struct ThemeVariant {
    pub name: String,
    pub color: ColorTokens,
}

#[derive(Deserialize, Clone)]
pub struct ThemePack {
    pub pack: String,
    pub variants: HashMap<String, ThemeVariant>,
}
pub fn load(path: &str, variant: &str) -> Result<ThemeVariant, String> {
    let contents = fs::read_to_string(path).map_err(|e| e.to_string())?;
    let pack: ThemePack = serde_json::from_str(&contents).map_err(|e| e.to_string())?;
    pack.variants
        .get(variant)
        .cloned()
        .ok_or_else(|| format!("variant '{}' not found", variant))
}
