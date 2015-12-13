chrome.app.runtime.onLaunched.addListener () -> 
    chrome.app.window.create "../index.html", {
        id: "app-window"
        bounds: {
            width: 668
            height: 420
        }
    }
