# WeatherApp Design

**Date:** 2026-04-12
**Stack:** Astro + Svelte + Pico CSS + Open-Meteo API

---

## Overview

A single-page weather app where the user types a city name and sees the current temperature, weather condition, and today's high/low. No authentication required — uses the free, keyless Open-Meteo API.

---

## Architecture

Two files do all the work:

```
src/
  pages/
    index.astro               — page shell: imports Pico CSS, renders the widget
  components/
    WeatherWidget.svelte       — search input, API calls, weather display
```

`index.astro` is mostly static markup — a centered `<main>` with a heading and `<WeatherWidget client:load />`. The `client:load` directive is the Astro islands pattern: Svelte hydrates in the browser, everything else is static HTML.

`WeatherWidget.svelte` owns all interactivity: the search input, two sequential API calls to Open-Meteo, and rendering the result.

---

## Data Flow

When the user submits a city name, the widget makes two sequential calls:

### 1. Geocoding

Resolves the city name to coordinates:

```
GET https://geocoding-api.open-meteo.com/v1/search?name=<city>&count=5
```

The response `results` array is checked:

- **0 results** → set error: "City not found. Please try another name."
- **1 result** → proceed to forecast
- **2+ results** → enter disambiguation state, show candidate list

Each candidate displays as `{name}, {admin1}, {country_code}` (e.g. "London, England, GB").

### 2. Forecast

Once a single location is confirmed (either directly or via user selection):

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=<lat>
  &longitude=<lon>
  &current=temperature_2m,weathercode
  &daily=temperature_2m_max,temperature_2m_min
  &timezone=auto
  &temperature_unit=celsius
```

The widget reads:
- `current.temperature_2m` — current temperature in °C
- `current.weathercode` — mapped to a human-readable condition string
- `daily.temperature_2m_max[0]` — today's high in °C
- `daily.temperature_2m_min[0]` — today's low in °C

WMO weather codes are mapped to condition strings in a local lookup table within the component (e.g. `0` → "Clear sky", `3` → "Overcast", `61` → "Rain").

---

## Reactive State

The widget holds four reactive variables:

| Variable | Type | Purpose |
|---|---|---|
| `loading` | `boolean` | True while any fetch is in-flight |
| `candidates` | `array \| null` | Geocoding results when 2+ cities match |
| `weather` | `object \| null` | Parsed forecast result |
| `error` | `string \| null` | User-facing error message |

The UI renders one of four states: `loading`, `error`, `disambiguating`, or `weather`.

---

## Error Handling

| Scenario | Behaviour |
|---|---|
| City not found (0 geocoding results) | Show "City not found. Please try another name." |
| Network or API error | Show "Something went wrong. Please try again." |
| Empty search submitted | No API call made; input stays focused |

Errors display inline below the search input and clear when the user starts a new search.

---

## Testing

Manual testing scenarios (no automated test framework):

| Scenario | Expected behaviour |
|---|---|
| Valid single-result city (e.g. "Tokyo") | Weather card shows immediately |
| Ambiguous city (e.g. "London") | Disambiguation list appears; picking one loads weather |
| Unknown city (e.g. "xyzzy") | "City not found" message |
| Network offline | "Something went wrong" message |
| Empty search submitted | No API call; input focused |
