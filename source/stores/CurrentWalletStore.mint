store CurrentWalletStore {
  property currentWallet : Maybe(WalletItem) = Maybe.nothing()

  fun setCurrent(wallet : WalletItem) : Void {
    next {state | currentWallet = Maybe.just(wallet)}
  }

  fun getCurrent : Maybe(WalletItem) {
    state.currentWallet
  }
}
