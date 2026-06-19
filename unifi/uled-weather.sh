#!/bin/bash

API_URL="https://api.open-meteo.com/v1/forecast?latitude=56.9496&longitude=24.1052&current_weather=true&timezone=Europe%2FRiga"

LOG_FILE='uled-weather.log'

PID_FILE='uled-weather.pid'

declare -a COLOR_MAP=(
    "-25:000033"    # Dark navy blue (extreme cold)
    "-24:000044"    # Dark navy blue
    "-23:000055"    # Dark navy blue
    "-22:000066"    # Dark navy blue
    "-21:000077"    # Dark navy blue
    "-20:000088"    # Dark navy blue
    "-19:000099"    # Navy blue
    "-18:0000aa"    # Navy blue
    "-17:0000bb"    # Navy blue
    "-16:0000cc"    # Blue
    "-15:0000dd"    # Blue
    "-14:0000ee"    # Blue
    "-13:0000ff"    # Pure blue
    "-12:0033ff"    # Blue
    "-11:0066ff"    # Blue
    "-10:0099ff"    # Light blue (very cold threshold)
    "-9:00aaff"     # Light blue
    "-8:00bbff"     # Light blue
    "-7:00ccff"     # Light blue
    "-6:00ddff"     # Light blue
    "-5:00eeff"     # Light blue (cold threshold)
    "-4:00ffff"     # Cyan
    "-3:00ffee"     # Light cyan
    "-2:00ffdd"     # Light cyan
    "-1:00ffcc"     # Light cyan
    "0:00ffbb"      # Cyan (freezing point - key threshold)
    "1:00ffaa"      # Cyan-green
    "2:00ff99"      # Cyan-green
    "3:00ff88"      # Cyan-green
    "4:00ff77"      # Cyan-green
    "5:00ff66"      # Green-cyan
    "6:00ff55"      # Green-cyan
    "7:00ff44"      # Green-cyan
    "8:00ff33"      # Green-cyan
    "9:00ff22"      # Green-cyan
    "10:00ff11"     # Green-cyan
    "11:00ff00"     # Green
    "12:11ff00"     # Green
    "13:22ff00"     # Green
    "14:33ff00"     # Green
    "15:44ff00"     # Green
    "16:55ff00"     # Green
    "17:66ff00"     # Green
    "18:77ff00"     # Yellow-green (room temperature - comfort zone)
    "19:88ff00"     # Yellow-green
    "20:99ff00"     # Yellow-green
    "21:aaff00"     # Yellow-green
    "22:bbff00"     # Yellow-green
    "23:ccff00"     # Yellow-green
    "24:ddff00"     # Yellow-green
    "25:ffaa00"     # Orange (warm threshold)
    "26:ff8800"     # Orange
    "27:ff6600"     # Orange
    "28:ff4400"     # Orange-red
    "29:ff2200"     # Orange-red
    "30:ff0000"     # Pure red (hot threshold)
    "31:dd0000"     # Dark red
    "32:bb0000"     # Dark red
    "33:990000"     # Dark red
    "34:770000"     # Dark red
    "35:550000"     # Very dark red (extreme heat)
)

logger() {
    local message="$1"
    echo "$(date --iso-8601=seconds): $message" >> "$LOG_FILE"
}

update_color() {
    local color="$1"
    if [[ -n "$color" ]]; then
        uled-ctrl color "$color"
    fi
}

get_color_for_temp() {
    local temp="$1"
    local temp_int=$(printf "%.0f" "$temp")  # Round to nearest integer

    # Extract min and max temperatures from COLOR_MAP
    local min_temp="${COLOR_MAP[0]%:*}"
    local max_temp="${COLOR_MAP[${#COLOR_MAP[@]}-1]%:*}"  # Use array length instead of -1

    # Use first/last colors for out of range temperatures
    if (( temp_int <= min_temp )); then
        echo "${COLOR_MAP[0]#*:}"  # First color (coldest)
        return
    elif (( temp_int >= max_temp )); then
        echo "${COLOR_MAP[${#COLOR_MAP[@]}-1]#*:}"  # Last color (hottest)
        return
    fi

    # Find exact temperature match in COLOR_MAP
    for mapping in "${COLOR_MAP[@]}"; do
        local map_temp="${mapping%:*}"
        if (( map_temp == temp_int )); then
            echo "${mapping#*:}"
            return
        fi
    done

    # If no exact match, use closest (fallback to first color)
    echo "${COLOR_MAP[0]#*:}"
}

fetch_and_update() {
    logger "Fetching weather from api.open-meteo.com"

    # Fetch weather
    local response
    response=$(curl -s "$API_URL")

    if [[ $? -eq 0 && -n "$response" ]]; then
        local temperature
        temperature=$(echo "$response" | jq -r '.current_weather.temperature')

        if [[ "$temperature" != "null" && -n "$temperature" ]]; then
            local color
            color=$(get_color_for_temp "$temperature")

            logger "Temperature: ${temperature}C, color: ${color}"

            update_color "$color"
        else
            logger "Could not extract temperature from response"
        fi
    else
        logger "Failed to fetch weather"
    fi
}

if [[ "$1" != "--detached" ]]; then
    echo "Starting uled-weather.sh in background..."

    # Check for existing process and kill it
    if [[ -f "$PID_FILE" ]]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
        if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
            # Verify it's actually our script before killing
            CMD=$(ps -p "$OLD_PID" -o cmd= 2>/dev/null)
            if [[ "$CMD" == *"uled-weather.sh"* ]]; then
                echo "Killing existing uled-weather.sh process with PID: $OLD_PID"
                kill -9 "$OLD_PID"
            else
                echo "PID $OLD_PID is not uled-weather.sh (it's: $CMD), skipping kill"
            fi
        fi
        rm -f "$PID_FILE"
    fi

    # Start new
    nohup "$0" --detached > /dev/null 2>&1 &
    PID=$!
    echo "$PID" > "$PID_FILE"
    echo "uled-weather.sh started with PID: $PID"
    exit 0
fi

shift

# Add cleanup trap
trap 'rm -f "$PID_FILE"' EXIT INT TERM

logger "Starting uled-weather.sh with PID $$"

if ! command -v uled-ctrl &> /dev/null; then
    logger "Error: uled-ctrl not found"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    logger "Error: curl not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    logger "Error: jq not found"
    exit 1
fi

# Initial update
fetch_and_update

while true; do
    sleep 3600
    fetch_and_update
done
