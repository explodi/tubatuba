const puppeteer = require('puppeteer');
console.log(__dirname)
var options = {
  headless: false,
  args: [
    '--enable-usermedia-screen-capturing',
    '--allow-http-screen-capture',
    '--no-sandbox',
    '--auto-select-desktop-capture-source=pickme',
    '--disable-setuid-sandbox',
    '--load-extension=' + __dirname,,
    '--disable-extensions-except=' + __dirname,
  ],
  executablePath: 'google-chrome',
}
puppeteer.launch().then(browser=>{
    console.log("launch")
    return browser.pages().then(pages=>{
        console.log("pages")
        var page = pages[0];
        return page.goto('https://tubatuba.net', {waitUntil: 'domcontentloaded'}).then(_=>{
            console.log("networkidle0")
            return page.evaluate(()=>{
                console.log("ev");
                var session = {
                    audio: false,
                    video: {
                        mandatory: {
                            chromeMediaSource: 'screen',
                        },
                        optional: []
                    },
                };
            })
        })
    }).then(_=>{
        // return browser.close()
    })
})

