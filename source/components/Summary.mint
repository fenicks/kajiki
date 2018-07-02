component Summary {

  connect WalletStore exposing { getCurrentWallet }



fun render : Html {
  <div class="card text-white bg-primary mb-3">
  <div class="card-header"><{name}></div>
  <div class="card-body">
    <h4 class="card-title"><{"Primary Card Title"}></h4>
    <p class="card-text"><{"Some quick example text to build on the card title and make up the bulk of the card's content."}></p>
  </div>
</div>
} where {
  current = getCurrentWallet()
  name = current |> Maybe.map(\c : WalletItem => c.name) |> Maybe.withDefault("")
}

}
