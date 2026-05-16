use crate::services;
use std::os::unix::net::UnixListener;
use std::io::{BufRead, BufReader, Write};

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

pub fn handle(input: &str, mut writer: impl Write){
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
    "nightlight" => {
        match args[1] {
            "on" => services::night_light::enable(),
            "off" => services::night_light::disable(),
            "status" => {
                let state = services::night_light::get_status();
                writeln!(writer, "Night light: {}", if state.enabled { "on" } else { "off" }).unwrap();
            } 
            _ => writeln!(writer, "unknown nightlight command").unwrap()
        }
    }
    _ => writeln!(writer, "unknown command").unwrap()
    }
}
