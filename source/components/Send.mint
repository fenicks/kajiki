component Send {
  connect WalletStore exposing { currentWallet, currentTransactions }

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
              type="text"
              class="form-control"
              id="address"
              aria-describedby="address"
              placeholder="Enter an address"/>
          </div>

        </fieldset>
      </div>
    </div>
  }
}
