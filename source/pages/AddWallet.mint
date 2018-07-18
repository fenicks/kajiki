component AddWallet {
  style mx {
    max-width: 20rem;
  }

  fun render : Html {
    <div>
      <br/>

      <div::mx class="card border-primary mb-3">
        <div class="card-header">
          <{ "Create or Import a wallet" }>
        </div>

        <div class="card-body">
          <a
            class="btn btn-primary"
            href="/create-wallet">

            <{ "Create wallet" }>

          </a>

          <span>
            <{ " or " }>
          </span>

          <a
            class="btn btn-info"
            href="/import-wallet">

            <{ "Import wallet" }>

          </a>
        </div>
      </div>
    </div>
  }
}
