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

record TransactionResponse {
  result : Kajiki.Transaction,
  status : String
}

record Kajiki.Sender {
  address : String,
  publicKey : String using "public_key",
  amount : Number,
  fee : Number,
  signr : String using "sign_r",
  signs : String using "sign_s"
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
  prevHash : String,
  timestamp : Number,
  scaled : Number
}

module Target.Network {
  fun testNet : TargetNetwork {
    {
      name = "Testnet",
      url = "https://testnet.sushichain.io:3443"
    }
  }

  fun local : TargetNetwork {
    {
      name = "Local",
      url = "http://localhost:3000"
    }
  }
}

record TargetNetwork {
  name : String,
  url : String
}

record Config {
  network : TargetNetwork
}

store WalletStore {
  state wallets : Array(EncryptedWalletWithName) = []
  state walletItems : Array(WalletItem) = []
  state error : String = ""
  state currentWalletAddress : Maybe(String) = Maybe.nothing()
  state currentWallet : Maybe(CurrentWallet) = Maybe.nothing()
  state currentTransactions : Array(Kajiki.Transaction) = []
  state config : Config = { network = Target.Network.testNet() }
  state transaction1 : Maybe(Kajiki.Transaction) = Maybe.nothing()

  fun setError (value : String) : Void {
    next { error = value }
  }

  fun clearError() : Void {
    next { error = ""}
  }

  fun getError() : String {
    error
  }

  fun setNetwork (network : TargetNetwork) : Void {
    do {
      updatedConfig =
        { network = network }

      updateConfig(updatedConfig)
    } catch Storage.Error => error {
      next { error = "could not set config: network type" }
    }
  }

  get getNetwork : TargetNetwork {
    try {
      config.network
    }
  }

  fun setCurrentAddress (address : String) : Void {
    next { currentWalletAddress = Maybe.just(address) }
  }

  get getCurrentAddress : Maybe(String) {
    currentWalletAddress
  }

  get emptyEncryptedWalletWithName : EncryptedWalletWithName {
    {
      name = "",
      source = "",
      ciphertext = "",
      address = "",
      salt = ""
    }
  }

  fun encodeSender (sender : Sender) : Object {
    Object.Encode.object(
      [
        Object.Encode.field(
          "address",
          Object.Encode.string(sender.address)),
        Object.Encode.field(
          "public_key",
          Object.Encode.string(sender.publicKey)),
        Object.Encode.field(
          "amount",
          Object.Encode.string(sender.amount)),
        Object.Encode.field("fee", Object.Encode.string(sender.fee)),
        Object.Encode.field(
          "sign_r",
          Object.Encode.string(sender.signr)),
        Object.Encode.field(
          "sign_s",
          Object.Encode.string(sender.signs))
      ])
  }

  fun encodeRecipient (r : Recipient) : Object {
    Object.Encode.object(
      [
        Object.Encode.field(
          "address",
          Object.Encode.string(r.address)),
        Object.Encode.field("amount", Object.Encode.string(r.amount))
      ])
  }

  fun encodeKajikiSender (sender : Kajiki.Sender) : Object {
    Object.Encode.object(
      [
        Object.Encode.field(
          "address",
          Object.Encode.string(sender.address)),
        Object.Encode.field(
          "public_key",
          Object.Encode.string(sender.publicKey)),
        Object.Encode.field(
          "amount",
          Object.Encode.number(sender.amount)),
        Object.Encode.field("fee", Object.Encode.number(sender.fee)),
        Object.Encode.field(
          "sign_r",
          Object.Encode.string(sender.signr)),
        Object.Encode.field(
          "sign_s",
          Object.Encode.string(sender.signs))
      ])
  }

  fun encodeKajikiRecipient (r : Kajiki.Recipient) : Object {
    Object.Encode.object(
      [
        Object.Encode.field(
          "address",
          Object.Encode.string(r.address)),
        Object.Encode.field("amount", Object.Encode.number(r.amount))
      ])
  }

  fun encodeSenders (senders : Array(Sender)) : Array(Object) {
    senders
    |> Array.map(encodeSender)
  }

  fun encodeKajikiSenders (senders : Array(Kajiki.Sender)) : Array(Object) {
    senders
    |> Array.map(encodeKajikiSender)
  }

  fun encodeRecipients (recipients : Array(Recipient)) : Array(Object) {
    recipients
    |> Array.map(encodeRecipient)
  }

  fun encodeKajikiRecipients (recipients : Array(Kajiki.Recipient)) : Array(Object) {
    recipients
    |> Array.map(encodeKajikiRecipient)
  }

  fun getTransaction (transaction : Transaction, signed : Bool) : Void {
    do {
      senders =
        if (signed) {
          encodeKajikiSenders(
            transaction.senders
            |> Array.map(Common.toKajikiSender))
        } else {
          encodeSenders(transaction.senders)
        }

      recipients =
        if (signed) {
          encodeKajikiRecipients(
            transaction.recipients
            |> Array.map(Common.toKajikiRecipient))
        } else {
          encodeRecipients(transaction.recipients)
        }

      encoded =
        Object.Encode.object(
          [
            Object.Encode.field(
              "id",
              Object.Encode.string(transaction.id)),
            Object.Encode.field(
              "action",
              Object.Encode.string(transaction.action)),
            Object.Encode.field("senders", Object.Encode.array(senders)),
            Object.Encode.field(
              "recipients",
              Object.Encode.array(recipients)),
            Object.Encode.field(
              "message",
              Object.Encode.string(transaction.message)),
            Object.Encode.field(
              "token",
              Object.Encode.string(transaction.token)),
            Object.Encode.field(
              "prev_hash",
              Object.Encode.string(transaction.prevHash)),
            Object.Encode.field(
              "timestamp",
              Object.Encode.number(transaction.timestamp)),
            Object.Encode.field(
              "scaled",
              Object.Encode.number(transaction.scaled))
          ])

      jsonTransaction =
        if (signed) {
          Object.Encode.object(
            [Object.Encode.field("transaction", encoded)])
        } else {
          encoded
        }

      url =
        if (signed) {
          "/api/v1/transaction"
        } else {
          "/api/v1/transaction/unsigned"
        }

      response =
        Http.post(getNetwork.url + url)
        |> Http.stringBody(
          Common.compactJson(Json.stringify(jsonTransaction)))
        |> Http.send()

      json =
        Json.parse(response.body)
        |> Maybe.toResult("Json parsing error")

      item =
        decode json as TransactionResponse

      txn =
        item.result

      next {transaction1 = Maybe.just(txn) }
    } catch Http.ErrorResponse => error {
      next { error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { error = "Could not parse json response" }
    } catch Object.Error => error {
      next { error = "could not decode json" }
    }
  }

  get currentWalletAddressOrFirst : String {
    try {
      first =
        Array.firstWithDefault(
          {
            name = "",
            balance = "",
            address = ""
          },
          walletItems)

      getCurrentAddress
      |> Maybe.withDefault(first.address)
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


       Debug.log(json)

      item =
        decode json as AddressTransactionsResponse



      next { currentTransactions = item.result }
    } catch Http.ErrorResponse => error {
      next { error = "Could not retrieve wallet transactions" }
    } catch String => error {
      next { error = "Could not parse json response" }
    } catch Object.Error => error {
      next { error = "could not decode json" }
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

      balances =
        item.result.pairs

      wallet =
        wallets
        |> Array.find(
          (w : EncryptedWalletWithName) : Bool => { w.address == currentWalletAddressOrFirst})
        |> Maybe.withDefault(emptyEncryptedWalletWithName)

      cw =
        {
          wallet = wallet,
          balances = balances
        }

      next {currentWallet = Maybe.just(cw) }
    } catch Http.ErrorResponse => error {
      next {error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next {error = "Could not parse json response" }
    } catch Object.Error => error {
      next { error = "could not decode json" }
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

      next { walletItems = replaceItem(walletInfo) }
    } catch Http.ErrorResponse => error {
      next { error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { error = "Could not parse json response" }
    } catch Object.Error => error {
      next { error = "could not decode json" }
    }
  }

  fun replaceItem (w : WalletItem) : Array(WalletItem) {
    try {
      exists =
        Array.find(
          (i : WalletItem) : Bool => {i.address == w.address},
        walletItems)

      if (Maybe.isJust(exists)) {
        Array.map(
          (i : WalletItem) : WalletItem => {
            if (i.address == w.address) {
              w
            } else {
              i
            }},
          walletItems)
      } else {
        Array.push(w, walletItems)
      }
    }
  }

  get getWalletItems : Void {
    do {
      promises =
        Array.map(getWalletBalance, wallets)

      `Promise.all(promises)`
    }
  }

  fun storeWallet (encWallet : EncryptedWalletWithName) : Void {
    try {
      getWallets

      if (Array.isEmpty(wallets)) {
        do {
          storeFirstWallet(encWallet)
          next { error = "" }
        } catch Storage.Error => error {
          next { error = "" }
        }
      } else {
        try {
          alreadyExists =
            wallets
            |> Array.map((w : EncryptedWalletWithName) : String => { w.address })
            |> Array.contains(encWallet.address)

          if (alreadyExists) {
            next { error = "A wallet with address: " + encWallet.address + " already exists - so not storing this again." }
          } else {
            do {
              appendWallet(encWallet)
              next { error = "" }
            } catch Storage.Error => error {
              next { error = "" }
            }
          }
        }
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
        Array.push(encWallet, wallets)

      encoded =
        updated
        |> Array.map((ew : EncryptedWalletWithName) : Object => { encode ew })

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

      theWallets =
        decode object as Array(EncryptedWalletWithName)

      next { wallets = theWallets }
    } catch Object.Error => error {
      void
    } catch String => error {
      void
    } catch Storage.Error => error {
      void
    }
  }

  fun updateConfig (config : Config) : Result(Storage.Error, Void) {
    try {
      encoded =
        encode config

      asString =
        Json.stringify(encoded)

      Storage.Local.set("kajiki_config", asString)
    }
  }

  get getConfig : Void {
    do {
      raw =
        Storage.Local.get("kajiki_config")

      object =
        Json.parse(raw)
        |> Maybe.toResult("Json Parsing Error")

      config =
        decode object as Config

      next { config = config }
    } catch Object.Error => error {
      void
    } catch String => error {
      void
    } catch Storage.Error => error {
      void
    }
  }
}
