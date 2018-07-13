record Send.State {
  amount : String,
  fee : String,
  address : String,
  password : String,
  showingConfirmation : Bool,
  error : String
}

component Send {
  connect WalletStore exposing { currentWallet, currentTransactions, getTransaction, transaction1, error }

  state : Send.State { amount = "", fee = "0.0001", address="", password="", showingConfirmation=false, error=""}

  fun onAmount (event : Html.Event) : Void {
    next { state | amount = Dom.getValue(event.target) }
  }

  fun onFee (event : Html.Event) : Void {
    next { state | fee = Dom.getValue(event.target) }
  }

  fun onAddress (event : Html.Event) : Void {
    next { state | address = Dom.getValue(event.target) }
  }

  fun onPassword (event : Html.Event) : Void {
    next { state | password = Dom.getValue(event.target) }
  }

  fun showConfirmation(event : Html.Event) : Void {
    next { state | showingConfirmation = true }
  }

  fun makeTransaction(event : Html.Event) : Void {
    do {

      Debug.log("HERE we go")

      senderWalletWithName = currentWallet
                     |> Maybe.toResult("Error getting sender wallet!")

      senderWallet = Common.walletWithNametoWallet(senderWalletWithName.wallet)
      decryptedWallet = Sushi.Wallet.decryptWallet(senderWallet, state.password)

      txn = {
    id = "",
    action = "send",
    senders = [
      {
        address = senderWallet.address,
        publicKey = decryptedWallet.publicKey,
        amount = state.amount,
        fee = state.fee,
        signr = "0",
        signs = "0"
      }
    ],
    recipients = [
      {
        address = state.address,
        amount = state.amount
      }
    ],
    message = "",
    token = "SUSHI",
    prevHash = "0",
    timestamp = 0,
    scaled = 1
    }

    unsignedTransaction = getTransaction(txn, false)

    fullWallet =
            Sushi.Wallet.getFullWalletFromWif(decryptedWallet.wif)

    transactionToSign = transaction1 |> Maybe.toResult("Error - can't get transaction to sign")

    signedTransaction =
                Sushi.Wallet.signTransaction(
                  fullWallet.privateKey,
                  Common.kajikiTransactionToTransaction(transactionToSign))


    Debug.log(signedTransaction)

    sendSignedTransaction = getTransaction(signedTransaction, true)




  } catch String => error {
    next { state | error = error }
  } catch Wallet.Error => error {
    case (error) {
     Wallet.Error::InvalidNetwork => next { state | error = "There was a wallet error: InvalidNetwork" }
     Wallet.Error::WalletGenerationError => next { state | error = "There was a wallet error: WalletGenerationError" }
     Wallet.Error::EncryptWalletError => next { state | error = "There was a wallet error: EncryptWalletError" }
     Wallet.Error::DecryptWalletError => next { state | error = "There was a wallet error: DecryptWalletError" }
     Wallet.Error::FromWifWalletError => next { state | error = "There was a wallet error: FromWifWalletError" }
     Wallet.Error::SigningError => next { state | error = "There was a wallet error: SigningError" }
     Wallet.Error::InvalidAddressError => next { state | error = "There was a wallet error: InvalidAddressError" }
     Wallet.Error::AddressLengthError => next { state | error = "There was a wallet error: AddressLengthError" }
     Wallet.Error::MnemonicGenerationError => next { state | error = "There was a wallet error: MnemonicGenerationError" }
   }

  }
 }











  fun render : Html {
    <div class="card border-dark mb-3">
    <div><{state.error}></div>
    <div><{error}></div>
      <div class="card-header">
        <{ Common.getCurrentWalletName(currentWallet) }>
      </div>

      <div class="card-body">
        <h4 class="card-title">
          <{ "Send tokens" }>
        </h4>
         <{
           if (state.showingConfirmation) {
             renderConfirmation
           } else {
             renderSendForm
           }
         }>

      </div>
    </div>
  }

  get renderConfirmation : Html {
    <div>
    <div class="alert alert-primary">
       <h4><{"Transaction summary"}></h4>
       <p><{"You are sending the following:"}></p>
       <table class="table table-hover">
       <tr>
         <th ><{"To address: "}></th>
         <th ><{state.address}></th>
       </tr>
       <tr>
         <th ><{"Amount: "}></th>
         <th ><{asNumber(state.amount)}></th>
       </tr>
       <tr>
         <th ><{"Fee: "}></th>
         <th ><{asNumber(state.fee)}></th>
       </tr>
       <tr>
         <th ><{"Total: "}></th>
         <th ><{calculateTotal()}></th>
       </tr>
       </table>
    </div>

    <button
      onClick={goBack}
      type="submit"
      class="btn btn-outline-primary">
      <{"Cancel"}>
      </button>

    <button
      onClick={makeTransaction}
      type="submit"
      class="btn btn-primary">
      <{"Send"}>
      </button>
    </div>
  }

  fun calculateTotal : String {
     (fee + amount)
     |> Number.toFixed(8)
  } where {
    fee = Number.fromString(state.fee) |> Maybe.withDefault(0)
    amount = Number.fromString(state.amount) |> Maybe.withDefault(0)
  }

  fun goBack(event : Html.Event) : Void {
    next { state | showingConfirmation = false}
  }

  fun asNumber(value : String) : String {
    n |> Number.toFixed(8)
  } where {
    n = Number.fromString(value) |> Maybe.withDefault(0)
  }

  get renderSendForm : Html {
    <fieldset>
      <div class="form-group">
        <label for="amount">
          <{ "Amount" }>
        </label>

        <input
          onInput={onAmount}
          value={state.amount}
          type="text"
          class="form-control"
          id="amount"
          aria-describedby="amount"
          placeholder="Enter an amount"/>
      </div>

      <div class="form-group">
        <label for="fee">
          <{ "Fee" }>
        </label>

        <input
          onInput={onFee}
          type="text"
          class="form-control"
          id="fee"
          aria-describedby="fee"
          value={state.fee}
          placeholder="Enter a fee"/>

        <small
          id="fee"
          class="form-text text-muted">

          <{ "The minimum fee is 0.0001 SUSHI" }>

        </small>
      </div>

      <div class="form-group">
        <label for="address">
          <{ "Address" }>
        </label>

        <input
          onInput={onAddress}
          value={state.address}
          type="text"
          class="form-control"
          id="address"
          aria-describedby="address"
          placeholder="Enter an address"/>
      </div>

      <div class="form-group">
        <label for="password">
          <{ "Password" }>
        </label>

        <input
          onInput={onPassword}
          value={state.password}
          type="password"
          class="form-control"
          id="password"
          aria-describedby="password"
          placeholder="Enter your password"/>
      </div>

      <button
        type="submit"
        class="btn btn-primary"
        onClick={showConfirmation}>
        /* disabled={createButtonState} */


        <{ "Send" }>

      </button>

    </fieldset>
  }
}
