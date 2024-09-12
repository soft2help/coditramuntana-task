let token = {
  get: function () {
    return localStorage.getItem("X-Auth-Token");
  },
  set: function (token) {
    localStorage.setItem("X-Auth-Token", token);
  },
  delete: function () {
    localStorage.removeItem("X-Auth-Token");
  },
};

let auth = {
  login: async function (email, password) {
    let receivedToken = null;
    await api
      .post(`auth/login`, {
        data: {
          attributes: {
            email: email,
            password: password
          }
        }

      })
      .then((response) => {
        receivedToken = response.data.token;
      });
    token.set(receivedToken);
    return receivedToken;
  },
  logout: async function () {
    await api.get(`auth/logout`);
    token.set(null);
    pages.login();
  },
  tokenExists: function () {
    return token.get() != null;
  },
  isLogged: function () {
    // return this.tokenExists() && this.checkLogged();
    return this.tokenExists();
  }
};

let pages = {
  logged: () => {
    if (!auth.isLogged()) {
      pages.login();
    }
  },
  login: () => {
    window.location.href = "/login";
  },

  index: () => {
    window.location.href = "/";
  },
  artists: {
    index: () => {
      window.location.href = `/artists`;
    },
    show: (id) => {
      window.location.href = `/artists/show/${id}`;
    },
    edit: (id) => {
      window.location.href = `/artists/edit/${id}`;
    }
  },
  lps: {
    index: () => {
      window.location.href = `/lps`;
    },
    show: (id) => {
      window.location.href = `/lps/show/${id}`;
    },
    edit: (id) => {
      window.location.href = `/lps/edit/${id}`;
    }
  }
};


$(() => {
  $(".logout").on("click", function () {
    auth.logout();
  });
});






