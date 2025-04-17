(function () {
  function toggleTheme() {
    // Toggle the 'light-theme' class on the body element
    document.body.classList.toggle("light-theme");

    // Change the icon based on the current theme
    const button = document.getElementById("theme-toggle-btn");
    button.textContent = document.body.classList.contains("light-theme")
      ? "💡"
      : "🌙";
  }

  const button = document.createElement("button");
  button.id = "theme-toggle-btn";
  button.textContent = "🌙";
  button.className = "toggle-btn";
  button.onclick = toggleTheme;
  document.getElementById("masthead").appendChild(button);
})();
