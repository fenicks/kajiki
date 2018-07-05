component ChooseNetwork {
  connect WalletStore exposing { getWallets, getWalletItems, setNetwork, getNetwork, getConfig, refreshWalletItems, getCurrentWallet, getCurrentTransactions }

  fun onChangeNetwork (event : Html.Event) : Void {
    do {
      setNetwork(network)
      getConfig
      p1 =
        [
          getWallets,
          getWalletItems,

        ]

      `Promise.all(p1)`

      p2 =
        [
          getCurrentWallet,
          getCurrentTransactions
        ]

      `Promise.all(p2)`
    }

  } where {
    network =
      case (Dom.getValue(event.target)) {
        "Testnet" => Target.Network.testNet()
        "Local"   => Target.Network.local()
        => Target.Network.testNet()
      }
  }

  fun render : Html {
    <form class="form-inline my-2 my-lg-0">
      <div class="form-group">
        <select onChange={onChangeNetwork} class="custom-select mr-sm-2">
          <{ options }>
        </select>
      </div>
    </form>
  } where {
    options =
      [
        Target.Network.testNet(),
        Target.Network.local()
      ]
      |> Array.map(renderNetwork)
  }

  fun renderNetwork (net : TargetNetwork) : Html {
    if (net.name == getNetwork.name) {
      <option
        value={net.name}
        selected="true">

        <{ net.name }>

      </option>
    } else {
      <option value={net.name}>
        <{ net.name }>
      </option>
    }
  }
}
