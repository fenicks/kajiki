component Main {
  connect Application exposing { page, setPage }

  get pages : Array(Ui.Pager.Item) {
    [
      {
        name = "add-wallet",
        contents = <AddWallet/>
      },
      {
        name = "create-wallet",
        contents = <CreateWallet/>
      },
      {
        name = "not_found",
        contents =
          <div>
            <{ "404" }>
          </div>
      }
    ]
  }

  fun render : Html {
    <Layout>
      <{ content }>
    </Layout>
  } where {
    content =
      pages
      |> Array.find(\item : Ui.Pager.Item => item.name == page)
      |> Maybe.map(\item : Ui.Pager.Item => item.contents)
      |> Maybe.withDefault(<div/>)
  }
}
