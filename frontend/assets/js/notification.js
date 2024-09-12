let noti={
    error: function (title, message) {
  
      Swal.fire({
        icon: "error",
        html: message,
        title: title,
        customClass: "bg-warning-notifications"
      })
    },
    success: function(title, message){
      Swal.fire({
        button: {
          text: "Ok",
          className: "button-sweet-alert",
          closeModal: true
        },
        icon: "success",
        text: message,
        title: title,
        className: "bg-success-notifications"
      })
    },
    autoClose: function (title) {
      Swal.fire({
        title: title,
        type: 'success',
        timer: 2000,
        showConfirmButton: false
      })
    },
    loading: function (title) {
      Swal.fire({
        title: title,
        allowEscapeKey: false,
        allowOutsideClick: false,
        willClose: () => {
          Swal.showLoading();
        }
      })
    }
  }
  
  
  
  