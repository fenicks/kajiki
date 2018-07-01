component MyWallets {
  property wallets : Array(EncryptedWalletWithName) = []


fun renderWallet(wallet : EncryptedWalletWithName) : Html {
  <a href="#" class="list-group-item list-group-item-action">
    <div>
    <strong><{wallet.name}></strong><br/>
    <span><i class="fas fa-dollar-sign text-muted"></i><{" 0.1234"}></span>
    </div>
  </a>
}

 fun render : Html {
   <div class="card mb-3">
  <h4 class="card-header"><{"My Wallets"}></h4>

  <ul class="list-group list-group-flush">
  <{
    wallets
    |> Array.map(renderWallet)
    }>
      <a href="/add-wallet" class="list-group-item list-group-item-action"><{"Add wallet"}></a>
  </ul>
  <div class="card-footer text-muted">
    <{"2 days"}>
  </div>
</div>

 }

}
