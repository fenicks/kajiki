store WalletStore {
  property wallets : Array(EncryptedWalletWithName) = []

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
