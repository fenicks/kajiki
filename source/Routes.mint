routes {
  /add-wallet {
    do {
      Application.setPage("add-wallet")
    }
  }

  /create-wallet {
    do {
      Application.setPage("create-wallet")
    }
  }

  / {
    do {
      Application.setPage("add-wallet")
    }
  }

  * {
    Application.setPage("not_found")
  }
}
