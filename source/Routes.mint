routes {
  /add-wallet {
      Application.setPage("add-wallet")
  }

  /create-wallet {
      Application.setPage("create-wallet")
  }

  /import-wallet {
      Application.setPage("import-wallet")
  }

  /dashboard {
      Application.setPage("dashboard")
  }

  / {
      Application.setPage("dashboard")
  }

  /dashboard/send {
      Application.setPage("send")
  }

  /dashboard/receive {
      Application.setPage("receive")
  }

  /dashboard/transactions {
      Application.setPage("transactions")
  }

  /dashboard/backup {
      Application.setPage("backup")
  }

  * {
    Application.setPage("not_found")
  }
}
