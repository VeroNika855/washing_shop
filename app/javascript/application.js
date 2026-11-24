// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  const filters = document.querySelector("details.filters");
  if (filters && window.matchMedia("(max-width: 800px)").matches) {
    filters.removeAttribute("open");
  }
});

function startCountdowns() {
  document.querySelectorAll("[data-countdown]").forEach((box) => {
    const end = new Date(box.dataset.countdown).getTime();
    const pad = (n) => String(n).padStart(2, "0");

    const tick = () => {
      if (!box.isConnected) { clearInterval(box._timer); return; }
      const diff = Math.max(0, Math.floor((end - Date.now()) / 1000));
      const parts = {
        days: Math.floor(diff / 86400),
        hours: Math.floor((diff % 86400) / 3600),
        minutes: Math.floor((diff % 3600) / 60),
        seconds: diff % 60
      };
      Object.entries(parts).forEach(([unit, value]) => {
        const el = box.querySelector(`[data-unit="${unit}"]`);
        if (el) el.textContent = pad(value);
      });
    };

    tick();
    clearInterval(box._timer);
    box._timer = setInterval(tick, 1000);
  });
}
document.addEventListener("turbo:load", startCountdowns);

// Фільтр списку товарів у формі акції
document.addEventListener("input", (event) => {
  const input = event.target.closest("[data-filter-input]");
  if (!input) return;
  const query = input.value.trim().toLowerCase();
  document.querySelectorAll("[data-filter-item]").forEach((item) => {
    item.hidden = !item.textContent.toLowerCase().includes(query);
  });
});

// Вікно акції на товар (адмінка)
document.addEventListener("click", (event) => {
  const dialog = document.getElementById("promo-dialog");
  if (!dialog) return;

  if (event.target.closest("[data-close-dialog]")) {
    dialog.close();
    return;
  }

  const row = event.target.closest("[data-open-promo]");
  if (!row) return;

  const d = row.dataset;
  document.getElementById("promo-dialog-title").textContent = d.name;
  document.getElementById("promo-form").action = d.saveUrl;
  const stopForm = document.getElementById("promo-stop-form");
  stopForm.action = d.stopUrl;
  stopForm.hidden = d.hasPromo !== "true";
  document.getElementById("promo-percent").value = d.percent || "";
  document.getElementById("promo-start").value = d.start || d.defaultStart;
  document.getElementById("promo-duration").value = d.duration || 7;
  document.getElementById("promo-unit").value = d.unit || "days";
  dialog.showModal();
});

// Вибір номіналу сертифіката: оновлює ціну й напис на картці
document.addEventListener("change", (event) => {
  const radio = event.target.closest(".nominal input");
  if (!radio) return;
  document.querySelectorAll("[data-gift-amount]").forEach((el) => {
    el.textContent = radio.dataset.price;
  });
});

// Вікно «Передзвоніть мені» (посилання «Допомога» в шапці)
document.addEventListener("click", (event) => {
  const dialog = document.getElementById("callback-dialog");
  if (!dialog) return;

  if (event.target.closest("[data-open-callback]")) {
    event.preventDefault();
    dialog.showModal();
  } else if (event.target.closest("[data-close-callback]")) {
    dialog.close();
  }
});

// Заявки на дзвінок (адмінка): відкрити вікно з нотатками, закрити, автоматично відкрити після додавання
document.addEventListener("click", (event) => {
  const closer = event.target.closest("[data-dialog-close]");
  if (closer) {
    closer.closest("dialog").close();
    return;
  }

  const trigger = event.target.closest("[data-open-dialog]");
  if (!trigger) return;

  // Клік на посилання чи кнопку всередині рядка не відкриває вікно
  const interactive = event.target.closest("a, button, input, textarea, select, form");
  if (interactive && interactive !== trigger && !interactive.hasAttribute("data-open-dialog")) return;

  const dialog = document.getElementById(trigger.dataset.openDialog);
  if (dialog && !dialog.open) dialog.showModal();
});

document.addEventListener("turbo:load", () => {
  const id = new URLSearchParams(window.location.search).get("open");
  if (!id) return;
  const dialog = document.getElementById(`request-dialog-${id}`);
  if (dialog && !dialog.open) dialog.showModal();
  window.history.replaceState(null, "", window.location.pathname);
});

// Список наявних логотипів і картинок типів (приходить із сервера, без вгадування назв)
function imageManifest() {
  try {
    return JSON.parse(document.querySelector('meta[name="image-manifest"]')?.content || "[]");
  } catch (error) {
    return [];
  }
}
function findImage(folder, slug) {
  return imageManifest().find((path) => path.startsWith(`/images/${folder}/${slug}.`));
}

// Логотипи брендів замість назв у чипах каталогу
const BRAND_SLUGS = {
  "Beko": "beko", "Bosch": "bosch", "Candy": "candy", "Electrolux": "electrolux",
  "Gorenje": "gorenje", "Haier": "haier", "Indesit": "indesit", "LG": "lg",
  "Samsung": "samsung", "Siemens": "siemens", "Whirlpool": "whirlpool", "Zanussi": "zanussi"
};

function brandLogos() {
  document.querySelectorAll(".chip, .chips a").forEach((chip) => {
    if (chip.dataset.logoDone) return;
    chip.dataset.logoDone = "1";

    const textNode = [...chip.childNodes].find((n) => n.nodeType === Node.TEXT_NODE && n.textContent.trim());
    if (!textNode) return;
    const name = textNode.textContent.trim();
    const slug = BRAND_SLUGS[name];
    if (!slug) return;

    const src = findImage("brands", slug);
    if (!src) return; // файлу немає: лишається звичайний текст

    const img = new Image();
    img.className = "brand-logo";
    img.alt = name;
    img.title = name;
    img.src = src;

    const hidden = document.createElement("span");
    hidden.textContent = name;
    hidden.className = "brand-name-hidden";

    textNode.textContent = "";
    chip.insertBefore(hidden, chip.firstChild);
    chip.insertBefore(img, chip.firstChild);
  });
}
document.addEventListener("turbo:load", brandLogos);

// Картинки в чипах типу завантаження
function typeImages() {
  document.querySelectorAll(".chip, .chips a").forEach((chip) => {
    if (chip.dataset.typeDone) return;
    const text = chip.textContent.toLowerCase();

    let key = null;
    if (text.includes("фронтальн") || text.includes("front")) key = "front";
    if (text.includes("вертикальн") || text.includes("top")) key = "top";
    if (!key) return;

    chip.dataset.typeDone = "1";
    const src = findImage("types", key);
    if (!src) return;

    chip.classList.add("chip-type");
    const img = new Image();
    img.className = "type-img";
    img.alt = "";
    img.src = src;
    chip.insertBefore(img, chip.firstChild);
  });
}
document.addEventListener("turbo:load", typeImages);

// Обране: перемикання сердечка без перезавантаження сторінки
document.addEventListener("submit", async (event) => {
  const form = event.target;
  if (!form.matches || !form.matches(".heart-form")) return;

  event.preventDefault();
  const button = form.querySelector(".heart");
  const wasOn = button.classList.contains("on");
  button.classList.toggle("on", !wasOn); // миттєвий відгук, до відповіді сервера

  try {
    const response = await fetch(form.action, {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
      }
    });
    const data = await response.json();

    // Гість: відправляємо на сторінку входу
    if (response.status === 401) {
      window.location.href = data.login_url;
      return;
    }

    button.classList.toggle("on", data.liked);

    // Лічильник у шапці
    const link = document.querySelector('.header-icons a[href="/favorites"]');
    if (link) {
      let badge = link.querySelector(".cart-badge");
      if (data.count > 0) {
        if (!badge) {
          badge = document.createElement("span");
          badge.className = "cart-badge";
          link.appendChild(badge);
        }
        badge.textContent = data.count;
      } else if (badge) {
        badge.remove();
      }
    }

    // На сторінці «Обране» прибраний товар зникає зі списку
    if (!data.liked && window.location.pathname === "/favorites") {
      form.closest(".product-card")?.remove();
    }
  } catch (error) {
    button.classList.toggle("on", wasOn); // повертаємо як було
    form.submit(); // запасний варіант: звичайна відправка форми
  }
}, true);

// Кошик: швидке додавання товару без перезавантаження сторінки
function showToast(text, isError = false) {
  let toast = document.getElementById("toast");
  if (!toast) {
    toast = document.createElement("div");
    toast.id = "toast";
    document.body.appendChild(toast);
  }
  toast.textContent = text;
  toast.className = "show" + (isError ? " error" : "");
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => { toast.className = ""; }, 2500);
}

function updateCartBadge(count) {
  const link = document.querySelector('.header-icons a[href="/cart"]');
  if (!link) return;
  let badge = link.querySelector(".cart-badge");
  if (count > 0) {
    if (!badge) {
      badge = document.createElement("span");
      badge.className = "cart-badge";
      link.appendChild(badge);
    }
    badge.textContent = count;
  } else if (badge) {
    badge.remove();
  }
}

document.addEventListener("submit", async (event) => {
  const form = event.target;
  const action = form.getAttribute && form.getAttribute("action");
  if (!action || !/\/cart\/add\/\d+$/.test(action)) return;

  event.preventDefault();
  const button = form.querySelector("button, input[type=submit]");
  if (button?.disabled) return;
  const original = button?.textContent;
  if (button) { button.disabled = true; button.textContent = "✓"; }

  try {
    const response = await fetch(action.replace("/cart/add/", "/cart/quick/"), {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
      }
    });
    const data = await response.json();

    updateCartBadge(data.count);
    showToast(data.message || data.error, !response.ok);
  } catch (error) {
    form.submit(); // запасний варіант: звичайна відправка форми
    return;
  } finally {
    if (button) setTimeout(() => { button.textContent = original; button.disabled = false; }, 900);
  }
}, true);

// Сторінка кошика: видалення й зміна кількості без перезавантаження
document.addEventListener("submit", async (event) => {
  const form = event.target;
  const action = form.getAttribute && form.getAttribute("action");
  if (!action || !/\/cart\/(remove|update)\/\d+$/.test(action)) return;

  event.preventDefault();
  const scrollY = window.scrollY;
  form.style.opacity = ".5";

  try {
    const response = await fetch(action, {
      method: "POST",
      body: new FormData(form),           // містить _method (delete/patch) і токен
      credentials: "same-origin",
      headers: { "Accept": "text/html" }
    });
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");

    // Повідомлення сервера показуємо спливаючим вікном, а не блоком на сторінці
    const flash = doc.querySelector(".flash");
    if (flash) { showToast(flash.textContent.trim(), flash.classList.contains("err")); }
    doc.querySelectorAll(".flash").forEach((el) => el.remove());

    // Підміняємо вміст кошика й іконки в шапці
    const freshMain = doc.querySelector("main");
    const currentMain = document.querySelector("main");
    if (freshMain && currentMain) currentMain.innerHTML = freshMain.innerHTML;

    const freshIcons = doc.querySelector(".header-icons");
    const currentIcons = document.querySelector(".header-icons");
    if (freshIcons && currentIcons) currentIcons.innerHTML = freshIcons.innerHTML;

    window.scrollTo(0, scrollY);
  } catch (error) {
    form.submit(); // запасний варіант: звичайна відправка форми
  }
}, true);

// Подарункові сертифікати: додавання в кошик без переходу зі сторінки
document.addEventListener("submit", async (event) => {
  const form = event.target;
  const action = form.getAttribute && form.getAttribute("action");
  if (!action || !/\/gift-cards\/?$/.test(action)) return;

  event.preventDefault();
  const button = form.querySelector("button, input[type=submit]");
  if (button?.disabled) return;
  const original = button ? (button.value || button.textContent) : "";
  if (button) button.disabled = true;

  try {
    const response = await fetch(action, {
      method: "POST",
      body: new FormData(form),
      credentials: "same-origin",
      headers: { "Accept": "text/html" }
    });
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");

    // Лічильник кошика в шапці з відповіді сервера
    const freshIcons = doc.querySelector(".header-icons");
    const currentIcons = document.querySelector(".header-icons");
    if (freshIcons && currentIcons) currentIcons.innerHTML = freshIcons.innerHTML;

    // Повідомлення (успіх або помилка валідації)
    const flash = doc.querySelector(".flash");
    const error = doc.querySelector(".flash.err, .errors, .field-error");
    if (error) {
      showToast(error.textContent.trim(), true);
    } else {
      showToast(flash ? flash.textContent.trim()
                      : (document.documentElement.lang === "en" ? "Added to cart" : "Сертифікат додано до кошика"));
    }
  } catch (err) {
    form.submit(); // запасний варіант: звичайна відправка форми
    return;
  } finally {
    if (button) setTimeout(() => { button.disabled = false; }, 700);
  }
}, true);

// Точна висота верхньої смужки й головної шапки для закріплення
function measureHeader() {
  const topbar = document.querySelector(".topbar");
  const mainbar = document.querySelector(".mainbar");
  const root = document.documentElement.style;
  if (topbar) root.setProperty("--topbar-h", `${topbar.offsetHeight}px`);
  if (mainbar) root.setProperty("--mainbar-h", `${mainbar.offsetHeight}px`);
}
document.addEventListener("turbo:load", measureHeader);
window.addEventListener("resize", measureHeader);

// Верхня смужка-оголошення: можна закрити, запам'ятовується
function initAnnounce() {
  const bar = document.querySelector("[data-announce]");
  if (!bar) return;
  let closed = false;
  try { closed = localStorage.getItem("announce-closed") === "1"; } catch (e) {}
  if (closed) { bar.hidden = true; return; }
  bar.querySelector("[data-announce-close]")?.addEventListener("click", () => {
    bar.hidden = true;
    try { localStorage.setItem("announce-closed", "1"); } catch (e) {}
  });
}
document.addEventListener("turbo:load", initAnnounce);

// Вікно Чорної п'ятниці: один раз за сесію, тільки на головній
document.addEventListener("turbo:load", () => {
  const dialog = document.getElementById("welcome-dialog");
  if (!dialog || window.location.pathname !== "/") return;
  let shown = false;
  try { shown = sessionStorage.getItem("welcome-shown") === "1"; } catch (e) {}
  if (shown) return;
  setTimeout(() => {
    if (dialog.isConnected && !dialog.open) {
      dialog.showModal();
      try { sessionStorage.setItem("welcome-shown", "1"); } catch (e) {}
    }
  }, 4000);
});

// ===== Оплата карткою =====
(function () {
  const setText = (id, text) => { const el = document.getElementById(id); if (el) el.textContent = text; };

  document.addEventListener("change", (e) => {
    if (e.target.id !== "order_payment") return;
    const box = document.getElementById("card-box");
    if (box) box.hidden = e.target.value !== "Переказ на картку";
  });

  document.addEventListener("input", (e) => {
    const t = e.target;
    if (t.id === "card_number") {
      const d = t.value.replace(/\D/g, "").slice(0, 16);
      t.value = d.replace(/(.{4})/g, "$1 ").trim();
      setText("cv-num", t.value || "•••• •••• •••• ••••");
    } else if (t.id === "card_expiry") {
      let d = t.value.replace(/\D/g, "").slice(0, 4);
      if (d.length > 2) d = d.slice(0, 2) + "/" + d.slice(2);
      t.value = d;
      setText("cv-exp", d || "MM/РР");
    } else if (t.id === "card_cvv") {
      t.value = t.value.replace(/\D/g, "").slice(0, 3);
    } else if (t.id === "card_holder") {
      setText("cv-holder", t.value.toUpperCase() || "IVAN IVANOV");
    }
  });
})();

