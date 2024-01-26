document.addEventListener("DOMContentLoaded", async function () {
  // NOTE: some of the variables referenced herein are defined in other script tags injected by prefab-cloud-jekyll.rb

  // cookies

  let contextAttributes = {};

  try {
    if (document.cookie.indexOf("tid=") === -1) {
      const guid = crypto.randomUUID();
      const expirationDate = new Date(
        new Date().setFullYear(new Date().getFullYear() + 1)
      ).toUTCString();
      document.cookie = `tid=${guid}; expires=${expirationDate}; domain=${config.cookieDomain}; SameSite=Lax; path=/`;
    }

    const trackingId = document.cookie
      .split("; ")
      .find((row) => row.startsWith("tid="))
      ?.split("=")[1];

    identifyCallback(trackingId);

    contextAttributes = {
      user: { key: trackingId },
    };
  } catch (e) {
    console.warn("Unable to access cookies");
  }

  // prefab initialization

  if (!window.prefab) {
    console.error("Unable to find Prefab client");
    return;
  }

  const onError = (error) => {
    console.log(error);
  };

  await window.prefab.init({
    contextAttributes,
    onError,
    ...config,
    // callback needs to come after the config object, because the name is duplicated in the config object
    afterEvaluationCallback,
  });

  // show/hide flag variants

  const flags = document.querySelectorAll("[data-flag-name]");
  flags.forEach((element) => {
    const name = element.dataset.flagName;
    const value = window.prefab.get(name);

    if (element.dataset.variant === value) {
      element.classList.remove("prefab-hidden");
    } else {
      element.classList.add("prefab-hidden");
    }
  });

  // inject config values

  const configs = document.querySelectorAll("[data-config-name]");
  configs.forEach((element) => {
    const name = element.dataset.configName;
    const value = window.prefab.get(name);

    if (value !== undefined) {
      element.innerHTML = value;
    }
  });
});
