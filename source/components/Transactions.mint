record GroupedTransaction {
  date : String,
  transactions : Array(Kajiki.Transaction)
}

component Transactions {
   connect WalletStore exposing { currentWallet, currentTransactions }

  fun aggregateTransactions (transactions : Array(Kajiki.Transaction)) : Array(GroupedTransaction) {
    `
    (() => {
      var result = [];
      transactions.forEach(function (hash) {
        return function (a) {
         var dt = new Date(a.timestamp*1000).toDateString()
         if (!hash[dt]) {
            hash[dt] = new Record({ date: dt, transactions: []});
            result.push(hash[dt]);
         }
        var t = a
        t.recipients = t.recipients.map(function (r){ return new Record(r)});
        hash[dt].transactions.push(new Record(t));
        };
      }(Object.create(null)));
      return result;
    })()
    `
  }

  fun render : Html {
    <div>
     <{ transactions
        |> Array.map(renderTransactionGroup)
       }>
    </div>
  } where {
    transactions = Debug.log(aggregateTransactions(currentTransactions))
  }

  fun renderTransactionGroup (group : GroupedTransaction) : Html {
   <div>
   <{ group.date }>
   <{ group.transactions
      |> Array.map(renderTransaction)
     }>
   </div>
  }

  fun renderTransaction (transaction : Kajiki.Transaction) : Html {
    <div>
      <div class="card">
        <div class="card-body">
          <h4 class="card-title">
            <i class="fas fa-download"></i><{ transaction.id }>
          </h4>

          <h6 class="card-subtitle mb-2 text-muted">
            <{ "more info" }>
          </h6>
        </div>
      </div>

      <br/>
    </div>
  } where {
    a = Debug.log(getTransactionAmountForAddress(transaction))
  }

  fun getTransactionAmountForAddress(transaction : Kajiki.Transaction) : String {
    try{
      address = currentWallet
                |> Maybe.map(\w : CurrentWallet => w.wallet.address)
                |> Maybe.withDefault("")

      recipients = transaction.recipients
                   |> Array.select(\r : Kajiki.Recipient => r.address == address)
                   |> Array.map(\r : Kajiki.Recipient => r.amount)

      "200.98"               

    }
  }

}
