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

store WalletStore {
  property wallets : Array(EncryptedWalletWithName) = []
  property walletItems : Array(WalletItem) = []
  property error : String = ""
  property currentWalletAddress : String = ""

  fun setCurrentAddress(address : String) : Void {
    next {state | currentWalletAddress = address}
  }

  fun getCurrentAddress : String {
    state.currentWalletAddress
  }

  fun getCurrentWallet : CurrentWallet {
    do {
      response =
        Http.get(
          "https://testnet.sushichain.io:3443/api/v1/address/" + w.address)
        |> Http.send()
    }
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

      next { state | walletItems = replaceItem(walletInfo) }
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
      wallets
      |> Array.map(getWalletBalance)
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
        Object.Encode.object(
          [
            Object.Encode.field(
              "name",
              Object.Encode.string(encWallet.name)),
            Object.Encode.field(
              "source",
              Object.Encode.string(encWallet.source)),
            Object.Encode.field(
              "ciphertext",
              Object.Encode.string(encWallet.ciphertext)),
            Object.Encode.field(
              "address",
              Object.Encode.string(encWallet.address)),
            Object.Encode.field(
              "salt",
              Object.Encode.string(encWallet.salt))
          ])

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
          \ew : EncryptedWalletWithName =>
            Object.Encode.object(
              [
                Object.Encode.field("name", Object.Encode.string(ew.name)),
                Object.Encode.field("source", Object.Encode.string(ew.source)),
                Object.Encode.field(
                  "ciphertext",
                  Object.Encode.string(ew.ciphertext)),
                Object.Encode.field(
                  "address",
                  Object.Encode.string(ew.address)),
                Object.Encode.field("salt", Object.Encode.string(ew.salt))
              ]))

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
