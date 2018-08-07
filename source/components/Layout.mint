component Layout {

  property children : Array(Html) = []

  get nav : Html {
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
      <a
        class="navbar-brand center"
        href="/">

        <{ "Kajiki - Wallet" }>

      </a>

      <button
        class="navbar-toggler"
        type="button"
        data-toggle="collapse"
        data-target="#navbarsExampleDefault"
        aria-controls="navbarsExampleDefault"
        aria-expanded="false"
        aria-label="Toggle navigation">

        <span class="navbar-toggler-icon"/>

      </button>

      <div
        class="collapse navbar-collapse"
        id="navbarsExampleDefault">

        <ChooseNetwork/>

      </div>
    </nav>
  }

  fun render : Html {
    <div>
      <{ nav }>

      <main
        role="main"
        class="container">

        <{ children }>

      </main>
    </div>
  }
}
