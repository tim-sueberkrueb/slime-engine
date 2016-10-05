/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

.pragma library
.import QtQuick 2.4 as QtQuick

var backend = ""
var backendDetected = false
var autoDetectBackend = true

function detectBackend () {
    var webEngineError = false;
    var oxideError = false;

    var parent = Qt.createComponent("DummyItem.qml").createObject(null, {});

    try {
        var oxideDummy = Qt.createQmlObject("import QtQuick 2.5; import com.canonical.Oxide 1.15; QtObject {}", parent);
    }
    catch(e) {
        oxideError = e;
    }

    if (oxideDummy && !oxideError) {
        console.log("Using Oxide engine as backend.");
        backendDetected = true;
        return backend = "Oxide";
    }

    try {
        var webEngineDummy = Qt.createQmlObject("import QtQuick 2.5; import QtWebEngine 1.2; QtObject {}", parent);
    }
    catch(e){
        webEngineError = e;
    }

    if (webEngineDummy && !webEngineError) {
        console.log("Using QtWebEngine as backend.");
        backendDetected = true;
        return backend = "QtWebEngine";
    }

    // No engine found
    console.error("Error: No engine module found. Neither QtWebEngine nor Oxide are installed. Install one of those modules in order to use Slime Engine.");
    return "";
}

if (!backendDetected && autoDetectBackend)
    detectBackend();
