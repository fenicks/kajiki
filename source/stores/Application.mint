store Application {
  property page : String = ""

  fun setPage (page : String) : Void {
    do {
      Http.abortAll()
      next { state | page = page }
    }
  }


}
