component Dashboard {
  connect WalletStore exposing { getWallets, wallets }

  fun componentDidMount : Void {
    try {
      getWallets

      if (Array.isEmpty(wallets)) {
        Window.navigate("add-wallet")
      } else {
        void
      }
    }
  }

  fun render : Html {
    <div class="row">
      <div class="col-mr-2">
        <MyWallets wallets={wallets}/>
      </div>

      <div class="col-md-9"/>
    </div>
  }
}
