record Ui.Pager.Item {
  contents : Html,
  name : String
}

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
        name = "import-wallet",
        contents = <ImportWallet/>
      },
      {
        name = "dashboard",
        contents = <DashboardSummary/>
      },
      {
        name = "send",
        contents = <DashboardSend/>
      },
      {
        name = "receive",
        contents = <DashboardReceive/>
      },
      {
        name = "transactions",
        contents = <DashboardTransactions/>
      },
      {
        name = "backup",
        contents = <DashboardBackup/>
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
      |> Array.find((item : Ui.Pager.Item) : Bool => {item.name == page})
      |> Maybe.map((item : Ui.Pager.Item) : Html => {item.contents})
      |> Maybe.withDefault(<div/>)
  }
}
