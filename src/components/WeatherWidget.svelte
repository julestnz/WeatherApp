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
    // geocoding will be added in Task 4
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
  <button type="submit" disabled={loading}>Search</button>
</form>
