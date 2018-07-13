record Tab {
  name : String,
  path : String
}

component Tabs {
  property currentTab : Tab = {name = "Sumary", path = "/dashboard"}

  fun render : Html {
    <ul class="nav nav-tabs">
     <{ tabs
        |> Array.map(renderTab)
     }>
    </ul>
  } where {
    tabs = [
     {name = "Summary", path = "/dashboard"},
     {name = "Send", path = "/dashboard/send"},
     {name = "Receive", path = "/dashboard/receive"},
     {name = "Transactions", path = "/dashboard/transactions"},
     {name = "Backup", path = "/dashboard/backup"},
    ]
  }

  fun renderTab(tab : Tab) : Html {
    <li class="nav-item">
      <a
        class={"nav-link " + active}
        data-toggle="tab"
        href={tab.path}>

        <{ tab.name }>

      </a>
    </li>
  } where {
    active = if(tab == currentTab){
      "active"
    } else {
      ""
    }
  }

}
