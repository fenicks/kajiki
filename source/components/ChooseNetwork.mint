component ChooseNetwork {
  connect WalletStore exposing { setNetwork, getNetwork }

  fun onChangeNetwork (event : Html.Event) : Void {
    setNetwork(network)
  } where {
    network =
      case (Dom.getValue(event.target)) {
        "1" => Target.Network.testNet()
        "2" => Target.Network.local()
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
    if (net == getNetwork) {
      <option
        value={net.name}
        selected="">

        <{ net.name }>

      </option>
    } else {
      <option value={net.name}>
        <{ net.name }>
      </option>
    }
  }
}
