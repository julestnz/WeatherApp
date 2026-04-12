<script>
  const WMO_CODES = {
    0: 'Clear sky', 1: 'Mainly clear', 2: 'Partly cloudy', 3: 'Overcast',
    45: 'Fog', 48: 'Icy fog',
    51: 'Light drizzle', 53: 'Drizzle', 55: 'Heavy drizzle',
    61: 'Light rain', 63: 'Rain', 65: 'Heavy rain',
    71: 'Light snow', 73: 'Snow', 75: 'Heavy snow', 77: 'Snow grains',
    80: 'Light showers', 81: 'Showers', 82: 'Heavy showers',
    85: 'Snow showers', 86: 'Heavy snow showers',
    95: 'Thunderstorm', 96: 'Thunderstorm with hail', 99: 'Thunderstorm with heavy hail',
  };

  let city = $state('');
  let loading = $state(false);
  let candidates = $state(null);
  let weather = $state(null);
  let error = $state(null);

  function handleInput() {
    error = null;
  }

  async function handleSubmit() {
    if (!city.trim()) return;

    loading = true;
    candidates = null;
    weather = null;
    error = null;

    try {
      const res = await fetch(
        `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(city.trim())}&count=5`
      );
      const data = await res.json();
      const results = data.results ?? [];

      if (results.length === 0) {
        error = 'City not found. Please try another name.';
      } else if (results.length === 1) {
        await fetchWeather(results[0]);
      } else {
        candidates = results;
      }
    } catch {
      error = 'Something went wrong. Please try again.';
    } finally {
      loading = false;
    }
  }

  async function fetchWeather(location) {
    loading = true;
    candidates = null;

    try {
      const url = new URL('https://api.open-meteo.com/v1/forecast');
      url.searchParams.set('latitude', location.latitude);
      url.searchParams.set('longitude', location.longitude);
      url.searchParams.set('current', 'temperature_2m,weathercode');
      url.searchParams.set('daily', 'temperature_2m_max,temperature_2m_min');
      url.searchParams.set('timezone', 'auto');
      url.searchParams.set('temperature_unit', 'celsius');

      const res = await fetch(url);
      const data = await res.json();

      weather = {
        name: location.name,
        region: location.admin1 ?? null,
        country: location.country_code,
        temp: Math.round(data.current.temperature_2m),
        condition: WMO_CODES[data.current.weathercode] ?? 'Unknown',
        high: Math.round(data.daily.temperature_2m_max[0]),
        low: Math.round(data.daily.temperature_2m_min[0]),
      };
    } catch {
      error = 'Something went wrong. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
  <input
    type="text"
    placeholder="Enter city name"
    bind:value={city}
    oninput={handleInput}
    aria-label="City name"
  />
  <button type="submit" disabled={loading}>
    {loading ? 'Loading…' : 'Search'}
  </button>
</form>

{#if error}
  <p style="color: var(--pico-color-red-500, #c0392b);">{error}</p>
{/if}

{#if candidates}
  <p><strong>Multiple cities found — which one did you mean?</strong></p>
  <ul>
    {#each candidates as candidate}
      <li>
        <button type="button" onclick={() => fetchWeather(candidate)}>
          {candidate.name}{candidate.admin1 ? `, ${candidate.admin1}` : ''}, {candidate.country_code}
        </button>
      </li>
    {/each}
  </ul>
{/if}

{#if weather}
  <article>
    <h2>{weather.name}{weather.region ? `, ${weather.region}` : ''}, {weather.country}</h2>
    <p style="font-size: 2.5rem; margin: 0.25rem 0;">{weather.temp}°C</p>
    <p>{weather.condition}</p>
    <p>High: {weather.high}°C &nbsp;/&nbsp; Low: {weather.low}°C</p>
  </article>
{/if}
