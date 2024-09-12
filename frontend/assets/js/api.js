let api = {
  isInnited: false,
  init: function (options = {}) {
    this.url = options.url || APIENDPOINT;
    this.headers = {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token.get()}`,
    };

    this.instance = axios.create({
      baseURL: this.url,
      timeout: 2000,
      headers: this.headers,
    });

    this.instance.interceptors.response.use(
      (response) => {
        console.log(response.config.custom);
        // Any status code that lies within the range of 2xx causes this function to trigger
        // Do something with response data
        console.log("Response interceptor:", response);
        return response;
      },
      (error) => {
        let showError = true;

        if (error.config.showErrors === false) {
          showError = false;
        }

        const status = error.response ? error.response.status : null;

        if (status === 401) {
          // Handle unauthorized access
          token.delete();
          pages.login();
        } else if (status === 400 || status === 500 || status === 403) {
          if (showError) {
            noti.error("Error", this.handleErrorResponse(error.response.data));
          }
        }
        // Any status codes that fall outside the range of 2xx cause this function to trigger
        // Do something with response error
        return Promise.reject(error);
      }
    );

    this.isInnited = true;
  },
  innited: function () {
    if (!this.isInnited) this.init();
  },
  handleErrorResponse: function (response) {
    let messageHTML = "";

    if (response.errors && Array.isArray(response.errors)) {
      // If the response contains an array of errors, iterate through them
      messageHTML = response.errors
        .map((error) => `<span class="error">${error.message}</span>`)
        .join("<br>");
    } else if (response.code && response.message) {
      // If the response is a single error object
      messageHTML = `<span class="error">${response.message}</span>`;
    }
    return messageHTML;
  },
  handleResponse: function (promise) {
    return promise
      .then((response) => {
        // Handle response
        console.log("Response handled:", response);
        return response;
      })
      .catch((error) => {
        // Handle error
        console.error("Error handled:", error);
        throw error;
      });
  },
  get: async function (url, options = {}) {
    this.innited();
    return this.handleResponse(this.instance.get(url, options));
  },
  delete: async function (url, options = {}) {
    this.innited();
    return this.handleResponse(this.instance.delete(url, options));
  },
  post: async function (url, params, options = {}) {
    this.innited();
    return this.handleResponse(this.instance.post(url, params, options));
  },
  put: async function (url, params, options = {}) {
    this.innited();
    return this.handleResponse(this.instance.put(url, params, options));
  },
};
