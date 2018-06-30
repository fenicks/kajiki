component MyWallets {
  property wallets : Array(EncryptedWallet) = []

fun renderWallet(wallet : EncryptedWallet) : Html {
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
