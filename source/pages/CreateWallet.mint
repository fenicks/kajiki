record State {
  name : String,
  password : String,
  repeatPassword : String,
  passwordStrength : Maybe(Result(PasswordStrength.Error, PasswordStrength))
}

record PasswordStrength {
  score : Number,
  warning : String,
  suggestion : String
}

enum PasswordStrength.Error {
  PasswordStrengthError
}

component CreateWallet {

  state : State {
    name = "",
    password = "",
    repeatPassword = "",
    passwordStrength = Maybe.nothing()
    }

  style spacer {
    padding-left:10px;
  }

  style height {
    margin-top: 5px;
  }

  fun onName(event : Html.Event) : Void {
    next { state | name = Dom.getValue(event.target) }
  }

  fun getPasswordStrength(password : String) : Result(PasswordStrength.Error, PasswordStrength) {
    `
    (() => {
      try {
        var result = zxcvbn(password);
        return new Ok(new Record({score: result.score, result.feedback.warning, result.feedback.suggestion}))
      } catch (e) {
        return new Err($PasswordStrength_Error_PasswordStrengthError)
      }
    })()
    `
  }

  fun onPassword(event : Html.Event) : Void {
    do {
      password = Dom.getValue(event.target)
      next { state | password = password, passwordStrength = Maybe.just(getPasswordStrength(password)) }
    }
  }

  fun onRepeatPasssword(event : Html.Event) : Void {
    next { state | repeatPassword = Dom.getValue(event.target) }
  }

  fun createWallet(event : Html.Event) : Void {
    void
  }

  get showPasswordStrength : Html {
    try {
      strength = state.passwordStrength
      score = Number.toString(strength.score)
      warning = strength.warning
      suggestion = strength.suggestion

      if(Result.isOk(state.passwordStrength)){
        <div/>
      } else {
        <div::height>
        <div class="alert alert-danger">
         <{"strength: " + score}>
        </div>
        </div>
      }
    }
  }

  fun render : Html {
    <form>
    <fieldset>
    <legend><{"Create a wallet"}></legend>

    <div class="form-group">
      <label for="exampleInputEmail1"><{"Wallet name"}></label>
      <input onInput={onName} type="text" class="form-control" id="walletName" aria-describedby="walletName" placeholder="Enter a name for this wallet"/>
    </div>
    <div class="form-group">
      <label for="password"><{"Password"}></label>
      <input onInput={onPassword} type="password" class="form-control" id="password" placeholder="Password"/>
      <{ showPasswordStrength }>

      <label for="repeatPassword"><{"Repeat password"}></label>
      <input onInput={onRepeatPasssword} type="password" class="form-control" id="repeatPassword" placeholder="Repeat password"/>
    </div>
     <button type="submit" class="btn btn-primary" onClick={createWallet}><{"Create"}></button><span::spacer />
     <a class="btn btn-secondary" href="/"><{"Cancel"}></a>
    </fieldset>
    </form>
  }

}
