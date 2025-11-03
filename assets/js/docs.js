// ========================================
// Quub Exchange Documentation - JavaScript
// ========================================

(function () {
    'use strict';

    // ========================================
    // Theme Toggle
    // ========================================

    function initTheme() {
        const themeToggle = document.getElementById('themeToggle');
        const html = document.documentElement;

        // Check for saved theme preference or default to light mode
        const currentTheme = localStorage.getItem('theme') || 'light';
        html.setAttribute('data-theme', currentTheme);
        updateThemeIcon(currentTheme);

        if (themeToggle) {
            themeToggle.addEventListener('click', () => {
                const newTheme = html.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
                html.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);
                updateThemeIcon(newTheme);
            });
        }
    }

    function updateThemeIcon(theme) {
        const themeToggle = document.getElementById('themeToggle');
        if (themeToggle) {
            const icon = themeToggle.querySelector('i');
            icon.className = theme === 'light' ? 'fas fa-moon' : 'fas fa-sun';
        }
    }

    // ========================================
    // Table of Contents Generation
    // ========================================

    function generateTableOfContents() {
        const content = document.querySelector('.doc-content');
        const tocNav = document.getElementById('tableOfContents');

        if (!content || !tocNav) return;

        const headings = content.querySelectorAll('h2, h3');

        if (headings.length === 0) {
            tocNav.innerHTML = '<p style="color: var(--text-tertiary); font-size: 0.813rem;">No headings found</p>';
            return;
        }

        const tocHTML = Array.from(headings).map(heading => {
            const id = heading.id || createSlug(heading.textContent);
            heading.id = id;

            const level = heading.tagName.toLowerCase();

            return `<a href="#${id}" class="toc-link" data-level="${level}">${heading.textContent}</a>`;
        }).join('');

        tocNav.innerHTML = tocHTML;

        // Highlight active section on scroll
        initTOCScroll();
    }

    function createSlug(text) {
        return text
            .toLowerCase()
            .replace(/[^\w\s-]/g, '')
            .replace(/\s+/g, '-')
            .replace(/-+/g, '-')
            .trim();
    }

    function initTOCScroll() {
        const tocLinks = document.querySelectorAll('.toc-link');
        const headings = document.querySelectorAll('.doc-content h2, .doc-content h3');

        if (tocLinks.length === 0 || headings.length === 0) return;

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const id = entry.target.id;
                    tocLinks.forEach(link => {
                        link.classList.remove('active');
                        if (link.getAttribute('href') === `#${id}`) {
                            link.classList.add('active');
                        }
                    });
                }
            });
        }, {
            rootMargin: '-80px 0px -80% 0px'
        });

        headings.forEach(heading => observer.observe(heading));
    }

    // ========================================
    // Sidebar Active State
    // ========================================

    function initSidebarActiveState() {
        const currentPath = window.location.pathname;
        const navItems = document.querySelectorAll('.nav-item');

        navItems.forEach(item => {
            const href = item.getAttribute('href');
            if (href && currentPath.includes(href)) {
                item.classList.add('active');
            }
        });
    }

    // ========================================
    // Search Functionality
    // ========================================

    function initSearch() {
        const searchInput = document.getElementById('docSearch');

        if (!searchInput) return;

        // Keyboard shortcut: Ctrl/Cmd + K
        document.addEventListener('keydown', (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                searchInput.focus();
            }
        });

        // Real-time search filtering
        searchInput.addEventListener('input', debounce(function (e) {
            const query = e.target.value.toLowerCase();
            filterSidebarItems(query);
        }, 300));
    }

    function filterSidebarItems(query) {
        const navItems = document.querySelectorAll('.nav-item');
        const navSections = document.querySelectorAll('.nav-section');

        if (!query) {
            // Show all items
            navItems.forEach(item => item.style.display = 'flex');
            navSections.forEach(section => section.style.display = 'block');
            return;
        }

        navSections.forEach(section => {
            const items = section.querySelectorAll('.nav-item');
            let hasVisibleItems = false;

            items.forEach(item => {
                const text = item.textContent.toLowerCase();
                if (text.includes(query)) {
                    item.style.display = 'flex';
                    hasVisibleItems = true;
                } else {
                    item.style.display = 'none';
                }
            });

            section.style.display = hasVisibleItems ? 'block' : 'none';
        });
    }

    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // ========================================
    // Smooth Scroll for Anchor Links
    // ========================================

    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const href = this.getAttribute('href');
                if (href === '#') return;

                e.preventDefault();
                const target = document.querySelector(href);

                if (target) {
                    const offsetTop = target.offsetTop - 80;
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });

                    // Update URL without jumping
                    history.pushState(null, null, href);
                }
            });
        });
    }

    // ========================================
    // Code Block Copy Button
    // ========================================

    function initCodeCopyButtons() {
        const codeBlocks = document.querySelectorAll('pre code');

        codeBlocks.forEach((codeBlock) => {
            const pre = codeBlock.parentElement;
            const button = document.createElement('button');
            button.className = 'copy-code-button';
            button.innerHTML = '<i class="fas fa-copy"></i>';
            button.setAttribute('aria-label', 'Copy code');

            button.addEventListener('click', () => {
                const code = codeBlock.textContent;
                navigator.clipboard.writeText(code).then(() => {
                    button.innerHTML = '<i class="fas fa-check"></i>';
                    button.style.color = 'var(--success)';

                    setTimeout(() => {
                        button.innerHTML = '<i class="fas fa-copy"></i>';
                        button.style.color = '';
                    }, 2000);
                });
            });

            pre.style.position = 'relative';
            pre.appendChild(button);
        });
    }

    // Add CSS for copy button
    const copyButtonStyle = document.createElement('style');
    copyButtonStyle.textContent = `
        .copy-code-button {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
            padding: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            color: #e2e8f0;
            cursor: pointer;
            font-size: 0.875rem;
            transition: all 150ms;
        }

        .copy-code-button:hover {
            background: rgba(255, 255, 255, 0.2);
        }
    `;
    document.head.appendChild(copyButtonStyle);

    // ========================================
    // Feedback Buttons
    // ========================================

    function initFeedback() {
        const feedbackButtons = document.querySelectorAll('.feedback-btn');

        feedbackButtons.forEach(button => {
            button.addEventListener('click', function () {
                const helpful = this.getAttribute('data-helpful');

                // Send feedback (you can implement your own tracking here)
                console.log('Feedback:', helpful, 'for page:', window.location.pathname);

                // Visual feedback
                const container = this.closest('.doc-feedback');
                container.innerHTML = `
                    <div style="color: var(--success);">
                        <i class="fas fa-check-circle" style="font-size: 2rem; margin-bottom: 0.5rem;"></i>
                        <p style="font-weight: 600;">Thank you for your feedback!</p>
                    </div>
                `;
            });
        });
    }

    // ========================================
    // External Links
    // ========================================

    function initExternalLinks() {
        const links = document.querySelectorAll('.doc-content a[href^="http"]');

        links.forEach(link => {
            if (!link.hostname.includes(window.location.hostname)) {
                link.setAttribute('target', '_blank');
                link.setAttribute('rel', 'noopener noreferrer');

                // Add external link icon
                if (!link.querySelector('.external-icon')) {
                    const icon = document.createElement('i');
                    icon.className = 'fas fa-external-link-alt external-icon';
                    icon.style.fontSize = '0.75em';
                    icon.style.marginLeft = '0.25rem';
                    link.appendChild(icon);
                }
            }
        });
    }

    // ========================================
    // Lazy Loading Images
    // ========================================

    function initLazyLoading() {
        const images = document.querySelectorAll('img[data-src]');

        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    imageObserver.unobserve(img);
                }
            });
        });

        images.forEach(img => imageObserver.observe(img));
    }

    // ========================================
    // Initialize All Features
    // ========================================

    function init() {
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initAll);
        } else {
            initAll();
        }
    }

    function initAll() {
        initTheme();
        generateTableOfContents();
        initSidebarActiveState();
        initSearch();
        initSmoothScroll();
        initCodeCopyButtons();
        initFeedback();
        initExternalLinks();
        initLazyLoading();
    }

    // Start initialization
    init();

})();
