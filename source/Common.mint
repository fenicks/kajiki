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

   fun toKajikiRecipient(r : Recipient) : Kajiki.Recipient {
     {address = r.address,
      amount = Number.fromString(r.amount) |> Maybe.withDefault(0)
     }
   }


   fun toKajikiSender(s : Sender) : Kajiki.Sender {
    {address = s.address,
      publicKey = s.publicKey,
      amount = Number.fromString(s.amount) |> Maybe.withDefault(0),
      fee = Number.fromString(s.fee) |> Maybe.withDefault(0),
      signr = s.signr,
      signs = s.signs
    }
   }

 fun toSender(s : Kajiki.Sender) : Sender {
  {address = s.address,
    publicKey = s.publicKey,
    amount = Number.toString(s.amount),
    fee = Number.toString(s.fee),
    signr = s.signr,
    signs = s.signs
  }
 }

 fun toRecipient(r : Kajiki.Recipient) : Recipient {
   {address = r.address,
    amount = Number.toString(r.amount)
   }
 }

 fun kajikiTransactionToTransaction(kt : Kajiki.Transaction) : Transaction {
   try{
    getSenders = kt.senders
              |> Array.map(toSender)

    getRecipients = kt.recipients
                     |> Array.map(toRecipient)
   {
 id = kt.id,
 action = kt.action,
 senders = getSenders,
 recipients = getRecipients,
 message = kt.message,
 token = kt.token,
 prevHash = kt.prevHash,
 timestamp = kt.timestamp,
 scaled = kt.scaled
 }
 }
}

}
