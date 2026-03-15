document.addEventListener('DOMContentLoaded', function() {
  const filterEl = document.getElementById('country-filter');
  if (!filterEl) return;

  const countryFilter = new Choices('#country-filter', {
    removeItemButton: true,
    searchEnabled: true,
    placeholder: true,
    placeholderValue: filterEl.dataset.placeholder || 'Select countries...'
  });

  const searchInput = document.getElementById('search-filter');
  const rows = document.querySelectorAll('.chapter-row');

  function filterTable() {
    const selectedCountries = countryFilter.getValue(true);
    const searchTerm = searchInput.value.toLowerCase();

    rows.forEach(row => {
      const country = row.dataset.country;
      const city = row.dataset.city;

      const countryMatch = selectedCountries.length === 0 || selectedCountries.includes(country);
      const searchMatch = searchTerm === '' || city.includes(searchTerm);

      row.style.display = (countryMatch && searchMatch) ? '' : 'none';
    });

    updateRowspans();
  }

  function updateRowspans() {
    const countries = {};
    const visibleContinents = new Set();
    rows.forEach(row => {
      if (row.style.display !== 'none') {
        const country = row.dataset.country;
        const continent = row.dataset.continent;
        if (!countries[country]) {
          countries[country] = [];
        }
        countries[country].push(row);
        visibleContinents.add(continent);
      }
    });

    document.querySelectorAll('.country-cell').forEach(cell => {
      cell.style.display = 'none';
    });

    Object.values(countries).forEach(countryRows => {
      const firstRow = countryRows[0];
      const cell = firstRow.querySelector('.country-cell');
      if (cell) {
        cell.style.display = '';
        cell.setAttribute('rowspan', countryRows.length);
      }
    });

    document.querySelectorAll('.continent-header').forEach(header => {
      header.style.display = visibleContinents.has(header.dataset.continent) ? '' : 'none';
    });
  }

  countryFilter.passedElement.element.addEventListener('change', filterTable);
  searchInput.addEventListener('input', filterTable);
});
