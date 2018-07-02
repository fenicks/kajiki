component MyWallets {
  property wallets : Array(WalletItem) = []

  connect WalletStore exposing { refreshWalletItems, setCurrentAddress, getCurrentAddress, getCurrentWallet, currentWalletAddressOrFirst, getCurrentTransactions }

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
        wallets)

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
          wallets
          |> Array.map(renderWallet)
        }>
      </ul>

      <div class="card-footer text-muted">
        <ul class="list-group list-group-flush">
          <a href="/add-wallet">
            <i class="fas fa-plus"></i><{ " Add wallet" }>
          </a>
        </ul>
      </div>
    </div>
  }
}
