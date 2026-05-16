use std::os::unix::net::UnixStream;
use std::io::{BufReader, Write, Read};

pub fn send(command: &str) {
    let mut stream = UnixStream::connect(crate::core::server::SOCKET_PATH).unwrap();
    writeln!(stream, "{}", command).unwrap();
    let mut reader = BufReader::new(&stream);
    let mut response = String::new();
    reader.read_to_string(&mut response).unwrap();
    print!("{}", response);
}