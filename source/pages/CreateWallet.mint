record State {
  name : String,
  password : String,
  repeatPassword : String
}

component CreateWallet {

  state : State {
    name = "",
    password = "",
    repeatPassword = ""
    }

  style spacer {
    padding-left:10px;
  }

  fun onName(event : Html.Event) : Void {
    next { state | name = Dom.getValue(event.target) }
  }

  fun onPassword(event : Html.Event) : Void {
    next { state | password = Dom.getValue(event.target) }
  }

  fun onRepeatPasssword(event : Html.Event) : Void {
    next { state | repeatPassword = Dom.getValue(event.target) }
  }

  fun createWallet(event : Html.Event) : Void {
    void
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
      <label for="repeatPassword"><{"Repeat password"}></label>
      <input onInput={onRepeatPasssword} type="password" class="form-control" id="repeatPassword" placeholder="Repeat password"/>
    </div>
     <button type="submit" class="btn btn-primary" onClick={createWallet}><{"Create"}></button><span::spacer />
     <a class="btn btn-secondary" href="/"><{"Cancel"}></a>
    </fieldset>
    </form>
  }

}
