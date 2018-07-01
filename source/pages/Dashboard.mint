record WalletItem {
  name : String,
  balance : String
}

record TokenPair {
  token : String,
  amount : String
}

record AddressAmount {
  confirmation : Number,
  pairs : Array(TokenPair)
}

record AddressAmountResponse {
  result : AddressAmount,
  status : String
}

record Dashboard.State {
  error : String,
  walletItems : Array(WalletItem)
}

component Dashboard {
  connect WalletStore exposing { getWallets, wallets }

  state : Dashboard.State {error = "", walletItems = []}

  fun getWalletBalance(w : EncryptedWalletWithName) : Void {
   do {
     response = Http.get("http://testnet.sushichain.io:3000/api/v1/address/" + w.address + "/token/SUSHI") |> Http.send()
     json = Json.parse(response.body)
            |> Maybe.toResult("Json paring error")

      item = decode json as AddressAmountResponse

      balance = Array.firstWithDefault({token = "SUSHI", amount = "0"}, item.result.pairs)

      walletInfo = {name = w.name, balance = balance.amount}

      next { state | walletItems = Array.push(walletInfo, state.walletItems)}

   } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information"}
   } catch String => error {
     next { state  | error = "Could not parse json response"}
   } catch Object.Error => error {
     next { state | error = "could not decode json"}
   }
  }

  fun getWalletItems (wallets : Array(EncryptedWalletWithName)) : Array(Void) {
      wallets
      |> Array.map(getWalletBalance)
  }

  fun componentDidMount : Void {
    try {
      getWallets

      if (Array.isEmpty(wallets)) {
        try {
        Window.navigate("add-wallet")
        void
      }
      } else {
        try {
        getWalletItems(wallets)
        void
      }
      }
    }
  }

  fun render : Html {
    <div class="row">
      <div class="col-mr-4">
        <br/>
        <MyWallets wallets={state.walletItems}/>
      </div>

      <div class="col-md-4">
        <br/>

        <h3>
          <{ "Main tabs go here" }>
        </h3>
      </div>
    </div>
  }
}
