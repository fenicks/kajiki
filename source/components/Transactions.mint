record GroupedTransaction {
  date : String,
  transactions : Array(KajikiTransaction)
}

component Transactions {
   connect WalletStore exposing { currentWallet, currentTransactions }

  fun aggregateTransactions (transactions : Array(KajikiTransaction)) : Array(GroupedTransaction) {
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

  fun sum(f : Function(a,a,b), array: Array(a)) : b {
     if(Array.isEmpty(array)){
       0
     } else {
     `array.reduce(f)`
     }
  }

  fun render : Html {
    <div>
     <{ transactions
        |> Array.map(renderTransactionGroup)
       }>
    </div>
  } where {
    transactions = aggregateTransactions(currentTransactions)
  }

  fun renderTransactionGroup (group : GroupedTransaction) : Html {
   <div>
   <{ group.date }>
   <{ group.transactions
      |> Array.map(renderTransaction)
     }>
   </div>
  }

  fun renderTransaction (transaction : KajikiTransaction) : Html {
    <div>
      <div class="card">
        <div class="card-body">
          <h4 class="card-title">
            <i class="fas fa-download"></i><{ " Received " + amount + " " + transaction.token}>
          </h4>

          <h6 class="card-subtitle mb-2 text-muted">
            <{ dateTime }>
          </h6>
        </div>
      </div>

      <br/>
    </div>
  } where {
    amount = getTransactionAmountForAddress(transaction)
    dateTime = getDateTimeForTransaction(transaction)
  }

  fun getTransactionAmountForAddress(transaction : KajikiTransaction) : String {
    try{
      address = currentWallet
                |> Maybe.map((w : CurrentWallet) : String => { w.wallet.address} )
                |> Maybe.withDefault("")

      total = transaction.recipients
                   |> Array.select((r : KajikiRecipient) : Bool => { r.address == address })
                   |> Array.map((r : KajikiRecipient) : Number => { r.amount })
                   |> sum((a : Number, b : Number) : Number => { a + b })

      Number.toString(total / 100000000)
    }
  }

  fun getDateTimeForTransaction(transaction: KajikiTransaction) : String {
     try {
       millis = (transaction.timestamp * 1000)
       `new Date(millis).toString()`
    }
  }

}
