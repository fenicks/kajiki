record ImportEncrypted.State {
  file : Maybe(File),
  contents : String,
  error : String
}

component ImportEncryptedWallet {
  connect WalletStore exposing { currentWallet, storeWallet }

  state : ImportEncrypted.State {
    file = Maybe.nothing(),
    contents = "",
    error = ""
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

      json =
        Json.parse(state.contents)

      decoded =
        json
        |> Maybe.toResult("could not decode imported json wallet")
        |> Result.map(\o : Object => decode o as EncryptedWallet)

      encryptedWallet =
        decoded

      fileInfo =
        state.file
        |> Maybe.toResult("cannot get uploaded file name")

      fileName =
        File.name(fileInfo)
        |> String.split("-")
        |> String.join(" ")
        |> String.split(".")
        |> Array.firstWithDefault("unknown")

      walletWithName =
        Common.walletToWalletWithName(encryptedWallet, fileName)

      if (walletWithName.source == "kajiki") {
        do {
          storeWallet(walletWithName)
          next { state | error = "" }
          Window.navigate("/dashboard")
        }
      } else {
        next
          { state |
            error =
              "This wallet is from the Sushi client and cannot be uploa" \
              "ded. If you want to upload this wallet you must first de" \
              "crypt it with the Sushi client and then use the import u" \
              "nencrypted wallet option"
          }
      }
    } catch String => error {
      next { state | error = error }
    } catch Object.Error => error {
      next { state | error = "This is not a valid Kajiki encrypted wallet file!" }
    }
  }

  get showError : Html {
    if(String.isEmpty(state.error)){
      <span/>
    } else {
      <div class="alert alert-danger">
        <{ state.error }>
      </div>
    }
  }

  fun render : Html {
    <div>
      <br/>

      <div class="card border-dark mb-9">
        <div class="card-header">
          <{ "Import a Kajiki encrypted wallet" }>
        </div>

        <div class="card-body">

          <{showError}>

          <p>
            <{ "Please choose a Kajiki encrypted json wallet to import." }>
          </p>

          <button
            class="btn btn-info"
            onClick={\event : Html.Event => openDialog()}>

            <{ "Upload an encrypted wallet" }>

          </button>
        </div>
      </div>
    </div>
  }
}
