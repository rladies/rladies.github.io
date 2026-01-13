const GITHUB_ORG = 'rladies';
const GITHUB_API = `https://api.github.com/search/issues?q=org:${GITHUB_ORG}+label:"help+wanted"+state:open&sort=updated&per_page=100`;

async function fetchHelpWantedIssues() {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    const container = document.getElementById('issues-container');
    const issuesList = document.getElementById('issues-list');
    const issueCount = document.getElementById('issue-count');

    try {
        const response = await fetch(GITHUB_API);

        if (!response.ok) {
            throw new Error(`GitHub API error: ${response.status}`);
        }

        const data = await response.json();
        const issues = data.items;

        loading.classList.add('d-none');

        if (issues.length === 0) {
            error.textContent = 'No open "help wanted" issues found.';
            error.classList.remove('d-none', 'alert-danger');
            error.classList.add('alert-info');
            return;
        }

        issueCount.textContent = issues.length;
        container.classList.remove('d-none');

        issuesList.innerHTML = issues.map(issue => createIssueCard(issue)).join('');

    } catch (err) {
        loading.classList.add('d-none');
        error.textContent = `Failed to load issues: ${err.message}`;
        error.classList.remove('d-none');
    }
}

function createIssueCard(issue) {
    const repoName = issue.repository_url.split('/').pop();
    const labels = issue.labels
        .filter(label => label.name !== 'help wanted')
        .map(label => `<span class="badge bg-primary text-white me-1">${escapeHtml(label.name)}</span>`)
        .join('');

    const updatedDate = new Date(issue.updated_at).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });

    return `
    <div class="col-md-6 col-lg-4">
      <div class="card h-100">
        <div class="card-body">
          <h5 class="card-title">
            <a href="${issue.html_url}" target="_blank" rel="noopener noreferrer">
              ${escapeHtml(issue.title)}
            </a>
          </h5>
          <p class="text-muted small mb-2">
            <strong>${escapeHtml(repoName)}</strong> • #${issue.number}
          </p>
          ${labels ? `<div class="mb-2">${labels}</div>` : ''}
          <p class="card-text small text-muted">
            Updated ${updatedDate}
          </p>
        </div>
      </div>
    </div>
  `;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener('DOMContentLoaded', fetchHelpWantedIssues);