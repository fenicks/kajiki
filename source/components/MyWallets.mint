component MyWallets {
  property wallets : Array(EncryptedWalletWithName) = []

fun renderWallet(wallet : EncryptedWalletWithName) : Html {
  <div><{wallet.address}></div>
}

 fun render : Html {
   <div>
   <h4><{"My Wallets"}></h4>
   <{
     wallets
     |> Array.map(renderWallet)
     }>
   </div>
 }

}
