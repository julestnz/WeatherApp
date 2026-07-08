# WeatherApp

A small weather lookup app, built as a pairing/teaching exercise: search a
city, disambiguate if there are multiple matches, and see current conditions
plus today's high/low.

Built with **Astro** + a **Svelte** island for the interactive widget, styled
with **Pico CSS**, and backed by the free [Open-Meteo](https://open-meteo.com/)
geocoding + forecast APIs — no API key required.

## Why it exists

This was a live Claude Code pairing session: one person driving, one person
new to Claude Code following along and learning the workflow. The goal was a
small, real feature (not a toy) built incrementally, with each step explained
along the way rather than generated in one big jump.

## Stack

- [Astro](https://astro.build/) — static-first site framework, page shell
- [Svelte 5](https://svelte.dev/) — the interactive `WeatherWidget` component
  (`src/components/WeatherWidget.svelte`), using Svelte 5 runes (`$state`)
- [Pico CSS](https://picocss.com/) — classless/minimal styling
- [Open-Meteo](https://open-meteo.com/) geocoding + forecast APIs

## Running it

```sh
npm install
npm run dev
```

## How it works

1. Type a city name and submit.
2. If the geocoding API returns multiple matches (e.g. more than one
   "Springfield"), the widget shows a disambiguation list instead of
   guessing.
3. Once a single location is resolved, it fetches current temperature,
   condition (mapped from Open-Meteo's WMO weather codes), and today's
   high/low.
