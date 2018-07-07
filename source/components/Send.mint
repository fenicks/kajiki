record Send.State {
  amount : String,
  fee : String,
  address : String,
  password : String
}

component Send {
  connect WalletStore exposing { currentWallet, currentTransactions }

  state : Send.State { amount = "", fee = "", address="", password=""}

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

  fun render : Html {
    <div class="card border-dark mb-3">
      <div class="card-header">
        <{ Common.getCurrentWalletName(currentWallet) }>
      </div>

      <div class="card-body">
        <h4 class="card-title">
          <{ "Send tokens" }>
        </h4>

        <fieldset>
          <div class="form-group">
            <label for="amount">
              <{ "Amount" }>
            </label>

            <input
              onInput={onAmount}
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
              placeholder="Enter a fee"/>

            <small
              id="fee"
              class="form-text text-muted">

              <{ "The minimum fee is 0.001 SUSHI" }>

            </small>
          </div>

          <div class="form-group">
            <label for="address">
              <{ "Address" }>
            </label>

            <input
              onInput={onAddress}
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
              type="password"
              class="form-control"
              id="password"
              aria-describedby="password"
              placeholder="Enter your password"/>
          </div>

          <button
            type="submit"
            class="btn btn-primary">
            /* onClick={createWallet}
            disabled={createButtonState} */


            <{ "Send" }>

          </button>

        </fieldset>
      </div>
    </div>
  }
}
