var puppeteer = require('puppeteer');
var { record } = require('puppeteer-recorder');

init_puppeteer();

var global_browser; 
async function init_puppeteer() {

        global_browser = await puppeteer.launch({headless: true , args: ['--no-sandbox', '--disable-setuid-sandbox']});

    check_login()
};

async function check_login()
{
    try {
        const page = await global_browser.newPage();
        await page.setViewport({width: 1000, height: 1100});

        await record({
            browser: global_browser, // Optional: a puppeteer Browser instance,
            page: page, // Optional: a puppeteer Page instance,
            output: 'output.webm',
            fps: 60,
            frames: 60 * 5, // 5 seconds at 60 fps
        prepare: function () {}, // <-- add this line
        render: function () {} // <-- add this line

        });

        await page.goto('https://tubatuba.net/', {timeout: 60000})
            .catch(function (error) {
                throw new Error('TimeoutBrows');
            });

        await page.close();
    }
    catch (e) {
        console.log(' LOGIN ERROR ---------------------');
        console.log(e);
    }
}