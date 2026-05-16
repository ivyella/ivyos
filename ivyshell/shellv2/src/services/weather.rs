use reqwest::blocking::get;
use serde_json::Value;

pub struct WeatherState {
    pub temperature: i32,
    pub condition: String,
    pub humidity: i32,
    pub wind_speed: i32,
}

pub fn get_weather() -> WeatherState {
    let geo = get("https://ipapi.co/json/").unwrap().text().unwrap();
    let geo_json: Value = serde_json::from_str(&geo).unwrap();

    let lat = geo_json["latitude"].as_f64().unwrap_or(-33.9249);
    let lon = geo_json["longitude"].as_f64().unwrap_or(18.4241);
    let url = format!(
        "https://api.open-meteo.com/v1/forecast?latitude={}&longitude={}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&temperature_unit=celsius&wind_speed_unit=kmh&timezone=auto",
        lat, lon
    );
    let weather = get(&url).unwrap().text().unwrap();
    let weather_json: Value = serde_json::from_str(&weather).unwrap();
    let temperature = weather_json["current"]["temperature_2m"]
        .as_f64()
        .unwrap_or(0.0) as i32;
    let humidity = weather_json["current"]["relative_humidity_2m"]
        .as_f64()
        .unwrap_or(0.0) as i32;
    let wind_speed = weather_json["current"]["wind_speed_10m"]
        .as_f64()
        .unwrap_or(0.0) as i32;
    let condition = code_to_condition(
        weather_json["current"]["weather_code"]
            .as_i64()
            .unwrap_or(0) as i32,
    );

    WeatherState {
        temperature,
        condition,
        humidity,
        wind_speed,
    }
}

fn code_to_condition(code: i32) -> String {
    match code {
        0 => "Clear",
        1 => "Mostly Clear",
        2 => "Partly Cloudy",
        3 => "Overcast",
        4..=49 => "Foggy",
        50..=59 => "Drizzle",
        60..=69 => "Rainy",
        70..=77 => "Snowy",
        78..=82 => "Showers",
        83..=84 => "Snow Showers",
        85..=99 => "Thunderstorm",
        _ => "Unknown",
    }
    .to_string()
}
