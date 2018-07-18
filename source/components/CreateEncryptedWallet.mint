record CreateEncryptedWallet.State {
  name : String,
  password : String,
  repeatPassword : String,
  passwordStrength : PasswordStrength,
  error : String,
  showPassword : Bool,
  showRepeatPassword : Bool
}

record PasswordStrength {
  score : Number,
  warning : String,
  suggestions : Array(String)
}

record ScoreInfo {
  text : String,
  colour : String
}

enum PasswordStrength.Error {
  PasswordStrengthError
}

record EncryptedWalletWithName {
  name : String,
  source : String,
  ciphertext : String,
  address : String,
  salt : String
}

component CreateEncryptedWallet {
  connect WalletStore exposing { storeWallet }
  connect ImportOrCreate exposing { setReadyToImport }

  property title : String = "Create a wallet"
  property cancelUrl : String = "/"
  property importOnly : Bool = false
  property importedWallet : Maybe(Wallet) = Maybe.nothing()

  state : CreateEncryptedWallet.State {
    name = "",
    password = "",
    repeatPassword = "",
    passwordStrength =
      {
        score = -1,
        warning = "",
        suggestions = []
      },
    error = "",
    showPassword = false,
    showRepeatPassword = false
  }

  style spacer {
    padding-left: 10px;
  }

  style height {
    margin-top: 5px;
  }

  style italics {
    font-style: italic;
  }

  style pointer {
    cursor: pointer;
  }

  fun onName (event : Html.Event) : Void {
    next { state | name = Dom.getValue(event.target) }
  }

  fun getPasswordStrength (password : String) : Result(PasswordStrength.Error, PasswordStrength) {
    `
    (() => {
      try {
        var result = zxcvbn(password);
        return new Ok(new Record({score: result.score, warning: result.feedback.warning, suggestions: result.feedback.suggestions}))
      } catch (e) {
        return new Err($PasswordStrength_Error_PasswordStrengthError)
      }
    })()
    `
  }

  fun onPassword (event : Html.Event) : Void {
    try {
      password =
        Dom.getValue(event.target)

      strength =
        getPasswordStrength(password)

      if (String.isEmpty(password)) {
        next
          { state |
            password = password,
            passwordStrength =
              {
                score = -1,
                warning = "",
                suggestions = []
              }
          }
      } else {
        next
          { state |
            password = password,
            passwordStrength = strength
          }
      }
    } catch PasswordStrength.Error => error {
      next
        { state |
          error = "Password strength checking error",
          passwordStrength =
            {
              score = -1,
              warning = "",
              suggestions = []
            }
        }
    }
  }

  fun onRepeatPasssword (event : Html.Event) : Void {
    next { state | repeatPassword = Dom.getValue(event.target) }
  }

  fun togglePasswordVisibility (event : Html.Event) : Void {
    next { state | showPassword = !state.showPassword }
  }

  fun toggleRepeatPasswordVisibility (event : Html.Event) : Void {
    next { state | showRepeatPassword = !state.showRepeatPassword }
  }

  fun createOrImportWallet (event : Html.Event) : Void {
    if (importOnly) {
      importWallet
    } else {
      createWallet
    }
  }

  fun storeAsEncryptedWithName (wallet : Wallet) : Void {
    do {
      encrypted =
        Sushi.Wallet.encryptWallet(wallet, state.password)

      encryptedWithName =
        {
          name = state.name,
          source = encrypted.source,
          ciphertext = encrypted.ciphertext,
          address = encrypted.address,
          salt = encrypted.salt
        }

      created =
        storeWallet(encryptedWithName)

      Window.navigate("/dashboard")
    } catch Wallet.Error => error {
      next { state | error = "Could not generate a new wallet" }
    } catch Storage.Error => error {
      next { state | error = "Could not store the new wallet" }
    }
  }

  get importWallet : Void {
    try {
      wallet =
        importedWallet
        |> Maybe.toResult("Could not process imported wallet")

      storeAsEncryptedWithName(wallet)
    } catch String => error {
      next { state | error = error }
    }
  }

  get createWallet : Void {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      storeAsEncryptedWithName(wallet)
    } catch Wallet.Error => error {
      next { state | error = "Could not generate a new wallet" }
    }
  }

  fun scoreText (score : Number) : ScoreInfo {
    case (score) {
      0 =>
        {
          text = "Worst",
          colour = "danger"
        }

      1 =>
        {
          text = "Bad",
          colour = "danger"
        }

      2 =>
        {
          text = "Weak",
          colour = "warning"
        }

      3 =>
        {
          text = "Good",
          colour = "success"
        }

      4 =>
        {
          text = "Strong",
          colour = "success"
        }

      =>
        {
          text = "Worst",
          colour = "danger"
        }
    }
  }

  get showPasswordStrength : Html {
    try {
      strength =
        state.passwordStrength

      score =
        Number.toString(strength.score)

      warning =
        strength.warning

      suggestions =
        String.join(" , ", strength.suggestions)

      rating =
        scoreText(strength.score)

      if (strength.score == -1) {
        <div/>
      } else {
        <div::height>
          <div class={"alert alert-" + rating.colour}>
            <span>
              <{ "Strength: " }>
            </span>

            <strong>
              <{ rating.text + " " }>
            </strong>

            <span::italics>
              <{ warning }>
            </span>

            <span::italics>
              <{ " " + suggestions }>
            </span>
          </div>
        </div>
      }
    }
  }

  get passwordsNotMatchingAlert : Html {
    if (String.isEmpty(state.password) && String.isEmpty(state.repeatPassword)) {
      <div/>
    } else {
      if (state.password == state.repeatPassword) {
        <div/>
      } else {
        if (String.isEmpty(state.repeatPassword) || String.isEmpty(state.password)) {
          <div/>
        } else {
          <div::height>
            <div class="alert alert-danger">
              <{
                "The password and repeat password you entered do not matc" \
                "h"
              }>
            </div>
          </div>
        }
      }
    }
  }

  get createButtonState : Bool {
    (String.isEmpty(state.name) || String.isEmpty(state.password) || String.isEmpty(state.repeatPassword)) || (state.password != state.repeatPassword)
  }

  fun checkMark (colour : String, icon : String) : Html {
    <div class="input-group-prepend">
      <span
        class="input-group-text"
        id="basic-addon3">

        <i class={"fas fa-" + icon + " text-" + colour}/>

      </span>
    </div>
  }

  get checkIndicator : Html {
    if (String.isEmpty(state.password) && String.isEmpty(state.repeatPassword)) {
      <div/>
    } else {
      if (state.password == state.repeatPassword) {
        checkMark("success", "check")
      } else {
        if (String.isEmpty(state.repeatPassword) || String.isEmpty(state.password)) {
          <div/>
        } else {
          checkMark("danger", "times")
        }
      }
    }
  }

  get passwordType : String {
    if (state.showPassword) {
      "text"
    } else {
      "password"
    }
  }

  get repeatPasswordType : String {
    if (state.showRepeatPassword) {
      "text"
    } else {
      "password"
    }
  }

  get passwordEye : String {
    if (state.showPassword) {
      "eye-slash"
    } else {
      "eye"
    }
  }

  get repeatPasswordEye : String {
    if (state.showRepeatPassword) {
      "eye-slash"
    } else {
      "eye"
    }
  }

  fun cancel (event : Html.Event) : Void {
    do {
      setReadyToImport(false)
      Window.navigate(cancelUrl)
    }
  }

  fun render : Html {
    <div>
      <fieldset>
        <legend>
          <{ title }>
        </legend>

        <div class="form-group">
          <label for="exampleInputEmail1">
            <{ "Wallet name" }>
          </label>

          <input
            onInput={onName}
            type="text"
            class="form-control"
            id="walletName"
            aria-describedby="walletName"
            maxLength="100"
            placeholder="Enter a name for this wallet"/>
        </div>

        <div class="form-group">
          <label for="password">
            <{ "Password" }>
          </label>

          <div class="input-group mb-3">
            <{ checkIndicator }>

            <input
              onInput={onPassword}
              type={passwordType}
              class="form-control"
              id="password"
              placeholder="Password"
              maxLength="100"
              aria-describedby="basic-addon2"/>

            <div class="input-group-append">
              <span
                class="input-group-text"
                id="basic-addon2">

                <span::pointer>
                  <i
                    onClick={togglePasswordVisibility}
                    class={"fas fa-" + passwordEye}/>
                </span>

              </span>
            </div>
          </div>

          <{ showPasswordStrength }>
        </div>

        <div class="form-group">
          <label for="password">
            <{ "Repeat Password" }>
          </label>

          <div class="input-group mb-3">
            <{ checkIndicator }>

            <input
              onInput={onRepeatPasssword}
              type={repeatPasswordType}
              class="form-control"
              id="repeatPassword"
              placeholder="Repeat password"
              maxLength="100"
              aria-describedby="basic-addon2"/>

            <div class="input-group-append">
              <span
                class="input-group-text"
                id="basic-addon2">

                <span::pointer>
                  <i
                    onClick={toggleRepeatPasswordVisibility}
                    class={"fas fa-" + repeatPasswordEye}/>
                </span>

              </span>
            </div>
          </div>

          <{ passwordsNotMatchingAlert }>
        </div>

        <button
          onClick={cancel}
          class="btn btn-outline-primary">

          <{ "Cancel" }>

        </button>

        <span::spacer/>

        <button
          type="submit"
          class="btn btn-primary"
          onClick={createOrImportWallet}
          disabled={createButtonState}>

          <{ "Create" }>

        </button>
      </fieldset>
    </div>
  }
}