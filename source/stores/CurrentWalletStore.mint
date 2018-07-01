store CurrentWalletStore {
  property currentWallet : Maybe(String) = Maybe.nothing()

  fun setCurrent(wallet : String) : Void {
    next {state | currentWallet = Maybe.just(wallet)}
  }

  fun getCurrent : Maybe(String) {
    state.currentWallet
  }
}
