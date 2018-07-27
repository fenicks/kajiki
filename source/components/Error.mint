component Error {
  connect WalletStore exposing { getError, clearError }

  fun render : Html {
    if(String.isEmpty(getError())){
     <span/>
    } else {
    <div class="alert alert-dismissible alert-danger">
     <button type="button" class="close" data-dismiss="alert"><{"close"}></button>
     <p><{getError()}></p>
   </div>
   }
  }
}
