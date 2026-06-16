/* Eagle Scapes — Interactions & Animations */

document.addEventListener('DOMContentLoaded', () => {
  /* === Header scroll effect === */
  const header = document.querySelector('.header');
  if (header) {
    const onScroll = () => {
      if (window.scrollY > 30) header.classList.add('scrolled');
      else header.classList.remove('scrolled');
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* === Mobile menu toggle === */
  const toggle = document.querySelector('.menu-toggle');
  const navLinks = document.querySelector('.nav-links');
  if (toggle && navLinks) {
    toggle.addEventListener('click', () => {
      toggle.classList.toggle('open');
      navLinks.classList.toggle('open');
      document.body.style.overflow = navLinks.classList.contains('open') ? 'hidden' : '';
    });
    // Close menu when any non-submenu link is clicked
    navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', (e) => {
      // If this is the parent "Services" link inside a has-submenu on mobile, toggle the submenu instead
      const parentLi = a.closest('.has-submenu');
      if (parentLi && window.innerWidth <= 768 && a.parentElement === parentLi) {
        e.preventDefault();
        parentLi.classList.toggle('open');
        return;
      }
      toggle.classList.remove('open');
      navLinks.classList.remove('open');
      document.body.style.overflow = '';
    }));
  }

  /* === Scroll-reveal animations (Intersection Observer) === */
  if ('IntersectionObserver' in window) {
    const reveals = document.querySelectorAll('.reveal');
    const io = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -50px 0px' });
    reveals.forEach(el => io.observe(el));
  } else {
    document.querySelectorAll('.reveal').forEach(el => el.classList.add('visible'));
  }

  /* === Animated counters for stats === */
  const counters = document.querySelectorAll('[data-count]');
  if (counters.length && 'IntersectionObserver' in window) {
    const counterIO = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const el = entry.target;
          const target = parseFloat(el.dataset.count);
          const suffix = el.dataset.suffix || '';
          const duration = 1800;
          const start = performance.now();
          const tick = (now) => {
            const t = Math.min((now - start) / duration, 1);
            const eased = 1 - Math.pow(1 - t, 3);
            const val = target * eased;
            el.textContent = (target % 1 === 0 ? Math.floor(val) : val.toFixed(1)) + suffix;
            if (t < 1) requestAnimationFrame(tick);
          };
          requestAnimationFrame(tick);
          counterIO.unobserve(el);
        }
      });
    }, { threshold: 0.5 });
    counters.forEach(c => counterIO.observe(c));
  }

  /* === Smooth-scroll for # links === */
  document.querySelectorAll('a[href^="#"]').forEach(link => {
    link.addEventListener('click', (e) => {
      const target = document.querySelector(link.getAttribute('href'));
      if (target) {
        e.preventDefault();
        const headerHeight = header ? header.offsetHeight : 0;
        const top = target.getBoundingClientRect().top + window.scrollY - headerHeight - 20;
        window.scrollTo({ top, behavior: 'smooth' });
      }
    });
  });

  /* === Contact form: real submission to Web3Forms via fetch === */
  const form = document.querySelector('.contact-form');
  if (form) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const btn = form.querySelector('button[type="submit"]');
      if (!btn) return;
      const originalLabel = btn.textContent;
      const accessKey = form.querySelector('input[name="access_key"]')?.value;

      // If access key still placeholder, fall back to mailto so it works locally
      if (!accessKey || accessKey === 'YOUR_WEB3FORMS_KEY') {
        const data = new FormData(form);
        const body = encodeURIComponent(
          `New estimate request from ${data.get('first_name')} ${data.get('last_name')}\n\n` +
          `Email: ${data.get('email')}\nPhone: ${data.get('phone') || '(not provided)'}\n` +
          `City: ${data.get('city')}\nService: ${data.get('service')}\n\n` +
          `Message:\n${data.get('message') || '(none)'}`
        );
        window.location.href = `mailto:eaglescapes23@gmail.com?subject=New%20Estimate%20Request&body=${body}`;
        return;
      }

      btn.textContent = 'Sending…';
      btn.disabled = true;
      try {
        const res = await fetch(form.action, {
          method: 'POST',
          body: new FormData(form),
          headers: { 'Accept': 'application/json' }
        });
        const json = await res.json().catch(() => ({}));
        if (res.ok && json.success !== false) {
          btn.textContent = '✓ Got it! We\'ll be in touch within 24 hours.';
          btn.style.background = 'var(--brown-dark)';
          form.reset();
          setTimeout(() => {
            btn.textContent = originalLabel;
            btn.disabled = false;
            btn.style.background = '';
          }, 6000);
        } else {
          throw new Error(json.message || 'Form submission failed');
        }
      } catch (err) {
        btn.textContent = '⚠ Couldn\'t send — try calling (216) 214-2070';
        btn.style.background = '#a04040';
        setTimeout(() => {
          btn.textContent = originalLabel;
          btn.disabled = false;
          btn.style.background = '';
        }, 5000);
      }
    });
  }
});
