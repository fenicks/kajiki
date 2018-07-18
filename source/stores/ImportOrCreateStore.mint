store ImportOrCreate {

  property readyToImport : Bool = false

  fun setReadyToImport(v : Bool) : Void {
    next { state | readyToImport = v}
  }

}
