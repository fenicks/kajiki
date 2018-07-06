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

  /dashboard/send {
    do {
      Application.setPage("send")
    }
  }

  * {
    Application.setPage("not_found")
  }
}
