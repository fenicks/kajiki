record ImportUnencrypted.State {
  file : Maybe(File),
  contents : String,
  error : String,
  wallet : Maybe(Wallet)
}

component ImportUnencryptedWallet {
  connect WalletStore exposing { currentWallet, storeWallet }
  connect ImportOrCreate exposing { setReadyToImport, readyToImport }

  state : ImportUnencrypted.State {
    file = Maybe.nothing(),
    contents = "",
    error = "",
    wallet = Maybe.nothing()
  }

  style mx {
    max-width: 20rem;
  }

  fun openDialog : Void {
    do {
      file =
        File.select("application/json")

      contents =
        File.readAsString(file)

      next
        { state |
          contents = contents,
          file = Maybe.just(file)
        }

      p1 =
        [setReadyToImport(true)]

      `Promise.all(p1)`

      json =
        Json.parse(state.contents)

       Debug.log(json)

      decoded =
        json
        |> Maybe.toResult("could not decode imported json wallet")
        |> Result.map(\o : Object => decode o as Wallet)

      wallet =
        decoded

      next { state | wallet = Maybe.just(wallet) }
    } catch String => error {
      next { state | error = error }
    } catch Object.Error => error {
      next { state | error = "This is not a valid unencrypted wallet file!" }
    }
  }

  get showError : Html {
    if (String.isEmpty(state.error)) {
      <span/>
    } else {
      <div class="alert alert-danger">
        <{ state.error }>
      </div>
    }
  }

  get renderUploadFile : Html {
    <div>
      <p>
        <{ "Please choose an unencrypted json wallet to import." }>
      </p>

      <button
        class="btn btn-info"
        onClick={\event : Html.Event => openDialog()}>

        <{ "Upload an unencrypted wallet" }>

      </button>
    </div>
  }

  get renderCompleteImport : Html {
    <div>
      <{ "File uploaded ok" }>
    </div>
  }

  fun render : Html {
    <div>
      <br/>

      <div::mx class="card border-dark mb-3">
        <div class="card-header">
          <{ "Import an unencrypted wallet" }>
        </div>

        <div class="card-body">
          <{ showError }>

          <{
            if (readyToImport) {
              <CreateEncryptedWallet
                title="Import unencrypted wallet"
                cancelUrl="/import-wallet"
                importOnly={true}
                importedWallet={state.wallet}/>
            } else {
              renderUploadFile
            }
          }>
        </div>
      </div>
    </div>
  }
}
