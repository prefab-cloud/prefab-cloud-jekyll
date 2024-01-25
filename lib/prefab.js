document.addEventListener("DOMContentLoaded", async function () {
  // cookie stuff

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
    afterEvaluationCallback: (key, value) => {
      window.posthog?.capture("Feature Flag Evaluation", {
        key,
        value,
      });
    },
    ...config,
  });

  // TODO: turn on polling

  // show variants

  // TODO: default / loading variant

  const elements = document.querySelectorAll("[data-flag-name]");
  elements.forEach((element) => {
    // console.log(
    //   `Experiment: ${element.dataset.flagName} Variant: ${
    //     element.dataset.variant
    //   } Value: ${window.prefab.get(element.dataset.flagName)}`
    // );

    const flagName = element.dataset.flagName;
    const value = window.prefab.get(flagName);
    if (element.dataset.variant === value) {
      element.style.display = "block";
    } else {
      element.style.display = "none";
    }
  });
});
