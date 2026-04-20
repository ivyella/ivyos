pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Location ──────────────────────────────────────────────────────────────
    property real   latitude:   -33.9249
    property real   longitude:  18.4241
    property string city:       "Cape Town"
    property bool   autoLocate: false

    // ── Weather state ─────────────────────────────────────────────────────────
    property bool   ready:       false
    property int    humidity:    0
    property real   windSpeed:   0
    property int    weatherCode: 0
    property string condition:   ""
    property string icon:        "cloud"
    property bool   isDay:       true

    // ── Internal celsius storage ──────────────────────────────────────────────
    property real _tempC:      0
    property real _feelsLikeC: 0

    // ── Unit ──────────────────────────────────────────────────────────────────
    property string unit: "celsius"

    readonly property string unitSymbol:  unit === "celsius" ? "°C" : "°F"
    readonly property int    temperature: Math.round(unit === "celsius" ? _tempC      : _tempC * 9/5 + 32)
    readonly property int    feelsLike:   Math.round(unit === "celsius" ? _feelsLikeC : _feelsLikeC * 9/5 + 32)

    function toggleUnit() {
        unit = unit === "celsius" ? "fahrenheit" : "celsius"
    }

    // ── Auto-locate via IP ────────────────────────────────────────────────────
    function geolocate() {
        if (!autoLocate) return
        geoProc.running = false
        geoProc.running = true
    }

    Process {
        id: geoProc
        command: ["curl", "-sf", "--max-time", "5", "https://ipapi.co/json/"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                try {
                    const d = JSON.parse(this.text)
                    if (d.latitude && d.longitude) {
                        root.latitude  = d.latitude
                        root.longitude = d.longitude
                        root.city      = d.city ?? root.city
                    }
                } catch (e) {
                    console.warn("Weather: geolocate parse error", e)
                }
                root.fetchWeather()
            }
        }
        onExited: (code) => {
            if (code !== 0) {
                console.warn("Weather: geolocate failed, using default coords")
                root.fetchWeather()
            }
        }
    }

    // ── Fetch weather (always celsius internally) ─────────────────────────────
    function fetchWeather() {
        weatherProc.running = false
        weatherProc.running = true
    }

    Process {
        id: weatherProc
        command: [
            "curl", "-sf", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast" +
            `?latitude=${root.latitude}` +
            `&longitude=${root.longitude}` +
            `&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day` +
            `&temperature_unit=celsius` +
            `&wind_speed_unit=kmh` +
            `&timezone=auto`
        ]
        stdout: StdioCollector {
            onStreamFinished: () => {
                try {
                    const d = JSON.parse(this.text)
                    const c = d.current
                    root._tempC      = c.temperature_2m
                    root._feelsLikeC = c.apparent_temperature
                    root.humidity    = c.relative_humidity_2m
                    root.windSpeed   = Math.round(c.wind_speed_10m)
                    root.weatherCode = c.weather_code
                    root.isDay       = c.is_day === 1
                    root.condition   = root.codeToCondition(c.weather_code)
                    root.icon        = root.codeToIcon(c.weather_code, c.is_day === 1)
                    root.ready       = true
                } catch (e) {
                    console.warn("Weather: parse error", e)
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("Weather: fetch failed, code", code)
        }
    }

    // ── Weather code → condition string ───────────────────────────────────────
    function codeToCondition(code) {
        if (code === 0)  return "Clear"
        if (code === 1)  return "Mostly Clear"
        if (code === 2)  return "Partly Cloudy"
        if (code === 3)  return "Overcast"
        if (code <= 49)  return "Foggy"
        if (code <= 59)  return "Drizzle"
        if (code <= 69)  return "Rainy"
        if (code <= 77)  return "Snowy"
        if (code <= 82)  return "Showers"
        if (code <= 84)  return "Snow Showers"
        if (code <= 99)  return "Thunderstorm"
        return "Unknown"
    }

    // ── Weather code → Material icon ──────────────────────────────────────────
    function codeToIcon(code, day) {
        if (code === 0)  return day ? "clear_day"         : "clear_night"
        if (code <= 2)   return day ? "partly_cloudy_day" : "partly_cloudy_night"
        if (code === 3)  return "cloud"
        if (code <= 49)  return "foggy"
        if (code <= 59)  return "grain"
        if (code <= 69)  return "rainy"
        if (code <= 77)  return "ac_unit"
        if (code <= 82)  return "rainy"
        if (code <= 84)  return "weather_mix"
        if (code <= 99)  return "thunderstorm"
        return "cloud"
    }

    // ── Poll every 30 minutes ─────────────────────────────────────────────────
    Timer {
        interval: 1800000
        running:  true
        repeat:   true
        onTriggered: root.autoLocate ? root.geolocate() : root.fetchWeather()
    }

    Component.onCompleted: {
        root.autoLocate ? root.geolocate() : root.fetchWeather()
    }
}