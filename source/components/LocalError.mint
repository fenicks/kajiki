component LocalError {
  property error : String = ""

  fun render : Html {
    if(String.isEmpty(error)){
     <span/>
    } else {
    <div class="alert alert-dismissible alert-danger">
     <p><{error}></p>
   </div>
   }
  }

}
