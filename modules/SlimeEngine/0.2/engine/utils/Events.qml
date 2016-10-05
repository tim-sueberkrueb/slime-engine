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
import QtQuick 2.5
import "../../components/LoadStatus.js" as LoadStatus

QtObject {
    property Component loadingChangedEventComponent: Component {
        QtObject {
            objectName: "LoadingChangedEvent"
            property url url
            property int status

            property string statusName: LoadStatus.names[status]
            property bool isError
            property int errorCode
            property string errorString
        }
    }

    function getLoadingChangedEvent(url, status, isError, errorCode, errorString){
        return loadingChangedEventComponent.createObject(null, {
            "url": url,
            "status": status,
            "isError": isError,
            "errorCode": errorCode,
            "errorString": errorString
        });
    }
}
