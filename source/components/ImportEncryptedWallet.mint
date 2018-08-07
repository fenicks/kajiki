component ImportEncryptedWallet {
  connect WalletStore exposing { currentWallet, storeWallet }

  state file : Maybe(File) = Maybe.nothing()
  state contents : String = ""
  state error : String = ""

  fun openDialog : Void {
    do {
      theFile =
        File.select("application/json")

      theContents =
        File.readAsString(theFile)

      next
        { contents = theContents,
          file = Maybe.just(theFile)
        }

      json =
        Json.parse(theContents)

      decoded =
        json
        |> Maybe.toResult("could not decode imported json wallet")
        |> Result.map((o : Object) : Result(Object.Error, EncryptedWallet) => { decode o as EncryptedWallet })

      encryptedWallet =
        decoded

      fileInfo =
        file
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
          next { error = "" }
          Window.navigate("/dashboard")
        }
      } else {
        next
          { error =
              "This wallet is from the Sushi client and cannot be uploa" \
              "ded. If you want to upload this wallet you must first de" \
              "crypt it with the Sushi client and then use the import u" \
              "nencrypted wallet option"
          }
      }
    } catch String => error {
      next {  error = error }
    } catch Object.Error => error {
      next {  error = "This is not a valid Kajiki encrypted wallet file!" }
    }
  }

  get showError : Html {
    if(String.isEmpty(error)){
      <span/>
    } else {
      <div class="alert alert-danger">
        <{ error }>
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
            onClick={(event : Html.Event) : Void => {openDialog()}}>

            <{ "Upload an encrypted wallet" }>

          </button>
        </div>
      </div>
    </div>
  }
}
