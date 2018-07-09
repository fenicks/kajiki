module Common {

 fun getCurrentWalletName(currentWallet : Maybe(CurrentWallet)) : String {
     currentWallet
     |> Maybe.map(\c : CurrentWallet => c.wallet.name)
     |> Maybe.withDefault("")
 }

 fun compactJson(value : String) : String {
  `JSON.stringify(JSON.parse(value), null, 0);`
 }

 fun walletWithNametoWallet(w : EncryptedWalletWithName) : EncryptedWallet {
   {source = w.source,
    ciphertext = w.ciphertext,
    address = w.address,
    salt = w.salt}
   }

}
