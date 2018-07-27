component Error {
  connect WalletStore exposing { getError, clearError }

  fun render : Html {
    if(String.isEmpty(getError())){
     <span/>
    } else {
    <div class="alert alert-dismissible alert-danger">
     <button onClick={\e : Html.Event => clearError()} type="button" class="close" data-dismiss="alert"><{"x"}></button>
     <p><{getError()}></p>
   </div>
   }
  }
}
