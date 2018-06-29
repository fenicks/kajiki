record State {
  name : String,
  password : String,
  repeatPassword : String,
  passwordStrength : PasswordStrength,
  error : String
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

component CreateWallet {

  state : State {
    name = "",
    password = "",
    repeatPassword = "",
    passwordStrength = {score = -1, warning = "", suggestions = []},
    error = ""
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
        return new Ok(new Record({score: result.score, warning: result.feedback.warning, suggestions: result.feedback.suggestions}))
      } catch (e) {
        return new Err($PasswordStrength_Error_PasswordStrengthError)
      }
    })()
    `
  }

  fun onPassword(event : Html.Event) : Void {
    try {
      password = Dom.getValue(event.target)
      strength = getPasswordStrength(password)

      if(String.isEmpty(password)){
        next { state | password = password, passwordStrength = {score = -1, warning = "", suggestions = []} }
      } else {

        next { state | password = password, passwordStrength = strength }
      }

    } catch PasswordStrength.Error => error {
       next { state | error = "Password strength checking error", passwordStrength = {score = -1, warning = "", suggestions = []}}
    }
  }

  fun onRepeatPasssword(event : Html.Event) : Void {
    next { state | repeatPassword = Dom.getValue(event.target) }
  }

  fun createWallet(event : Html.Event) : Void {
    void
  }

  fun scoreText(score : Number) : ScoreInfo {
    case (score) {
  0 => {text = "Worst", colour = "danger"}
  1 => {text = "Bad", colour = "danger"}
  2 => {text = "Weak", colour = "warning"}
  3 => {text = "Good", colour = "success"}
  4 => {text = "Strong", colour = "success"}
  => {text = "Worst", colour = "danger"}
}
  }

  get showPasswordStrength : Html {
    try {

      strength = state.passwordStrength
      score = Number.toString(strength.score)
      warning = strength.warning
      suggestions = strength.suggestions

      if(strength.score == -1){
        <div/>
      } else {
        <div::height>
        <div class="alert alert-danger">
         <{scoreText(strength.score)}>
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
