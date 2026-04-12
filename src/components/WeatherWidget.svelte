<script>
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
    // forecast will be added in Task 5
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
