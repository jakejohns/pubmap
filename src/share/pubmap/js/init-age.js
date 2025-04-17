(function () {
  // Get the document creation date from the meta tag with dcterms.created
  const metaTag = document.querySelector('meta[name="dcterms.created"]');
  if (!metaTag) {
    console.error('Meta tag with name "dcterms.created" not found!');
    return;
  }

  const creationDate = new Date(metaTag.getAttribute("content"));
  const currentDate = new Date();
  const ageInMilliseconds = currentDate - creationDate;

  // Convert milliseconds to days
  const ageInDays = Math.floor(ageInMilliseconds / (1000 * 60 * 60 * 24));
  const ageInYears = Math.floor(ageInDays / 365);
  const remainingMonths = Math.floor((ageInDays % 365) / 30);
  const remainingDays = ageInDays % 30;

  // Dont alter if kinnda newish
  if (ageInDays < 2) {
    return;
  }

  // Determine the label for the document's age
  let ageString = "";

  if (ageInYears > 0) {
    ageString = `${ageInYears} year${ageInYears > 1 ? "s" : ""} old`;
  } else if (remainingMonths > 0) {
    ageString = `${remainingMonths} month${remainingMonths > 1 ? "s" : ""} old`;
  } else if (remainingDays > 0) {
    ageString = `${remainingDays} day${remainingDays > 1 ? "s" : ""} old`;
  }

  // Add the age string to the #header element
  const masthead = document.getElementById("masthead");
  if (masthead && ageString) {
    const ageElement = document.createElement("div");
    ageElement.textContent = `(${ageString})`;
    masthead.appendChild(ageElement);
  }
})();
