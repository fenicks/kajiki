component ImportUnencryptedWallet {
  connect WalletStore exposing { currentWallet, storeWallet }
  connect ImportOrCreate exposing { setReadyToImport, readyToImport }

  state file : Maybe(File) = Maybe.nothing()
  state contents : String = ""
  state error : String = ""
  state wallet : Maybe(Wallet) = Maybe.nothing()

  fun componentDidMount() : Void {
    setReadyToImport(false)
  }

  fun openDialog : Void {
    do {
      file =
        File.select("application/json")

      contents =
        File.readAsString(file)

      next
        { contents = contents,
          file = Maybe.just(file)
        }

      p1 =
        [setReadyToImport(true)]

      `Promise.all(p1)`

      json =
        Json.parse(contents)

       Debug.log(json)

      decoded =
        json
        |> Maybe.toResult("could not decode imported json wallet")
        |> Result.map((o : Object) : Result(Object.Error, Wallet) => { decode o as Wallet })

      wallet =
        decoded

      next { wallet = Maybe.just(wallet), error= "" }
    } catch String => error {
      do {
        next { error = error }
        setReadyToImport(false)
      }
    } catch Object.Error => error {
      do {
      next { error = "This is not a valid unencrypted wallet file!" }
      setReadyToImport(false)
      }
    }
  }

  get showError : Html {
    if (String.isEmpty(error)) {
      <span/>
    } else {
      <div class="alert alert-danger">
        <{ error }>
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
        onClick={(event : Html.Event) : Void => { openDialog() }}>

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

      <div class="card border-dark mb-9">
        <div class="card-header">
          <{ "Import an unencrypted wallet" }>
        </div>

        <div class="card-body">
          <{ showError }>

          <{
            if (readyToImport && error == "") {
              <CreateEncryptedWallet
                title="Import unencrypted wallet"
                cancelUrl="/import-wallet"
                importOnly={true}
                importedWallet={wallet}/>
            } else {
              renderUploadFile
            }
          }>
        </div>
      </div>
    </div>
  }
}
