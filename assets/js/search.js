// API Documentation Search Functionality

document.addEventListener('DOMContentLoaded', function () {
    initializeSearch();
});

function initializeSearch() {
    const searchInput = document.getElementById('search-input');
    const searchResults = document.getElementById('search-results');

    if (!searchInput || !searchResults) return;

    let searchIndex = [];

    // Build search index from all API docs
    buildSearchIndex();

    // Search functionality
    searchInput.addEventListener('input', function (e) {
        const query = e.target.value.toLowerCase().trim();

        if (query.length < 2) {
            searchResults.innerHTML = '';
            searchResults.style.display = 'none';
            return;
        }

        const results = performSearch(query);
        displaySearchResults(results, query);
    });

    // Hide results when clicking outside
    document.addEventListener('click', function (e) {
        if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
            searchResults.style.display = 'none';
        }
    });
}

function buildSearchIndex() {
    // This would typically load from a pre-built index
    // For now, we'll build it from the current page content
    const headings = document.querySelectorAll('.api-doc-article h1, .api-doc-article h2, .api-doc-article h3, .api-doc-article h4');
    const paragraphs = document.querySelectorAll('.api-doc-article p, .api-doc-article li');

    headings.forEach((heading, index) => {
        searchIndex.push({
            id: `heading-${index}`,
            text: heading.textContent,
            type: 'heading',
            level: parseInt(heading.tagName.charAt(1)),
            element: heading
        });
    });

    paragraphs.forEach((para, index) => {
        searchIndex.push({
            id: `para-${index}`,
            text: para.textContent,
            type: 'content',
            element: para
        });
    });
}

function performSearch(query) {
    const results = [];
    const queryWords = query.split(' ').filter(word => word.length > 0);

    searchIndex.forEach(item => {
        const text = item.text.toLowerCase();
        let score = 0;
        let matches = 0;

        queryWords.forEach(word => {
            if (text.includes(word)) {
                matches++;
                // Boost score for exact matches and heading matches
                if (item.type === 'heading') score += 10;
                if (text === word) score += 5;
                score += word.length;
            }
        });

        if (matches > 0) {
            results.push({
                ...item,
                score: score,
                matches: matches
            });
        }
    });

    // Sort by score (highest first)
    return results.sort((a, b) => b.score - a.score).slice(0, 10);
}

function displaySearchResults(results, query) {
    const searchResults = document.getElementById('search-results');

    if (results.length === 0) {
        searchResults.innerHTML = '<div class="search-no-results">No results found</div>';
        searchResults.style.display = 'block';
        return;
    }

    let html = '<div class="search-results-header">Search Results</div>';

    results.forEach(result => {
        const highlightedText = highlightSearchTerms(result.text, query);
        const icon = result.type === 'heading' ? '📄' : '📝';

        html += `
            <div class="search-result-item" data-target="${result.id}">
                <div class="search-result-icon">${icon}</div>
                <div class="search-result-content">
                    <div class="search-result-title">${highlightedText}</div>
                    <div class="search-result-type">${result.type === 'heading' ? `Heading ${result.level}` : 'Content'}</div>
                </div>
            </div>
        `;
    });

    searchResults.innerHTML = html;
    searchResults.style.display = 'block';

    // Add click handlers
    document.querySelectorAll('.search-result-item').forEach(item => {
        item.addEventListener('click', function () {
            const targetId = this.getAttribute('data-target');
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });

                // Highlight the target element briefly
                targetElement.style.backgroundColor = '#fff3cd';
                setTimeout(() => {
                    targetElement.style.backgroundColor = '';
                }, 2000);
            }

            searchResults.style.display = 'none';
        });
    });
}

function highlightSearchTerms(text, query) {
    const words = query.split(' ').filter(word => word.length > 0);
    let highlighted = text;

    words.forEach(word => {
        const regex = new RegExp(`(${word})`, 'gi');
        highlighted = highlighted.replace(regex, '<mark>$1</mark>');
    });

    return highlighted;
}