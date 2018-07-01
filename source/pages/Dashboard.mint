record WalletItem {
  name : String,
  balance : String,
  address : String
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
  connect WalletStore exposing { getWallets, wallets, appendWalletItem, setError }
  connect CurrentWalletStore exposing { setCurrent, getCurrent }

  state : Dashboard.State {
    error = "",
    walletItems = []
  }

  fun getWalletBalance (w : EncryptedWalletWithName) : Void {
    do {
      response =
        Http.get(
          "https://testnet.sushichain.io:3443/api/v1/address/" + w.address + "/token/SUSHI")
        |> Http.send()

      json =
        Json.parse(response.body)
        |> Maybe.toResult("Json paring error")

      item =
        decode json as AddressAmountResponse

      balance =
        Array.firstWithDefault(
          {
            token = "SUSHI",
            amount = "0"
          },
          item.result.pairs)

      walletInfo =
        {
          name = w.name,
          balance = balance.amount,
          address = w.address
        }

      next { state | walletItems = Array.push(walletInfo, state.walletItems) }
    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
    }
  }

  fun getWalletItems () : Array(Void) {
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
          getWalletItems()
          void
        }
      }
    }
  }

  fun render : Html {
    <div class="row">
      <div class="col-md-3">
        <br/>
        <MyWallets wallets={state.walletItems}/>
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
