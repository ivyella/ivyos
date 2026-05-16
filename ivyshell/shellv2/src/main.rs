mod core;
mod services;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() > 1 {
        let command = args[1..].join(" ");
        core::client::send(&command);
    } else {
        core::server::start();
    }
}
