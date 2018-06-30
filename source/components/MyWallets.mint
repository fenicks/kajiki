component MyWallets {
  property wallets : Array(EncryptedWalletWithName) = []

fun renderWallet(wallet : EncryptedWalletWithName) : Html {
  <div><{wallet.name}><span><{" : " + wallet.address}></span></div>
}

 fun render : Html {
   <div>
   <h4><{"My Wallets"}></h4>
   <{
     wallets
     |> Array.map(renderWallet)
     }>
    <a href="/add-wallet"><{"Add wallet"}></a>
   </div>
 }

}
