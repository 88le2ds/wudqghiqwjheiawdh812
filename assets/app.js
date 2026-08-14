(() => {
  "use strict";
  const $ = (selector, scope = document) => scope.querySelector(selector);
  const $$ = (selector, scope = document) => [...scope.querySelectorAll(selector)];

  const toggle = $(".nav-toggle");
  const links = $(".nav-links");
  if (toggle && links) {
    const close = () => { links.classList.remove("is-open"); toggle.setAttribute("aria-expanded", "false"); };
    toggle.addEventListener("click", () => { const open = links.classList.toggle("is-open"); toggle.setAttribute("aria-expanded", String(open)); });
    links.addEventListener("click", (event) => { if (event.target.closest("a")) close(); });
    document.addEventListener("keydown", (event) => { if (event.key === "Escape") close(); });
  }

  const reveals = $$(".reveal");
  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver((entries) => entries.forEach((entry) => {
      if (entry.isIntersecting) { entry.target.classList.add("is-visible"); observer.unobserve(entry.target); }
    }), { threshold: .12, rootMargin: "0px 0px -30px" });
    reveals.forEach((item) => observer.observe(item));
  } else reveals.forEach((item) => item.classList.add("is-visible"));

  $$("textarea[data-autogrow]").forEach((field) => {
    const resize = () => { field.style.height = "auto"; field.style.height = `${field.scrollHeight}px`; };
    field.addEventListener("input", resize); resize();
  });

  $$("form[data-form]").forEach((form) => form.addEventListener("submit", (event) => {
    event.preventDefault();
    const message = $(".form-message", form);
    if (!message) return;
    message.className = "form-message";
    if (!form.checkValidity()) { form.reportValidity(); message.textContent = "Please complete the required fields."; message.classList.add("is-error"); return; }
    if (form.dataset.form === "login") { message.textContent = "Login is not connected yet. Please contact Silverheart for access."; message.classList.add("is-error"); return; }
    const genres = $$("input[name='genre']:checked", form);
    if (!genres.length) { message.textContent = "Select at least one genre."; message.classList.add("is-error"); return; }
    const data = new FormData(form);
    const profile = { name: data.get("name"), email: data.get("email"), role: data.get("role"), genres: genres.map((input) => input.value), goal: data.get("goal"), createdAt: new Date().toISOString() };
    try { sessionStorage.setItem("silverheartProfile", JSON.stringify(profile)); } catch (_) { /* Continue if browser storage is unavailable. */ }
    window.location.assign("../submitted/");
  }));
})();
