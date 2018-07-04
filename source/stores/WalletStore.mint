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

record CurrentWallet {
  wallet : EncryptedWalletWithName,
  balances : Array(TokenPair)
}

record AddressTransactionsResponse {
  result : Array(Kajiki.Transaction),
  status : String
}


record Kajiki.Sender {
  address : String,
  publicKey : String,
  amount : Number,
  fee : Number,
  signr : String from "sign_r",
  signs : String from "sign_s"
}

record Kajiki.Recipient {
  address : String,
  amount : Number
}

record Kajiki.Transaction {
  id : String,
  action : String,
  senders : Array(Kajiki.Sender),
  recipients : Array(Kajiki.Recipient),
  message : String,
  token : String,
  prevHash : String from "prev_hash",
  timestamp : Number,
  scaled : Number
}

module Target.Network {
  fun testNet () : TargetNetwork {
    {name = "Testnet", url = "https://testnet.sushichain.io:3443"}
  }
  fun local () : TargetNetwork {
    {name = "Local", url = "http://localhost:3000"}
  }
}

record TargetNetwork {
  name : String,
  url : String
}

store WalletStore {
  property wallets : Array(EncryptedWalletWithName) = []
  property walletItems : Array(WalletItem) = []
  property error : String = ""
  property currentWalletAddress : Maybe(String) = Maybe.nothing()
  property currentWallet : Maybe(CurrentWallet) = Maybe.nothing()
  property currentTransactions : Array(Kajiki.Transaction) = []
  property targetNetwork : TargetNetwork = Target.Network.testNet()

  fun setNetwork(network : TargetNetwork) : Void {
    next { state | targetNetwork = network }
  }

  get getNetwork : TargetNetwork {
    try {
    state.targetNetwork
     }
  }

  fun setCurrentAddress(address : String) : Void {
    next {state | currentWalletAddress = Maybe.just(address)}
  }

  get getCurrentAddress : Maybe(String) {
    state.currentWalletAddress
  }

  get emptyEncryptedWalletWithName : EncryptedWalletWithName {
    {name = "",
    source = "",
    ciphertext = "",
    address = "",
    salt = ""}
  }

  get currentWalletAddressOrFirst : String {
    try {
      first = Array.firstWithDefault({name="",balance="",address=""}, walletItems)
      getCurrentAddress |> Maybe.withDefault(first.address)
    }
  }

  get getCurrentTransactions : Void {
    do {
    response =
      Http.get(
        getNetwork.url + "/api/v1/address/" + currentWalletAddressOrFirst + "/transactions")
      |> Http.send()

      json =
        Json.parse(response.body)
        |> Maybe.toResult("Json paring error")

        item =
          decode json as AddressTransactionsResponse

          Debug.log(item.result)

       next { state | currentTransactions = item.result}

    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve wallet transactions" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
    }
  }

  get getCurrentWallet : Void {
    do {
      response =
        Http.get(
          getNetwork.url + "/api/v1/address/" + currentWalletAddressOrFirst)
        |> Http.send()

        json =
          Json.parse(response.body)
          |> Maybe.toResult("Json paring error")

        item =
          decode json as AddressAmountResponse

        balances = item.result.pairs

        wallet = wallets
                 |> Array.find(\w : EncryptedWalletWithName => w.address == currentWalletAddressOrFirst)
                 |> Maybe.withDefault(emptyEncryptedWalletWithName)

       cw = {
         wallet = wallet,
         balances = balances
       }

      next { state | currentWallet = Maybe.just(cw)}

    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
    }
  }

  fun getWalletBalance (w : EncryptedWalletWithName) : Void {
    do {
      response =
        Http.get(
          getNetwork.url + "/api/v1/address/" + w.address + "/token/SUSHI")
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

        Debug.log("hello:")
        Debug.log(walletInfo)

      next { state | walletItems = replaceItem(walletInfo) }
      Debug.log("after:")
      Debug.log(state.walletItems)
    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
    }
  }

  fun replaceItem(w : WalletItem) : Array(WalletItem) {
    try {
      exists = Array.find(\i : WalletItem => i.address == w.address, state.walletItems)
      if(Maybe.isJust(exists)){
        Array.map(\i : WalletItem => if(i.address == w.address){ w } else { i }, state.walletItems)
      } else {
        Array.push(w, state.walletItems)
      }
    }
  }

  get getWalletItems : Void {
    do {
      promises = Array.map(getWalletBalance, wallets)
      `Promise.all(promises)`
    }
  }

  fun storeWallet (encWallet : EncryptedWalletWithName) : Result(Storage.Error, Void) {
    try {
      getWallets

      if (Array.isEmpty(state.wallets)) {
        storeFirstWallet(encWallet)
      } else {
        appendWallet(encWallet)
      }
    }
  }

  get refreshWalletItems : Void {
    do {
      getWalletItems
    }
  }

  fun storeFirstWallet (encWallet : EncryptedWalletWithName) : Result(Storage.Error, Void) {
    try {
      wallet =
        encode encWallet

      encodedArray =
        Object.Encode.array([wallet])

      asString =
        Json.stringify(encodedArray)

      Storage.Local.set("kajiki_wallets", asString)
    }
  }

  fun appendWallet (encWallet : EncryptedWalletWithName) : Result(Storage.Error, Void) {
    try {
      updated =
        Array.push(encWallet, state.wallets)

      encoded =
        updated
        |> Array.map(
          \ew : EncryptedWalletWithName => encode ew)

      encodedArray =
        Object.Encode.array(encoded)

      asString =
        Json.stringify(encodedArray)

      Storage.Local.set("kajiki_wallets", asString)
    }
  }

  get getWallets : Void {
    do {
      raw =
        Storage.Local.get("kajiki_wallets")

      object =
        Json.parse(raw)
        |> Maybe.toResult("Json Parsing Error")

      wallets =
        decode object as Array(EncryptedWalletWithName)

      next { state | wallets = wallets }
    } catch Object.Error => error {
      void
    } catch String => error {
      void
    } catch Storage.Error => error {
      void
    }
  }
}
