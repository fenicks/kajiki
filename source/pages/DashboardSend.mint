component DashboardSend {
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
              name = "Send",
              path = "/dashboard/send"
            }
          }/>

        <div>
          <br/>
          <Send/>
        </div>
      </div>
    </div>
  }
}
