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

pragma Singleton
import QtQuick 2.4
import "backend/base/"

Item {
    id: slime
    property string backend: ""
    property bool backendDetected: false

    function detectBackend () {
        var webEngineError = false;
        var oxideError = false;

        try {
            var webEngineDummy = Qt.createQmlObject("import QtQuick 2.4; import QtWebEngine 1.1; QtObject {}", slime);
        }
        catch(e){
            webEngineError = e;
        }

        try {
            var oxideDummy = Qt.createQmlObject("import QtQuick 2.4; import com.canonical.Oxide 1.9; QtObject {}", slime);
        }
        catch(e) {
            oxideError = e;
        }

        if (webEngineDummy && !webEngineError) {
            console.log("Using QtWebEngine as backend.")
            backendDetected=true;
            return backend = "QtWebEngine";
        }
        else if (oxideDummy && !oxideError) {
            console.log("Using Oxide engine as backend.")
            backendDetected=true;
            return backend = "Oxide";
        }
        else {
            console.error("No backend module found. Neither QtWebEngine nor Oxide are installed. Install one of those modules in order to use Slime.")
        }
    }
}
