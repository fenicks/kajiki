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

  /dashboard {
    do {
      Application.setPage("dashboard")
    }
  }

  / {
    do {
      Application.setPage("dashboard")
    }
  }

  * {
    Application.setPage("not_found")
  }
}
