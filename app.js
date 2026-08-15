/**
 * Frutiger Aero Showcase Interactive Logic 🫧🐬✨
 */

document.addEventListener('DOMContentLoaded', () => {
    initBubbles();
    initInstallTabs();
    initCopyButtons();
    initCompareSlider();
    initSoundBoard();
});

/* 1. Floating Animated Bubbles Generator */
function initBubbles() {
    const container = document.getElementById('bubbleContainer');
    if (!container) return;

    const bubbleCount = 18;
    for (let i = 0; i < bubbleCount; i++) {
        createBubble(container, i);
    }
}

function createBubble(container, index) {
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

/* 2. Platform Tab Switcher */
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

/* 3. One-Click Copy to Clipboard */
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
            // Fallback for older browsers
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

/* 4. Before & After Comparison Slider */
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

/* 5. Audio Preview Sound Board */
function initSoundBoard() {
    const soundCards = document.querySelectorAll('.sound-card');
    const audioPlayer = document.getElementById('audioPlayer');

    if (!soundCards.length || !audioPlayer) return;

    let currentPlayingBtn = null;

    soundCards.forEach((card) => {
        card.addEventListener('click', () => {
            const soundSrc = card.getAttribute('data-src');
            if (!soundSrc) return;

            // If clicking currently playing sound, stop it
            if (currentPlayingBtn === card && !audioPlayer.paused) {
                audioPlayer.pause();
                card.classList.remove('playing');
                currentPlayingBtn = null;
                return;
            }

            // Remove playing state from previous
            if (currentPlayingBtn) {
                currentPlayingBtn.classList.remove('playing');
            }

            audioPlayer.src = soundSrc;
            audioPlayer.play().then(() => {
                card.classList.add('playing');
                currentPlayingBtn = card;
            }).catch((err) => {
                console.warn('Audio autoplay prevented or file unavailable:', err);
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
