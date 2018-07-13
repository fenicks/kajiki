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

  /dashboard/receive {
    do {
      Application.setPage("receive")
    }
  }

  /dashboard/transactions {
    do {
      Application.setPage("transactions")
    }
  }

  /dashboard/backup {
    do {
      Application.setPage("backup")
    }
  }

  * {
    Application.setPage("not_found")
  }
}
