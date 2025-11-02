// API Documentation JavaScript

document.addEventListener('DOMContentLoaded', function () {
    generateTableOfContents();
    initializeSmoothScrolling();
    highlightActiveTOCItem();
});

function generateTableOfContents() {
    const tocList = document.getElementById('toc-list');
    if (!tocList) return;

    const headings = document.querySelectorAll('.api-doc-article h1, .api-doc-article h2, .api-doc-article h3, .api-doc-article h4');

    headings.forEach((heading, index) => {
        const level = parseInt(heading.tagName.charAt(1));
        const text = heading.textContent;
        const id = `heading-${index}`;

        // Add ID to heading for linking
        heading.id = id;

        // Create TOC item
        const li = document.createElement('li');
        li.style.paddingLeft = `${(level - 1) * 1}rem`;

        const a = document.createElement('a');
        a.href = `#${id}`;
        a.textContent = text;
        a.className = `toc-level-${level}`;

        li.appendChild(a);
        tocList.appendChild(li);
    });
}

function initializeSmoothScrolling() {
    const tocLinks = document.querySelectorAll('.toc a');

    tocLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

function highlightActiveTOCItem() {
    const tocLinks = document.querySelectorAll('.toc a');
    const headings = document.querySelectorAll('.api-doc-article h1, .api-doc-article h2, .api-doc-article h3, .api-doc-article h4');

    function updateActiveLink() {
        let currentHeading = null;

        // Find the heading currently in view
        for (let i = headings.length - 1; i >= 0; i--) {
            const heading = headings[i];
            const rect = heading.getBoundingClientRect();

            if (rect.top <= 100) { // 100px from top
                currentHeading = heading;
                break;
            }
        }

        // Update active link
        tocLinks.forEach(link => {
            link.classList.remove('active');
            if (currentHeading && link.getAttribute('href') === `#${currentHeading.id}`) {
                link.classList.add('active');
            }
        });
    }

    // Update on scroll
    window.addEventListener('scroll', updateActiveLink);
    updateActiveLink(); // Initial call
}

// Enhanced JSON syntax highlighting
function highlightJSON() {
    const jsonBlocks = document.querySelectorAll('.json-example');

    jsonBlocks.forEach(block => {
        let html = block.innerHTML;

        // Highlight keys
        html = html.replace(/"([^"]+)":/g, '<span class="json-key">"$1"</span>:');

        // Highlight strings
        html = html.replace(/: "([^"]+)"/g, ': <span class="json-string">"$1"</span>');

        // Highlight numbers
        html = html.replace(/: (\d+(?:\.\d+)?)/g, ': <span class="json-number">$1</span>');

        // Highlight booleans
        html = html.replace(/: (true|false)/g, ': <span class="json-boolean">$1</span>');

        block.innerHTML = html;
    });
}

// Initialize JSON highlighting
document.addEventListener('DOMContentLoaded', highlightJSON);