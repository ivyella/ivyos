use mpris::PlayerFinder;

pub struct MediaState {
    pub title: String,
    pub artist: String,
    pub art_url: String,
    pub is_playing: bool,
    pub player_name: String,
}

pub fn get_media() -> MediaState {
    let finder = PlayerFinder::new().unwrap_or_else(|_| panic!("could not connect to dbus"));
    let players = finder.find_all().unwrap_or_default();
    let player = players
        .iter()
        .find(|p| p.get_playback_status().ok() == Some(mpris::PlaybackStatus::Playing))
        .or_else(|| players.first());
    let (title, artist, art_url, is_playing, player_name) = match player {
        Some(p) => {
            let meta = p.get_metadata().unwrap_or_default();
            let title = meta.title().unwrap_or("").to_string();
            let artist = meta
                .artists()
                .and_then(|a| a.first().cloned())
                .unwrap_or_default()
                .to_string();
            let art_url = meta.art_url().unwrap_or("").to_string();
            let is_playing = p.get_playback_status().ok() == Some(mpris::PlaybackStatus::Playing);
            let player_name = p.identity().to_string();
            (title, artist, art_url, is_playing, player_name)
        }
        None => (
            "".to_string(),
            "".to_string(),
            "".to_string(),
            false,
            "".to_string(),
        ),
    };
    MediaState {
        title,
        artist,
        art_url,
        is_playing,
        player_name,
    }
}
