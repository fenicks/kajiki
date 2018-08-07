store ImportOrCreate {

  state readyToImport : Bool = false

  fun setReadyToImport(v : Bool) : Void {
    next { readyToImport = v}
  }

}
