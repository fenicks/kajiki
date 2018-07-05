component MyWallets {
  connect WalletStore exposing {
    getWallets,
    getWalletItems,
    walletItems,
    refreshWalletItems,
    setCurrentAddress,
    getCurrentAddress,
    getCurrentWallet,
    currentWalletAddressOrFirst,
    getCurrentTransactions,
    getConfig
  }

  fun componentDidMount : Void {
    do {
      p1 =
        [
          getWallets,
          getWalletItems,
          getConfig
        ]

      `Promise.all(p1)`

      p2 =
        [
          getCurrentWallet,
          getCurrentTransactions
        ]

      `Promise.all(p2)`
    }
  }

  fun setCurrent (wallet : WalletItem, event : Html.Event) : Void {
    try {
      setCurrentAddress(wallet.address)
      refreshWalletItems
      getCurrentWallet
      getCurrentTransactions
    }
  }

  fun renderWallet (wallet : WalletItem) : Html {
    <a
      onClick={\event : Html.Event => setCurrent(wallet, event)}
      href=""
      class={"list-group-item list-group-item-action" + active}>

      <div>
        <strong>
          <{ wallet.name }>
        </strong>

        <br/>

        <span>
          <h6>
            <{ wallet.balance }>

            <span class="text-muted">
              <{ " (SUSHI)" }>
            </span>
          </h6>
        </span>
      </div>

    </a>
  } where {
    first =
      Array.firstWithDefault(
        {
          name = "",
          balance = "",
          address = ""
        },
        walletItems)

    activeWallet =
      getCurrentAddress
      |> Maybe.withDefault(first.address)

    active =
      if (activeWallet == wallet.address) {
        " active"
      } else {
        ""
      }
  }

  fun render : Html {
    <div class="card mb-3">
      <h4 class="card-header">
        <{ "My Wallets" }>
      </h4>

      <ul class="list-group list-group-flush">
        <{
          walletItems
          |> Array.map(renderWallet)
        }>
      </ul>

      <div class="card-footer text-muted">
        <ul class="list-group list-group-flush">
          <a href="/add-wallet">
            <i class="fas fa-plus"/>
            <{ " Add wallet" }>
          </a>
        </ul>
      </div>
    </div>
  }
}
