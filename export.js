const puppeteer = require('puppeteer');
const Xvfb      = require('xvfb');
var xvfb        = new Xvfb({silent: true});
var width       = parseInt(process.argv[4]);
var height      = parseInt(process.argv[5]);
var options     = {
  headless: false,
  args: [
    '--enable-usermedia-screen-capturing',
    '--no-sandbox',
    '--allow-http-screen-capture',
    '--auto-select-desktop-capture-source=puppetcam',
    '--load-extension=' + __dirname,,
    '--disable-extensions-except=' + __dirname,
    '--disable-infobars',
    `--window-size=${width},${height}`,
  ],
}

async function main() {
    xvfb.startSync()
    var url = process.argv[2], exportname = process.argv[3]
    if(!url){ url = 'http://tobiasahlin.com/spinkit/' }
    if(!exportname){ exportname = 'spinner.webm' }
    const browser = await puppeteer.launch(options)
    const pages = await browser.pages()
    const page = pages[0]
    await page._client.send('Emulation.clearDeviceMetricsOverride')
    await page.goto(url, {waitUntil: 'load'})
    await page.setBypassCSP(true)

    // Perform any actions that have to be captured in the exported video
    await page.waitFor(16000)

    await page.evaluate(filename=>{
        window.postMessage({type: 'SET_EXPORT_PATH', filename: filename}, '*')
        window.postMessage({type: 'REC_STOP'}, '*')
    }, exportname)

    // Wait for download of webm to complete
    await page.waitForSelector('html.downloadComplete', {timeout: 0})
    await page.screenshot({path: 'public/image/screen.png'});

    await browser.close()
    xvfb.stopSync()
}

main()

