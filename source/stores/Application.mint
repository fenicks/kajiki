store Application {
  state page : String = ""

  fun setPage (page : String) : Void {
    do {
      Http.abortAll()
      next { page = page }
    }
  }


}
