component Summary {
  connect WalletStore exposing { currentWallet, currentTransactions }

  fun render : Html {
    <div>
      <div class="card text-white bg-primary mb-3">
        <div class="card-header">
          <{ Common.getCurrentWalletName(currentWallet) }>
        </div>

        <div class="card-body">
          <{ renderSushiBalance(balances) }>

          <{ renderTokenBalances(balances) }>
        </div>
      </div>

      <Transactions />

    </div>
  } where {
    balances =
      currentWallet
      |> Maybe.map((c : CurrentWallet) : Array(TokenPair) => { c.balances })
      |> Maybe.withDefault([])
  }

  fun renderTokenBalances (balances : Array(TokenPair)) : Html {
    if (Array.isEmpty(tokenBalances)) {
      <p class="card-text">
        <{ "You have no custom tokens" }>
      </p>
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
    tokenBalances =
      balances
      |> Array.reject((i : TokenPair) : Bool => { (i.token == "SUSHI" || i.amount == "0")})
  }

  fun renderBalances (pairs : Array(TokenPair)) : Array(Html) {
    pairs
    |> Array.reject((i : TokenPair) : Bool => {(i.token == "SUSHI" || i.amount == "0")})
    |> Array.map(renderBalance)
  }

  fun renderBalance (pair : TokenPair) : Html {
    <tr class="table-default">
      <th scope="row">
        <{ pair.token }>
      </th>

      <td>
        <{ pair.amount }>
      </td>
    </tr>
  }

  fun toBalance (value : String) : String {
    Number.toString(
      (Number.fromString(value)
      |> Maybe.withDefault(0)) / 100000000)
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
      |> Array.select((i : TokenPair) : Bool => {i.token == "SUSHI"})
      |> Array.firstWithDefault({
        token = "SUSHI",
        amount = "0"
      })
  }
}
