const {app, BrowserWindow} = require('electron') // http://electron.atom.io/docs/api

let window = null

// Wait until the app is ready
app.once('ready', () => {
  // Create a new window
  window = new BrowserWindow({
    // Set the initial width to 800px
    width: 800,
    // Set the initial height to 600px
    height: 600,
    // Don't show the window until it ready, this prevents any white flickering
    show: false,
    webPreferences: {
      // Disable node integration in remote page
      nodeIntegration: false
    }
  })

  const exec = require('child_process').exec;

  const process = exec('npm run kajiki-http', () => {
    // URL is argument to npm start
    window.loadURL(`http://localhost:3002`)

    // Show window when page is ready
    window.once('ready-to-show', () => {
      window.maximize()
      window.show()
    });

    window.on('closed', ()=> {
        process.kill();
    });
  })

  
})