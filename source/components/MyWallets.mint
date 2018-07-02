component MyWallets {
  property wallets : Array(WalletItem) = []

    connect WalletStore exposing { refreshWalletItems }
    connect CurrentWalletStore exposing { setCurrent, getCurrent }

fun setCurrentWallet(wallet : WalletItem,event : Html.Event) : Void {
  try {
    setCurrent(wallet.address)
    refreshWalletItems
  }
}

fun renderWallet(wallet : WalletItem) : Html {
    <a onClick={\event : Html.Event => setCurrentWallet(wallet, event)} href="" class={"list-group-item list-group-item-action" + active}>
    <div>
    <strong><{wallet.name}></strong><br/>
    <span><i class="fas fa-dollar-sign text-muted"></i><{wallet.balance}></span>
    </div>
    </a>
} where {
  first = Array.firstWithDefault({name="",balance="",address=""}, wallets)
  activeAddress = Maybe.withDefault(first.address, getCurrent())
  active = if (activeAddress == wallet.address) {
    " active"
  } else {
    ""
  }
}

 fun render : Html {
   <div class="card mb-3">
  <h4 class="card-header"><{"My Wallets"}></h4>

  <ul class="list-group list-group-flush">
  <{
    wallets
    |> Array.map(renderWallet)
    }>
      <a href="/add-wallet" class="list-group-item list-group-item-action"><{"Add wallet"}></a>
  </ul>
  <div class="card-footer text-muted">
    <{"2 days"}>
  </div>
</div>

 }

}
