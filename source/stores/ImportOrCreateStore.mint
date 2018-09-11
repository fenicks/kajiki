store ImportOrCreate {

  state readyToImport : Bool = false

  fun setReadyToImport(v : Bool) : Promise(Never, Void) {
    next { readyToImport = v}
  }

}
