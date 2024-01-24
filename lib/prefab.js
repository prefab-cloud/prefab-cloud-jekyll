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

  const endpoints = [
    "https://api-catfood-staging-prefab-cloud.global.ssl.fastly.net/api/v1",
  ];

  const onError = (error) => {
    console.log(error);
  };

  const apiKey = window.prefabPlugin.apiKey;

  await window.prefab.init({
    apiKey,
    // apiKey: "105-staging-P100-E100-CLIENT-9898271b-6d07-497b-9396-7d4ad90947bd",
    // apiKey:
    //   process.env.NODE_ENV === "development"
    //     ? "105-staging-P100-E100-CLIENT-9898271b-6d07-497b-9396-7d4ad90947bd"
    //     : "104-production-P100-E101-CLIENT-fef75a8f-4423-4812-83f7-62e98ff3f232",
    contextAttributes,
    endpoints,
    onError,
    apiEndpoint: "https://api.catfood.staging-prefab.cloud/api/v1",
    collectEvaluationSummaries: true,
    afterEvaluationCallback: (key, value) => {
      window.posthog?.capture("Feature Flag Evaluation", {
        key,
        value,
      });
    },
  });

  // TODO: turn on polling

  // sleep just to see delay
  await new Promise((r) => setTimeout(r, 1000));

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
