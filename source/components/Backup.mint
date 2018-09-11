component Backup {

  connect WalletStore exposing { currentWallet }

  fun downloadWallet(event : Html.Event) : Promise(Never, Void) {
    sequence {
      walletWithName = currentWallet
      |> Maybe.map((cw : CurrentWallet) : EncryptedWalletWithName => { cw.wallet } )
      |> Maybe.toResult("")

      wallet = Common.walletWithNametoWallet(walletWithName)
      walletJson = Json.stringify(encode wallet)
      name = (walletWithName.name
              |> String.split(" ")
              |> String.join("-")) + ".json"

      `saveAs(new Blob([walletJson], {type: "application/json;charset=utf-8"}), name);`
    } catch String => error {
      Promise.never()
    }
  }

  fun render : Html {
    <div class="card border-dark mb-3">
      <div class="card-header">
        <{ Common.getCurrentWalletName(currentWallet) }>
      </div>

      <div class="card-body">
        <h4 class="card-title">
          <{ "Backup" }>
        </h4>
        <hr/>
        <h5><{"Download the encrypted wallet"}></h5>
        <button onClick={downloadWallet} class="btn btn-primary"><{"Download"}></button>


      </div>
    </div>
  }
}
