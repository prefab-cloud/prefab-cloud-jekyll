document.addEventListener("DOMContentLoaded", async function () {
  // cookie stuff

  // need to pass in domain

  // need to pass in optional function get tracking id

  // pass in optional identify function too?

  // after evaluation callback function

  if (document.cookie.indexOf("tid=") === -1) {
    const guid = crypto.randomUUID();
    const expirationDate = new Date(
      new Date().setFullYear(new Date().getFullYear() + 1)
    ).toUTCString();
    document.cookie = `tid=${guid}; expires=${expirationDate}; domain=.prefab.cloud; SameSite=Lax; path=/`;
  }

  const tid = document.cookie
    .split("; ")
    .find((row) => row.startsWith("tid="))
    ?.split("=")[1];

  window.posthog?.identify(tid);

  const contextAttributes = {
    user: { key: tid },
  };

  // prefab initialization

  const onError = (error) => {
    console.log(error);
  };

  await window.prefab.init({
    contextAttributes,
    onError,
    ...config,
    // call backs need to come after the config object, because the names are duplicated
    afterEvaluationCallback,
  });

  // TODO: turn on polling

  // show variants

  // seems like we don't have to special case the default variant here, because it's on by default
  // and if there is a variant match it will get turned off
  // but does default only mean show when not loaded, or does it also mean show when no other match?
  // i guess it should be the loading thing, and then if there are other cases when you want it shown you should attach a variant to it
  // (this would typically be default + false or default + control)

  const flags = document.querySelectorAll("[data-flag-name]");
  flags.forEach((element) => {
    const flagName = element.dataset.flagName;
    const value = window.prefab.get(flagName);

    if (element.dataset.variant === value) {
      element.style.display = "block";
    } else {
      element.style.display = "none";
    }
  });

  // configs

  const configs = document.querySelectorAll("[data-config-name]");
  configs.forEach((element) => {
    const name = element.dataset.configName;
    const value = window.prefab.get(name);
    console.log(`config: ${name} value: ${value}`);

    if (value !== undefined) {
      element.innerHTML = value;
    }
  });
});
