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
  walletItems : Array(WalletItem)
}

component Dashboard {
  connect WalletStore exposing { getWallets, wallets }

  state : Dashboard.State {
      walletItems = []
    }

fun getWalletItems(wallet : EncryptedWalletWithName) : WalletItem {
  try {
  response = Http.get("http://testnet.sushichain.io:3000/api/v1/address/" + wallet.address + "/token/SUSHI") |> Http.send()

    {name = wallet.name, balance = "0.1234"}
  }
}

  fun componentDidMount : Void {
    try {
      getWallets

      if (Array.isEmpty(wallets)) {
        Window.navigate("add-wallet")
      } else {
        do {
          wallets
          |> Array.map(getWalletItems)


    }
      }
    }
  }

  fun render : Html {
    <div class="row">
      <div class="col-mr-4">
      <br/>
        <MyWallets wallets={wallets}/>
      </div>

      <div class="col-md-4">
      <br/>
     <h3><{"Main tabs go here"}></h3>
      </div>
    </div>
  }
}
