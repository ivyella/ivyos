use crate::services;
use std::io::{BufRead, BufReader, Write};
use std::os::unix::net::UnixListener;

pub const SOCKET_PATH: &str = "/run/user/1000/shellv2.sock";

pub fn start() {
    println!("shellv2 daemon started on {}", SOCKET_PATH);
    let _ = std::fs::remove_file(SOCKET_PATH);
    let listener = UnixListener::bind(SOCKET_PATH).unwrap();
    for stream in listener.incoming() {
        let stream = stream.unwrap();
        let mut reader = BufReader::new(&stream);
        let mut input = String::new();
        reader.read_line(&mut input).unwrap();
        handle(&input, &stream);
    }
}

pub fn handle(input: &str, mut writer: impl Write) {
    let args: Vec<&str> = input.split_whitespace().collect();
    match args[0] {
        "time" => writeln!(writer, "{}", services::clock::format_time()).unwrap(),
        "date" => writeln!(writer, "{}", services::clock::format_date()).unwrap(),
        "volume" => {
            let state = services::audio::get_audio();
            writeln!(writer, "Volume: {}%", state.volume).unwrap();
            writeln!(writer, "Muted: {}", state.muted).unwrap();
        }
        "weather" => {
            let state = services::weather::get_weather();
            writeln!(writer, "Temperature: {}°C", state.temperature).unwrap();
            writeln!(writer, "Condition: {}", state.condition).unwrap();
            writeln!(writer, "Humidity: {}%", state.humidity).unwrap();
            writeln!(writer, "Wind Speed: {} km/h", state.wind_speed).unwrap();
        }
        "nightlight" => match args[1] {
            "on" => services::night_light::enable(),
            "off" => services::night_light::disable(),
            "status" => {
                let state = services::night_light::get_status();
                writeln!(
                    writer,
                    "Night light: {}",
                    if state.enabled { "on" } else { "off" }
                )
                .unwrap();
            }
            _ => writeln!(writer, "unknown nightlight command").unwrap(),
        },
        "network" => match args[1] {
            "enable" => services::network::toggle(true),
            "disable" => services::network::toggle(false),
            "status" => {
                let state = services::network::get_network();
                writeln!(writer, "Type {}", state.connection_type).unwrap();
                writeln!(writer, "SSID {}", state.ssid).unwrap();
                writeln!(
                    writer,
                    "Enabled {}",
                    if state.enabled { "on" } else { "off" }
                )
                .unwrap();
            }
            _ => writeln!(writer, "unknown network command").unwrap(),
        },
        "bluetooth" => match args[1] {
            "enable" => services::bluetooth::toggle(true),
            "disable" => services::bluetooth::toggle(false),
            "status" => {
                let state = services::bluetooth::get_bluetooth();
                writeln!(
                    writer,
                    "Available {}",
                    if state.available { "on" } else { "off" }
                )
                .unwrap();
                writeln!(
                    writer,
                    "Enabled {}",
                    if state.enabled { "on" } else { "off" }
                )
                .unwrap();
                writeln!(writer, "Device {}", state.connected_device).unwrap();
            }
            _ => writeln!(writer, "unknown bluetooth command").unwrap(),
        },
        "brightness" => match args[1] {
            "status" => {
                let state = services::brightness::get_brightness();
                writeln!(writer, "Available: {}", state.available).unwrap();
                writeln!(writer, "Level: {}%", state.level).unwrap();
            }
            "set" => {
                let val = args[2].parse::<u32>().unwrap_or(50);
                services::brightness::set_level(val);
            }
            _ => writeln!(writer, "unknown brightness command").unwrap(),
        },
        "battery" => {
            let state = services::battery::get_battery();
            writeln!(writer, "Available: {}", state.available).unwrap();
            writeln!(writer, "Charge Status: {}", state.charging).unwrap();
            writeln!(writer, "Level: {}%", state.level).unwrap();
            writeln!(writer, "Critical: {}", state.is_low).unwrap();
        }
        _ => writeln!(writer, "unknown command").unwrap(),
    }
}
