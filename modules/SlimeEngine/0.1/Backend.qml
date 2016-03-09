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

import QtQuick 2.4
import "../"

Item {
    property Element target
    property Pipe pipe
    property bool createBackendOnCompletion: true

    property var backendInstance
    property string backendName: ""

    function createBackend(object, backend){
        if(!object)
            object = target.objectName;
        if (!backend) {
            if (!Slime.backendDetected)
                Slime.detectBackend();
            backend = Slime.backend;
        }
        var component = Qt.createComponent("backend/%1/%2.qml".arg(backend).arg(object));
        if (component.status === Component.Error) {
            console.error("Error loading %1 backend component for %2:".arg(object).arg(backend),
                        component.errorString());
            return;
        }
        backendName = backend;
        backendInstance = component.createObject(target, {
            "anchors.fill": target,
            "pipe": pipe
        });
        backendInstance.ready = true;
        target.completed();
    }

    function destroyBackend(){
        backendInstance.destroy();
        backendName = "";
    }

    Component.onCompleted: {
        if (createBackendOnCompletion)
            createBackend();
    }
}
