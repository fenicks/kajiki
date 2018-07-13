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
  publicKey : String from "public_key",
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
  property wallets : Array(EncryptedWalletWithName) = []
  property walletItems : Array(WalletItem) = []
  property error : String = ""
  property currentWalletAddress : Maybe(String) = Maybe.nothing()
  property currentWallet : Maybe(CurrentWallet) = Maybe.nothing()
  property currentTransactions : Array(Kajiki.Transaction) = []
  property config : Config = { network = Target.Network.testNet()}
  property transaction1 : Maybe(Kajiki.Transaction) = Maybe.nothing()

  fun setNetwork (network : TargetNetwork) : Void {
    do {
      updatedConfig = { network = network }
      updateConfig(updatedConfig)
    } catch Storage.Error => error {
      next { state | error = "could not set config: network type"}
    }
  }

  get getNetwork : TargetNetwork {
      try {
      state.config.network
    }
  }

  fun setCurrentAddress (address : String) : Void {
    next { state | currentWalletAddress = Maybe.just(address) }
  }

  get getCurrentAddress : Maybe(String) {
    state.currentWalletAddress
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

  fun encodeSender(sender : Sender) : Object {
    Object.Encode.object(
        [Object.Encode.field("address", Object.Encode.string(sender.address)),
        Object.Encode.field("public_key", Object.Encode.string(sender.publicKey)),
        Object.Encode.field("amount", Object.Encode.string(sender.amount)),
        Object.Encode.field("fee", Object.Encode.string(sender.fee)),
        Object.Encode.field("sign_r", Object.Encode.string(sender.signr)),
        Object.Encode.field("sign_s", Object.Encode.string(sender.signs))]
        )
  }

  fun encodeRecipient(r : Recipient) : Object {
    Object.Encode.object(
        [Object.Encode.field("address", Object.Encode.string(r.address)),
        Object.Encode.field("amount", Object.Encode.string(r.amount))]
    )
  }

  fun encodeKajikiSender(sender : Kajiki.Sender) : Object {
    Object.Encode.object(
        [Object.Encode.field("address", Object.Encode.string(sender.address)),
        Object.Encode.field("public_key", Object.Encode.string(sender.publicKey)),
        Object.Encode.field("amount", Object.Encode.number(sender.amount)),
        Object.Encode.field("fee", Object.Encode.number(sender.fee)),
        Object.Encode.field("sign_r", Object.Encode.string(sender.signr)),
        Object.Encode.field("sign_s", Object.Encode.string(sender.signs))]
        )
  }

  fun encodeKajikiRecipient(r : Kajiki.Recipient) : Object {
    Object.Encode.object(
        [Object.Encode.field("address", Object.Encode.string(r.address)),
        Object.Encode.field("amount", Object.Encode.number(r.amount))]
    )
  }

  fun encodeSenders(senders : Array(Sender)) : Array(Object) {
    senders |> Array.map(encodeSender)
  }

  fun encodeKajikiSenders(senders : Array(Kajiki.Sender)) : Array(Object) {
    senders |> Array.map(encodeKajikiSender)
  }

  fun encodeRecipients(recipients : Array(Recipient)) : Array(Object) {
    recipients |> Array.map(encodeRecipient)
  }

  fun encodeKajikiRecipients(recipients : Array(Kajiki.Recipient)) : Array(Object) {
    recipients |> Array.map(encodeKajikiRecipient)
  }

  fun getTransaction(transaction : Transaction, signed : Bool) : Void {
    do {

       senders = if(signed){
         encodeKajikiSenders(transaction.senders |> Array.map(Common.toKajikiSender))
       } else {
         encodeSenders(transaction.senders)
       }

      recipients = if(signed){
          encodeKajikiRecipients(transaction.recipients |> Array.map(Common.toKajikiRecipient))
        } else {
          encodeRecipients(transaction.recipients)
        }



      encoded = Object.Encode.object(
           [Object.Encode.field("id",Object.Encode.string(transaction.id)),
           Object.Encode.field("action",Object.Encode.string(transaction.action)),
           Object.Encode.field("senders", Object.Encode.array(senders)),
           Object.Encode.field("recipients",Object.Encode.array(recipients)),
           Object.Encode.field("message",Object.Encode.string(transaction.message)),
           Object.Encode.field("token",Object.Encode.string(transaction.token)),
           Object.Encode.field("prev_hash",Object.Encode.string(transaction.prevHash)),
           Object.Encode.field("timestamp",Object.Encode.number(transaction.timestamp)),
           Object.Encode.field("scaled",Object.Encode.number(transaction.scaled))]
           )

      jsonTransaction = if(signed){
          Object.Encode.object([Object.Encode.field("transaction", encoded)])
        } else {
          encoded
        }

      url = if(signed){
         "/api/v1/transaction"
      } else {
         "/api/v1/transaction/unsigned"
      }

      response =
      Http.post(getNetwork.url + url)
      |> Http.stringBody(Common.compactJson(Json.stringify(jsonTransaction)))
      |> Http.send()

      json =
        Json.parse(response.body)
        |> Maybe.toResult("Json parsing error")


      item =
        decode json as TransactionResponse

      txn =
        item.result

      next { state | transaction1 = Maybe.just(txn) }
    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
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

      item =
        decode json as AddressTransactionsResponse

      next { state | currentTransactions = item.result }
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

      balances =
        item.result.pairs

      wallet =
        wallets
        |> Array.find(
          \w : EncryptedWalletWithName => w.address == currentWalletAddressOrFirst)
        |> Maybe.withDefault(emptyEncryptedWalletWithName)

      cw =
        {
          wallet = wallet,
          balances = balances
        }

      next { state | currentWallet = Maybe.just(cw) }
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

      next { state | walletItems = replaceItem(walletInfo) }
    } catch Http.ErrorResponse => error {
      next { state | error = "Could not retrieve remote wallet information" }
    } catch String => error {
      next { state | error = "Could not parse json response" }
    } catch Object.Error => error {
      next { state | error = "could not decode json" }
    }
  }

  fun replaceItem (w : WalletItem) : Array(WalletItem) {
    try {
      exists =
        Array.find(
          \i : WalletItem => i.address == w.address,
          state.walletItems)

      if (Maybe.isJust(exists)) {
        Array.map(
          \i : WalletItem =>
            if (i.address == w.address) {
              w
            } else {
              i
            },
          state.walletItems)
      } else {
        Array.push(w, state.walletItems)
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
        |> Array.map(\ew : EncryptedWalletWithName => encode ew)

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

  fun updateConfig (config : Config) : Result(Storage.Error, Void) {
    try {

      encoded = encode config

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

      next { state | config = config }
    } catch Object.Error => error {
      void
    } catch String => error {
      void
    } catch Storage.Error => error {
      void
    }
  }
}
