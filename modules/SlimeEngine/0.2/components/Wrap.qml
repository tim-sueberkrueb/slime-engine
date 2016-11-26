/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.5
import "."

Item {
    id: wrap

    property int engine
    property string __engineName: WebEngine.names[engine]
    property string __componentName: ""
    property var __engineComponent
    property var __engineInstance

    property Init __init: Init { wrapInstance: wrap }   // Default initializer
    on__InitChanged: __init.wrapInstance = wrap;

    property var __createEngineComponent: function() {
        var componentUrl = "../engine/%1/%2.qml".arg(__engineName).arg(__componentName);
        __engineComponent = Qt.createComponent(componentUrl);
        if (__engineComponent.status == Component.Error) {
            console.error("Error creating %1 engine component for %1: ".arg(__componentName).arg(__engineName))
            console.error(__engineComponent.errorString());
        }
        return __engineComponent;
    }

    property var __createEngineInstance: function (customProperties) {
        var properties = {
            wrapInstance: wrap,
            active: true
        };
        if (customProperties) {
            for (var key in customProperties)
                properties[key] = customProperties[key];
        }
        __engineInstance = __engineComponent.createObject(wrap, properties);
        __engineInstance.anchors.fill = wrap;
        return __engineInstance;
    }

    Component.onCompleted: {
        __init.begin();
        __init.script();
        __init.end();
    }
}
