component DashboardBackup {
  fun render : Html {
    <div class="row">
      <div class="col-md-3">
        <br/>
        <MyWallets/>
      </div>

      <div class="col-md-9">
        <br/>

        <Tabs
          currentTab={
            {
              name = "Backup",
              path = "/dashboard/backup"
            }
          }/>

        <div>
          <br/>
          <Backup/>
        </div>
      </div>
    </div>
  }
}
