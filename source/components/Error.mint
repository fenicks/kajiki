component Error {
  connect WalletStore exposing { getError, clearError }

  property dismissable : Bool = false

  fun render : Html {
    if(String.isEmpty(getError())){
     <span/>
    } else {
    <div class="alert alert-dismissible alert-danger">
     <{
       if(dismissable) {
         dismissButton
       } else {
         <span/>
       }
     }>
     <p><{getError()}></p>
   </div>
   }
  }

  get dismissButton : Html {
    <button onClick={\e : Html.Event => clearError()} type="button" class="close" data-dismiss="alert"><{"x"}></button>
  }
}
