component Receive {

  connect WalletStore exposing { currentWallet }

  fun copyAddress(event : Html.Event) : Void {
    `
    (() => {
      var copyText = document.getElementById("my-address");
      copyText.select();
      document.execCommand("copy");
    })()
    `
  }

  fun generateQrCode(address : String) : String {
    `new QRious({value: address, size: 150}).toDataURL();`
  }

  fun render : Html {
    <div class="card border-dark mb-3">
      <div class="card-header">
        <{ Common.getCurrentWalletName(currentWallet) }>
      </div>

      <div class="card-body">
        <h4 class="card-title">
          <{ "Receive tokens" }>
        </h4>
        <div id="my-address-qrcode">
         <img src={generateQrCode(Common.getCurrentWalletAddress(currentWallet))}/>
        </div>
        <br/>
        <{"Your address is: "}>
        <br/>
        <input id="my-address" size="80" value={Common.getCurrentWalletAddress(currentWallet)}/>
        <br/>
        <br/>
        <button class="btn btn-outline-info" onClick={copyAddress}><{"Copy address"}></button>

      </div>
    </div>
  }
}
