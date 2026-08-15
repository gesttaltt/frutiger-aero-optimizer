/**
 * Frutiger Aero Showcase Interactive Logic 🫧🐬✨
 */

document.addEventListener('DOMContentLoaded', () => {
    initBubbles();
    initMobileNav();
    initInstallTabs();
    initCopyButtons();
    initCompareSlider();
    initSoundBoard();
    initLightbox();
    initBackToTop();
});

/* 1. Floating Animated Bubbles Generator */
function initBubbles() {
    const container = document.getElementById('bubbleContainer');
    if (!container) return;

    const bubbleCount = 18;
    for (let i = 0; i < bubbleCount; i++) {
        createBubble(container);
    }
}

function createBubble(container) {
    const bubble = document.createElement('div');
    bubble.className = 'bubble';
    
    // Randomized organic properties
    const size = Math.floor(Math.random() * 65) + 20; // 20px - 85px
    const left = Math.floor(Math.random() * 100); // 0% - 100%
    const duration = Math.floor(Math.random() * 12) + 10; // 10s - 22s
    const delay = Math.floor(Math.random() * 14); // 0s - 14s

    bubble.style.width = `${size}px`;
    bubble.style.height = `${size}px`;
    bubble.style.left = `${left}%`;
    bubble.style.animationDuration = `${duration}s`;
    bubble.style.animationDelay = `${delay}s`;

    container.appendChild(bubble);
}

/* 2. Mobile Navigation Toggle */
function initMobileNav() {
    const btn = document.getElementById('mobileMenuBtn');
    const menu = document.getElementById('mobileNavMenu');

    if (!btn || !menu) return;

    btn.addEventListener('click', () => {
        menu.classList.toggle('open');
    });

    // Close when clicking any nav link
    menu.querySelectorAll('.mobile-nav-link').forEach((link) => {
        link.addEventListener('click', () => {
            menu.classList.remove('open');
        });
    });
}

/* 3. Platform Tab Switcher */
const INSTALL_COMMANDS = {
    linux: 'curl -fsSL https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/install.sh | bash',
    windows: 'irm https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/windows/install.ps1 | iex'
};

function initInstallTabs() {
    const tabLinux = document.getElementById('tabLinux');
    const tabWindows = document.getElementById('tabWindows');
    const installCmdText = document.getElementById('installCmdText');

    if (!tabLinux || !tabWindows || !installCmdText) return;

    tabLinux.addEventListener('click', () => {
        tabLinux.classList.add('active');
        tabLinux.setAttribute('aria-selected', 'true');
        tabWindows.classList.remove('active');
        tabWindows.setAttribute('aria-selected', 'false');
        installCmdText.textContent = INSTALL_COMMANDS.linux;
    });

    tabWindows.addEventListener('click', () => {
        tabWindows.classList.add('active');
        tabWindows.setAttribute('aria-selected', 'true');
        tabLinux.classList.remove('active');
        tabLinux.setAttribute('aria-selected', 'false');
        installCmdText.textContent = INSTALL_COMMANDS.windows;
    });
}

/* 4. One-Click Copy to Clipboard */
function initCopyButtons() {
    const btnCopy = document.getElementById('btnCopyCode');
    const installCmdText = document.getElementById('installCmdText');
    const label = document.getElementById('copyBtnLabel');

    if (!btnCopy || !installCmdText) return;

    btnCopy.addEventListener('click', async () => {
        const textToCopy = installCmdText.textContent.trim();
        try {
            await navigator.clipboard.writeText(textToCopy);
            if (label) label.textContent = 'Copied! 🫧';
            btnCopy.style.borderColor = '#38ef7d';
            btnCopy.style.boxShadow = '0 0 14px rgba(56, 239, 125, 0.6)';

            setTimeout(() => {
                if (label) label.textContent = 'Copy';
                btnCopy.style.borderColor = '';
                btnCopy.style.boxShadow = '';
            }, 2400);
        } catch (err) {
            // Fallback for older environments
            const textArea = document.createElement('textarea');
            textArea.value = textToCopy;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            if (label) label.textContent = 'Copied! 🫧';
            setTimeout(() => {
                if (label) label.textContent = 'Copy';
            }, 2400);
        }
    });
}

/* 5. Before & After Comparison Slider */
function initCompareSlider() {
    const slider = document.getElementById('compareSlider');
    const beforeLayer = document.getElementById('beforeLayer');
    const divider = document.getElementById('sliderDivider');

    if (!slider || !beforeLayer || !divider) return;

    const updateSliderPosition = (val) => {
        beforeLayer.style.width = `${val}%`;
        divider.style.left = `${val}%`;
    };

    slider.addEventListener('input', (e) => {
        updateSliderPosition(e.target.value);
    });

    // Initial setup at 50%
    updateSliderPosition(50);
}

/* 6. Audio Preview Sound Board with Multi-Format Fallback */
function initSoundBoard() {
    const soundCards = document.querySelectorAll('.sound-card');
    const audioPlayer = document.getElementById('audioPlayer');

    if (!soundCards.length || !audioPlayer) return;

    let currentPlayingBtn = null;

    soundCards.forEach((card) => {
        card.addEventListener('click', () => {
            const oggSrc = card.getAttribute('data-ogg');
            const wavSrc = card.getAttribute('data-wav');

            // If clicking currently playing sound, stop it
            if (currentPlayingBtn === card && !audioPlayer.paused) {
                audioPlayer.pause();
                card.classList.remove('playing');
                currentPlayingBtn = null;
                return;
            }

            if (currentPlayingBtn) {
                currentPlayingBtn.classList.remove('playing');
            }

            // Determine best audio format support
            const canPlayOgg = audioPlayer.canPlayType('audio/ogg; codecs="vorbis"');
            const targetSrc = (canPlayOgg && oggSrc) ? oggSrc : (wavSrc || oggSrc);

            audioPlayer.src = targetSrc;
            audioPlayer.play().then(() => {
                card.classList.add('playing');
                currentPlayingBtn = card;
            }).catch((err) => {
                // If OGG fails, try WAV fallback
                if (wavSrc && targetSrc !== wavSrc) {
                    audioPlayer.src = wavSrc;
                    audioPlayer.play().then(() => {
                        card.classList.add('playing');
                        currentPlayingBtn = card;
                    }).catch((e) => console.warn('Audio playback error:', e));
                }
            });
        });
    });

    audioPlayer.addEventListener('ended', () => {
        if (currentPlayingBtn) {
            currentPlayingBtn.classList.remove('playing');
            currentPlayingBtn = null;
        }
    });
}

/* 7. Wallpaper Lightbox Modal */
function initLightbox() {
    const modal = document.getElementById('lightboxModal');
    const lightboxImg = document.getElementById('lightboxImg');
    const closeBtn = document.getElementById('lightboxCloseBtn');
    const backdrop = document.getElementById('lightboxBackdrop');
    const cards = document.querySelectorAll('.wallpaper-card');

    if (!modal || !lightboxImg) return;

    const openModal = (src) => {
        lightboxImg.src = src;
        modal.classList.add('active');
        modal.setAttribute('aria-hidden', 'false');
    };

    const closeModal = () => {
        modal.classList.remove('active');
        modal.setAttribute('aria-hidden', 'true');
        lightboxImg.src = '';
    };

    cards.forEach((card) => {
        const thumbWrapper = card.querySelector('.wallpaper-thumb-wrapper');
        const fullSrc = card.getAttribute('data-full');
        if (thumbWrapper && fullSrc) {
            thumbWrapper.addEventListener('click', () => openModal(fullSrc));
        }
    });

    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    if (backdrop) backdrop.addEventListener('click', closeModal);

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && modal.classList.contains('active')) {
            closeModal();
        }
    });
}

/* 8. Floating Back to Top Button */
function initBackToTop() {
    const btn = document.getElementById('backToTopBtn');
    if (!btn) return;

    window.addEventListener('scroll', () => {
        if (window.scrollY > 400) {
            btn.classList.add('visible');
        } else {
            btn.classList.remove('visible');
        }
    });

    btn.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
}
