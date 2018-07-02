component Summary {
  connect WalletStore exposing { currentWallet, walletItems, getCurrentWallet, currentWalletAddressOrFirst, getCurrentAddress }

  fun componentDidUpdate : Void {
    try {
      if (Maybe.isNothing(currentWallet) && !Array.isEmpty(walletItems)) {
        getCurrentWallet
      } else {
        void
      }
    }
  }

  fun render : Html {
    <div class="card text-white bg-primary mb-3">
      <div class="card-header">
        <{ name }>
      </div>

      <div class="card-body">
        <{ renderSushiBalance(balances) }>


        <p class="card-text">
        <br/>
        <table class="table table-hover">
  <thead>
    <tr>
      <th scope="col"><{"Token"}></th>
      <th scope="col"><{"Balance"}></th>
    </tr>
  </thead>
  <tbody>
     <{renderBalances(balances)}>
  </tbody>
</table>

        </p>
      </div>
    </div>
  } where {
    name =
      currentWallet
      |> Maybe.map(\c : CurrentWallet => c.wallet.name)
      |> Maybe.withDefault("")

    balances =
      currentWallet
      |> Maybe.map(\c : CurrentWallet => c.balances)
      |> Maybe.withDefault([])
  }

fun renderBalances(pairs : Array(TokenPair)) : Array(Html) {
  pairs
  |> Array.reject(\i : TokenPair => i.token == "SUSHI")
  |> Array.map(renderBalance)
}

fun renderBalance(pair: TokenPair): Html {
  <tr class="table-default">
    <th scope="row"><{pair.token}></th>
    <td><{pair.amount}></td>
  </tr>
}

fun renderSushiBalance(pairs: Array(TokenPair)) : Html {
  <h4 class="card-title"><{balance.amount}><span class="text-muted"><{" (SUSHI)"}></span></h4>

} where {
  balance = pairs
  |> Array.select(\i : TokenPair => i.token == "SUSHI")
  |> Array.firstWithDefault({token = "SUSHI", amount = "0"})
}

}
