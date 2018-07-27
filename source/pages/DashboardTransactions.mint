component DashboardTransactions {

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

        <Error/> 

        <Tabs
          currentTab={
            {
              name = "Transactions",
              path = "/dashboard/transactions"
            }
          }/>

        <div>
          <br/>
          <Transactions/>
        </div>
      </div>
    </div>
  }
}
