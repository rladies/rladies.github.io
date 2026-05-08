const GITHUB_ORG="rladies",GITHUB_API=`https://api.github.com/search/issues?q=org:${GITHUB_ORG}+label:"help+wanted"+state:open&sort=updated&per_page=100`;async function fetchHelpWantedIssues(){const t=document.getElementById("loading"),e=document.getElementById("error"),n=document.getElementById("issues-container"),s=document.getElementById("issues-list"),o=document.getElementById("issue-count");try{const i=await fetch(GITHUB_API);if(!i.ok)throw new Error(`GitHub API error: ${i.status}`);const r=await i.json(),a=r.items;if(t.classList.add("hidden"),a.length===0){e.textContent='No open "help wanted" issues found.',e.classList.remove("hidden"),e.classList.remove("bg-red-50","border-red-200","text-red-700"),e.classList.add("bg-blue-50","border-blue-200","text-blue-700");return}o.textContent=a.length,n.classList.remove("hidden"),s.innerHTML=a.map(e=>createIssueCard(e)).join("")}catch(n){t.classList.add("hidden"),e.textContent=`Failed to load issues: ${n.message}`,e.classList.remove("hidden")}}function createIssueCard(e){const n=e.repository_url.split("/").pop(),t=e.labels.filter(e=>e.name!=="help wanted").map(e=>`<span class="badge badge-primary text-white mr-1">${escapeHtml(e.name)}</span>`).join(""),s=new Date(e.updated_at).toLocaleDateString("en-US",{year:"numeric",month:"short",day:"numeric"});return`
    <div>
      <div class="card h-full">
        <div class="card-body">
          <h5 class="card-title">
            <a href="${e.html_url}" target="_blank" rel="noopener noreferrer">
              ${escapeHtml(e.title)}
            </a>
          </h5>
          <p class="text-muted text-sm mb-2">
            <strong>${escapeHtml(n)}</strong> • #${e.number}
          </p>
          ${t?`<div class="mb-2">${t}</div>`:""}
          <p class="card-text text-sm text-muted">
            Updated ${s}
          </p>
        </div>
      </div>
    </div>
  `}function escapeHtml(e){const t=document.createElement("div");return t.textContent=e,t.innerHTML}document.addEventListener("DOMContentLoaded",fetchHelpWantedIssues)