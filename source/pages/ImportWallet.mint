component ImportWallet {

  style mx {
    max-width: 20rem;
  }

  fun render : Html {
    <div>
     <br/>
    <div::mx class="card text-black bg-white mb-3">
      <div class="card-header"><{"Import a wallet"}></div>
      <div class="card-body">
      <ImportEncryptedWallet/>
      <ImportUnencryptedWallet/>
      </div>
    </div>

    </div>
  }
}
