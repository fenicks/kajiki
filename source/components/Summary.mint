component Summary {
  connect WalletStore exposing { currentWallet, walletItems, getCurrentWallet, currentWalletAddressOrFirst, getCurrentAddress, getCurrentTransactions, currentTransactions }

  fun componentDidUpdate : Void {
    try {
      if (Maybe.isNothing(currentWallet) && !Array.isEmpty(walletItems)) {
        try{
        getCurrentWallet
        getCurrentTransactions
        }
      } else {
        void
      }
    }
  }

  fun render : Html {
    <div>
    <div class="card text-white bg-primary mb-3">
      <div class="card-header">
        <{ name }>
      </div>

      <div class="card-body">
        <{ renderSushiBalance(balances) }>

        <{ renderTokenBalances(balances) }>
      </div>
    </div>

    <{ currentTransactions |> Array.map(renderTransaction)}>



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

  fun renderTransaction(transaction : Transaction) : Html {
    <div class="card">
    <div class="card-body">
    <h4 class="card-title"><{"Card Title"}></h4>
    <h6 class="card-subtitle mb-2 text-muted"><{"more info"}></h6>
    </div>
    </div>
  }

  fun renderTokenBalances(balances : Array(TokenPair)) : Html {
   if(Array.isEmpty(tokenBalances)){
        <p class="card-text"><{"You have no custom tokens"}></p>
   } else {
    <p class="card-text">
      <br/>

      <table class="table table-hover">
        <thead>
          <tr>
            <th scope="col">
              <{ "Token" }>
            </th>

            <th scope="col">
              <{ "Balance" }>
            </th>
          </tr>
        </thead>

        <tbody>
          <{ renderBalances(balances) }>
        </tbody>
      </table>
    </p>
  }
  } where {
   tokenBalances = balances
   |> Array.reject(\i : TokenPair => i.token == "SUSHI")
  }

  fun renderBalances (pairs : Array(TokenPair)) : Array(Html) {
    pairs
    |> Array.reject(\i : TokenPair => i.token == "SUSHI")
    |> Array.map(renderBalance)
  }

  fun renderBalance (pair : TokenPair) : Html {
    <tr class="table-default">
      <th scope="row">
        <{ pair.token }>
      </th>

      <td>
        <{ toBalance(pair.amount) }>
      </td>
    </tr>
  }

  fun toBalance(value : String) : String {
   Number.toString((Number.fromString(value) |> Maybe.withDefault(0)) / 100000000)
  }

  fun renderSushiBalance (pairs : Array(TokenPair)) : Html {
    <h4 class="card-title">
      <{ balance.amount }>

      <span class="text-muted">
        <{ " (SUSHI)" }>
      </span>
    </h4>
  } where {
    balance =
      pairs
      |> Array.select(\i : TokenPair => i.token == "SUSHI")
      |> Array.firstWithDefault({
        token = "SUSHI",
        amount = "0"
      })
  }
}
