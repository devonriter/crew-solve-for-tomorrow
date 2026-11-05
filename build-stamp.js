// Shows "Build #N, built 11:35 AM" at the bottom of a project page, so a team
// can tell their new version is up. The publish step writes build.json into the
// project's folder. With no build.json, this shows nothing.
(function () {
  fetch("./build.json", { cache: "no-store" })
    .then(function (response) {
      return response.ok ? response.json() : null;
    })
    .then(function (info) {
      if (!info || !Number.isInteger(info.build)) return;
      var built = new Date(info.builtAt);
      if (isNaN(built)) return;
      var time = built.toLocaleTimeString("en-US", {
        timeZone: "America/Detroit",
        hour: "numeric",
        minute: "2-digit",
      });
      var footer = document.createElement("footer");
      footer.textContent = "Build #" + info.build + ", built " + time;
      footer.style.cssText = "margin-top: 2rem; font-size: 0.85rem; opacity: 0.75;";
      document.body.appendChild(footer);
    })
    .catch(function () {});
})();
