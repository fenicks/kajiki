component DashboardSummary {

  connect WalletStore exposing { wallets }

  fun componentDidMount : Promise(Never, Void) {
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

        <Error/>
        
        <Tabs
          currentTab={
            {
              name = "Summary",
              path = "/dashboard"
            }
          }/>

        <div>
          <br/>

          <Summary/>
        </div>
      </div>
    </div>
  }
}
