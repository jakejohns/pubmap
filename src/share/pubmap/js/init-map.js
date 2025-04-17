(function () {
  const elements = document.querySelectorAll(".element");
  const theaders = document.querySelectorAll("tbody th");

  function toggleHighlight(story, isHighlight) {
    elements.forEach((el) => {
      if (el.getAttribute("data-story") === story) {
        el.classList.toggle("highlight", isHighlight);
      }
    });
  }

  // Click/Hover elements
  elements.forEach((ele) => {
    ele.addEventListener("mouseover", () =>
      toggleHighlight(ele.getAttribute("data-story"), true),
    );
    ele.addEventListener("mouseout", () =>
      toggleHighlight(ele.getAttribute("data-story"), false),
    );

    const tooltipText = document.createElement("span");
    tooltipText.className = "tooltip-text";

    const e_type = ele.getAttribute("data-type");
    const e_flat = ele.getAttribute("data-flat");
    const e_pages = ele.getAttribute("data-pages");
    const e_total = ele.getAttribute("data-tpages");
    const e_desc = ele.getAttribute("data-desc");
    const e_story = ele.getAttribute("data-story");
    const e_flatcount = ele.getAttribute("data-flatcount");
    const e_tip =
      e_type == "major"
        ? `<strong>~${e_pages}</strong>${e_flatcount > 1 ? "/" + e_total : ""}pp on flat ${e_flat}`
        : `${e_desc}`;
    tooltipText.innerHTML = `<span style="--item-color:var(--color${e_story});" class="${e_type}-tip">${e_tip}</span>`;

    document.body.appendChild(tooltipText);

    ele.addEventListener("mouseenter", () => {
      tooltipText.style.visibility = "visible";
      tooltipText.style.opacity = "1";
    });

    ele.addEventListener("mouseleave", () => {
      tooltipText.style.visibility = "hidden";
      tooltipText.style.opacity = "0";
    });

    ele.addEventListener("mousemove", (e) => {
      tooltipText.style.left = `${e.pageX + 5}px`;
      tooltipText.style.top = `${e.pageY + 5}px`;
    });
  });

  // Click table headers
  theaders.forEach((header) => {
    header.addEventListener("mouseover", () =>
      toggleHighlight(header.parentElement.getAttribute("data-story"), true),
    );
    header.addEventListener("mouseout", () =>
      toggleHighlight(header.parentElement.getAttribute("data-story"), false),
    );

    header.addEventListener("click", async () => {
      dataStory = header.parentElement.getAttribute("data-story");
      elements.forEach((ele) => {
        if (ele.getAttribute("data-story") === dataStory) {
          ele.scrollIntoView({ behavior: "smooth" });
          return;
        }
      });
      elements.forEach((ele) => {
        if (ele.getAttribute("data-story") === dataStory) {
          if (ele.getAttribute("data-type") == "minor") {
            const page = ele.closest(".flat");
            page.classList.remove("pulse2");
            void page.offsetWidth; // force reflow
            page.classList.add("pulse2");
          }
          ele.classList.remove("pulse");
          void ele.offsetWidth; //force reflow
          ele.classList.add("pulse");
        }
      });
    });
  });
})();
