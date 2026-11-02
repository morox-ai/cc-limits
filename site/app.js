(() => {
  const MINUTE = 60 * 1000;
  const HOUR = 60 * MINUTE;
  const DAY = 24 * HOUR;
  const start = Date.now();

  const providers = {
    claude: {
      name: 'Claude Code',
      five: 61,
      week: 34,
      fiveResets: start + 2 * HOUR + 38 * MINUTE,
      weekResets: start + 3 * DAY + 4 * HOUR + 30 * MINUTE,
    },
    codex: {
      name: 'Codex',
      five: 24,
      week: 12,
      fiveResets: start + 4 * HOUR + 11 * MINUTE,
      weekResets: start + 5 * DAY + 19 * HOUR + 30 * MINUTE,
    },
  };

  let cancelIntro = () => {};

  const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const clockTime = (date) => {
    const hours = date.getHours() % 12 || 12;
    return `${hours}:${String(date.getMinutes()).padStart(2, '0')}`;
  };
  const clockTimeWithPeriod = (date) => `${clockTime(date)} ${date.getHours() < 12 ? 'AM' : 'PM'}`;

  const formatFiveHour = (remaining) => {
    const totalMinutes = Math.floor(Math.max(0, remaining) / MINUTE);
    return `${Math.floor(totalMinutes / 60)}:${String(totalMinutes % 60).padStart(2, '0')}`;
  };

  const formatSevenDay = (remaining) => {
    const totalMinutes = Math.floor(Math.max(0, remaining) / MINUTE);
    const days = Math.floor(totalMinutes / 1440);
    const hours = Math.floor((totalMinutes % 1440) / 60);
    const minutes = totalMinutes % 60;
    if (days >= 1) return `${days}d ${hours}h`;
    if (hours >= 1) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  const tint = (usage) => {
    if (usage > 80) return 'red';
    if (usage > 60) return 'amber';
    return '';
  };

  const el = (tag, className, text) => {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  };

  const buildGroup = () => {
    const group = el('span', 's-group');
    const bar = el('span', 's-bar');
    const fill = el('i');
    const pct = el('span', 's-pct');
    const time = el('span', 's-time');
    bar.append(fill);
    group.append(bar, pct, time);
    return { group, fill, pct, time };
  };

  const statusViews = [...document.querySelectorAll('[data-status]')].map((node) => {
    const claude = buildGroup();
    const codex = buildGroup();
    node.replaceChildren(claude.group, el('span', 's-sep', '│'), codex.group);
    return { node, claude, codex };
  });

  const fillWidth = (usage) => (usage > 0 ? Math.min(22, Math.max(5, (22 * usage) / 100)) : 0);

  const renderStatus = () => {
    const label = Object.values(providers)
      .map((provider) => `${provider.name} ${provider.five} percent used, resets at ${clockTime(new Date(provider.fiveResets))}`)
      .join(', ');
    statusViews.forEach((view) => {
      ['claude', 'codex'].forEach((key) => {
        const provider = providers[key];
        const parts = view[key];
        parts.group.className = `s-group ${tint(provider.five)}`.trim();
        parts.fill.style.setProperty('--w', fillWidth(provider.five));
        parts.pct.textContent = `${provider.five}%`;
        parts.time.textContent = clockTime(new Date(provider.fiveResets));
      });
      view.node.setAttribute('aria-label', label);
    });
  };

  const renderMenu = () => {
    const now = Date.now();
    Object.entries(providers).forEach(([key, provider]) => {
      const fiveAt = new Date(provider.fiveResets);
      const weekAt = new Date(provider.weekResets);
      const fiveRow = document.querySelector(`[data-row="${key}-five"]`);
      const weekRow = document.querySelector(`[data-row="${key}-week"]`);
      fiveRow.textContent = `5h limit: ${provider.five}% used • resets in ${formatFiveHour(provider.fiveResets - now)} • at ${clockTimeWithPeriod(fiveAt)}`;
      weekRow.textContent = `Weekly limit: ${provider.week}% used • resets in ${formatSevenDay(provider.weekResets - now)} • at ${WEEKDAYS[weekAt.getDay()]} ${clockTimeWithPeriod(weekAt)}`;
    });
  };

  const renderClock = () => {
    const now = new Date();
    const clock = document.querySelector('[data-clock]');
    clock.textContent = window.matchMedia('(max-width: 680px)').matches
      ? clockTimeWithPeriod(now)
      : `${WEEKDAYS[now.getDay()]} ${clockTimeWithPeriod(now)}`;
  };

  const render = () => {
    renderStatus();
    renderMenu();
    renderClock();
  };

  const setupSliders = (onInput) => {
    document.querySelectorAll('[data-usage]').forEach((input) => {
      const key = input.dataset.usage;
      const output = document.querySelector(`[data-usage-value="${key}"]`);
      input.setAttribute('aria-valuetext', `${input.value} percent`);
      input.addEventListener('input', () => {
        onInput();
        const usage = Number(input.value);
        providers[key].five = usage;
        output.textContent = `${usage}%`;
        input.setAttribute('aria-valuetext', `${usage} percent`);
        renderStatus();
        renderMenu();
      });
    });
  };

  const setupAppearance = () => {
    const stage = document.querySelector('[data-stage]');
    const buttons = document.querySelectorAll('[data-appearance]');
    buttons.forEach((button) => {
      button.addEventListener('click', () => {
        stage.dataset.stage = button.dataset.appearance;
        buttons.forEach((other) => other.setAttribute('aria-pressed', String(other === button)));
      });
    });
  };

  const setupMenu = () => {
    const desktop = document.querySelector('[data-desktop]');
    const trigger = document.querySelector('[data-status-btn]');
    const menu = document.querySelector('[data-menu]');
    const setOpen = (open) => {
      menu.classList.toggle('closed', !open);
      trigger.setAttribute('aria-expanded', String(open));
    };
    trigger.addEventListener('click', () => {
      cancelIntro();
      setOpen(menu.classList.contains('closed'));
    });
    menu.querySelectorAll('[data-menu-close]').forEach((button) => {
      button.addEventListener('click', () => {
        setOpen(false);
        trigger.focus();
      });
    });
    desktop.addEventListener('click', (event) => {
      if (!menu.contains(event.target) && !trigger.contains(event.target)) {
        cancelIntro();
        setOpen(false);
      }
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && !menu.classList.contains('closed')) setOpen(false);
    });
    return setOpen;
  };

  const playIntro = (setOpen) => {
    const target = providers.claude.five;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      setOpen(true);
      return;
    }
    const from = 48;
    const duration = 1300;
    const began = performance.now();
    let frame;
    let timer;
    let active = true;
    cancelIntro = () => {
      if (!active) return;
      active = false;
      cancelAnimationFrame(frame);
      clearTimeout(timer);
      providers.claude.five = Number(document.querySelector('[data-usage="claude"]').value);
      renderStatus();
      renderMenu();
    };
    const step = (time) => {
      const progress = Math.min(1, (time - began) / duration);
      const eased = 1 - (1 - progress) ** 3;
      providers.claude.five = Math.round(from + (target - from) * eased);
      renderStatus();
      renderMenu();
      if (progress < 1) {
        frame = requestAnimationFrame(step);
      } else {
        active = false;
        timer = setTimeout(() => setOpen(true), 180);
      }
    };
    providers.claude.five = from;
    renderStatus();
    renderMenu();
    frame = requestAnimationFrame(step);
  };

  const setupCopy = () => {
    const announce = document.querySelector('[data-announce]');
    const fallbackSelect = (button) => {
      const code = button.parentElement.querySelector('code');
      const range = document.createRange();
      range.selectNodeContents(code);
      const selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(range);
      announce.textContent = 'Could not copy automatically. The command is selected: press Command C.';
    };
    document.querySelectorAll('[data-copy]').forEach((button) => {
      let timer;
      button.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(button.dataset.copy);
          button.classList.add('done');
          announce.textContent = 'Copied to clipboard.';
          clearTimeout(timer);
          timer = setTimeout(() => button.classList.remove('done'), 1600);
        } catch {
          fallbackSelect(button);
        }
      });
    });
  };

  const setupNav = () => {
    const nav = document.querySelector('[data-nav]');
    const update = () => nav.classList.toggle('scrolled', window.scrollY > 8);
    window.addEventListener('scroll', update, { passive: true });
    update();
  };

  document.querySelectorAll('[data-usage]').forEach((input) => {
    providers[input.dataset.usage].five = Number(input.value);
    document.querySelector(`[data-usage-value="${input.dataset.usage}"]`).textContent = `${input.value}%`;
  });

  render();
  setupSliders(() => cancelIntro());
  setupAppearance();
  const setMenuOpen = setupMenu();
  setupCopy();
  setupNav();
  playIntro(setMenuOpen);
  setInterval(() => {
    renderMenu();
    renderClock();
  }, 30 * 1000);
  window.addEventListener('resize', renderClock, { passive: true });
})();
