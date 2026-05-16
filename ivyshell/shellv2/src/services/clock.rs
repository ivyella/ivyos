use chrono::Local;

pub fn format_time() -> String {
    let time = Local::now();
    time.format("%I:%M %p").to_string()
}

pub fn format_date() -> String {
    let date = Local::now();
    date.format("%a, %b %d").to_string()
}
