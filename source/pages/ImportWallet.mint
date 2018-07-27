component ImportWallet {

  style mx {
    max-width: 20rem;
  }

  fun render : Html {
    <div>
     <br/>
    <div class="card text-black bg-white mb-9">
      <div class="card-header"><{"Import a wallet"}></div>
      <div class="card-body">
      <Error/>
      <ImportEncryptedWallet/>
      <ImportUnencryptedWallet/>
      </div>
    </div>

    </div>
  }
}
