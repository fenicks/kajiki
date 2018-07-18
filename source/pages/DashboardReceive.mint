component DashboardReceive {

  connect WalletStore exposing { wallets }

  fun componentDidMount : Void {
    Common.redirectToAddWallet(wallets)
  }
  
  fun render : Html {
    <div class="row">
      <div class="col-md-3">
        <br/>
        <MyWallets/>
      </div>

      <div class="col-md-9">
        <br/>

        <Tabs
          currentTab={
            {
              name = "Receive",
              path = "/dashboard/receive"
            }
          }/>

        <div>
          <br/>
          <Receive/>
        </div>
      </div>
    </div>
  }
}
