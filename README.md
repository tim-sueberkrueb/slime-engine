# Slime Engine
A QML webview wrapper to support both QtWebEngine and Oxide through one simple QML API.

# Installation

## Dependencies
* Qt >= 5.5 (QtQuick >= 2.5)

Either ...
* QtWebEngine >= 1.2

... or ...
* Oxide >= 1.15 and Ubuntu.DownloadManager >= 0.1

## Build and Install
```
    git clone https://github.com/tim-sueberkrueb/slime-engine
    cd slime-engine
    qmake && make
    sudo make install
```

## Usage

Try the demo:
```
    cd slime-engine
    qmlscene demo/Demo.qml
```

Minimal example:
```qml
import QtQuick 2.5
import SlimeEngine 0.2

WebView {
    engine: Slime.detectEngine()
    // engine: WebEngine.Oxide
    // engine: WebEngine.QtWebEngine
    url: "http://github.com"
}

```
Remember to call `QtWebEngine::initialize();` from C++ when you're using QtWebEngine.

# Releases
* v0.2
    * Current development release
    * Code cleanup and removed a lot of boilerplate code
    * Bug fixes
    * API changes:
        * `NewViewRequest.openIn()` and `WebView.openRequest` are no longer supported. Set `WebView.request` on creation of a new view instead.
        * `Slime.backend` was renamed to `Slime.engineName`
        * `Slime.backendDetected` was renamed to `Slime.engineDetected`
        * `Slime.detectBackend()` was renamed to `Slime.detectEngine()`
    * Slime no longer automatically detects the webengine
* v0.1
    * Initial alpha preview
    * There are some known bugs (fixed in v0.2) - do not use in production

Note: There is no stable realease, yet!

## Copyright and License
(C) Copyright 2016 by Tim Süberkrüb

Slime Engine is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

See LICENSE for more information.
