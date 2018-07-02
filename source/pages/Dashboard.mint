component Dashboard {
  connect WalletStore exposing { getWallets, wallets, getWalletItems, walletItems }
  connect CurrentWalletStore exposing { setCurrent, getCurrent }

  fun componentDidMount : Void {
    try {
      getWallets
      if (Array.isEmpty(wallets)) {
        try {
          Window.navigate("add-wallet")
        }
      } else {
        try {
          getWalletItems
        }
      }
    }
  }

  fun render : Html {
    <div class="row">
      <div class="col-md-3">
        <br/>
        <MyWallets wallets={walletItems}/>
      </div>

      <div class="col-md-9">
        <br/>

        <ul class="nav nav-tabs">
          <li class="nav-item">
            <a
              class="nav-link active"
              data-toggle="tab"
              href="#home">

              <{ "Summary" }>

            </a>
          </li>

          <li class="nav-item">
            <a
              class="nav-link"
              data-toggle="tab"
              href="#profile">

              <{ "Send" }>

            </a>
          </li>

          <li class="nav-item">
            <a
              class="nav-link"
              data-toggle="tab"
              href="#profile">

              <{ "Receive" }>

            </a>
          </li>

          <li class="nav-item">
            <a
              class="nav-link"
              data-toggle="tab"
              href="#profile">

              <{ "Transactions" }>

            </a>
          </li>
        </ul>

        <div>
          <br/>

          <Summary/>
        </div>
      </div>
    </div>
  }
}
