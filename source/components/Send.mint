component Send {
  connect WalletStore exposing { currentWallet, currentTransactions, getTransaction, transaction1, error }

  state amount : String = ""
  state fee : String = "0.0001"
  state address : String = ""
  state password : String = ""
  state showingConfirmation : Bool = false
  state sendError : String = ""
  state amountError : String = ""

  fun onAmount (event : Html.Event) : Void {
    next { amount = value, amountError = validateAmount(value) }
  } where {
    value = Dom.getValue(event.target)
  }

  fun validateAmount(value : String) : String {
    try {
      amount = Number.fromString(value) |> Maybe.withDefault(0)
      sushi = Common.getCurrentWalletSushiBalance(currentWallet)
      if(sushi <= (amount + 0.0001)){
        "You don't have enough SUSHI to send"
      } else {
        if(amount <= 0){
          "you must supply an amount greater than 0"
        } else {
          ""
        }
      }
    }
  }

  fun onFee (event : Html.Event) : Void {
    next { fee = Dom.getValue(event.target) }
  }

  fun onAddress (event : Html.Event) : Void {
    next { address = Dom.getValue(event.target) }
  }

  fun onPassword (event : Html.Event) : Void {
    next { password = Dom.getValue(event.target) }
  }

  fun showConfirmation(event : Html.Event) : Void {
    next { showingConfirmation = true }
  }

  fun makeTransaction(event : Html.Event) : Void {
    do {

      senderWalletWithName = currentWallet
                     |> Maybe.toResult("Error getting sender wallet!")

      senderWallet = Common.walletWithNametoWallet(senderWalletWithName.wallet)
      decryptedWallet = Sushi.Wallet.decryptWallet(senderWallet,password)

      txn = {
    id = "",
    action = "send",
    senders = [
      {
        address = senderWallet.address,
        publicKey = decryptedWallet.publicKey,
        amount = amount,
        fee = fee,
        signr = "0",
        signs = "0"
      }
    ],
    recipients = [
      {
        address = address,
        amount = amount
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

    sendSignedTransaction = getTransaction(signedTransaction, true)

  } catch String => error {
    next { sendError = error }
  } catch Wallet.Error => error {
    case (error) {
     Wallet.Error::InvalidNetwork => next { sendError = "There was a wallet error: InvalidNetwork" }
     Wallet.Error::WalletGenerationError => next { sendError = "There was a wallet error: WalletGenerationError" }
     Wallet.Error::EncryptWalletError => next {  sendError = "There was a wallet error: EncryptWalletError" }
     Wallet.Error::DecryptWalletError => next {  sendError = "There was a wallet error: DecryptWalletError" }
     Wallet.Error::FromWifWalletError => next {  sendError = "There was a wallet error: FromWifWalletError" }
     Wallet.Error::SigningError => next {  sendError = "There was a wallet error: SigningError" }
     Wallet.Error::InvalidAddressError => next {  sendError = "There was a wallet error: InvalidAddressError" }
     Wallet.Error::AddressLengthError => next {  sendError = "There was a wallet error: AddressLengthError" }
     Wallet.Error::MnemonicGenerationError => next { sendError = "There was a wallet error: MnemonicGenerationError" }
   }

  }
 }

  fun render : Html {
    <div class="card border-dark mb-3">
    <div><{error}></div>
    <div><{sendError}></div>
      <div class="card-header">
        <{ Common.getCurrentWalletName(currentWallet) }>
      </div>

      <div class="card-body">
        <h4 class="card-title">
          <{ "Send tokens" }>
        </h4>
         <{
           if (showingConfirmation) {
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
         <th ><{address}></th>
       </tr>
       <tr>
         <th ><{"Amount: "}></th>
         <th ><{asNumber(amount)}></th>
       </tr>
       <tr>
         <th ><{"Fee: "}></th>
         <th ><{asNumber(fee)}></th>
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
     (theFee + theAmount)
     |> Number.toFixed(8)
  } where {
    theFee = Number.fromString(fee) |> Maybe.withDefault(0)
    theAmount = Number.fromString(amount) |> Maybe.withDefault(0)
  }

  fun goBack(event : Html.Event) : Void {
    next { showingConfirmation = false}
  }

  fun asNumber(value : String) : String {
    n |> Number.toFixed(8)
  } where {
    n = Number.fromString(value) |> Maybe.withDefault(0)
  }

  get createButtonState : Bool {
    (String.isEmpty(amount) || String.isEmpty(password))
  }

  get renderSendForm : Html {
    <fieldset>
      <div class="form-group">
        <label for="amount">
          <{ "Amount" }>
        </label>

        <input
          onInput={onAmount}
          value={amount}
          type="text"
          class="form-control"
          id="amount"
          aria-describedby="amount"
          placeholder="Enter an amount"/>
      <LocalError error={amountError}/>
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
          value={fee}
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
          value={address}
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
          value={password}
          type="password"
          class="form-control"
          id="password"
          aria-describedby="password"
          placeholder="Enter your password"/>
      </div>

      <button
        type="submit"
        class="btn btn-primary"
        onClick={showConfirmation}
        disabled={createButtonState}>

        <{ "Send" }>

      </button>

    </fieldset>
  }
}
