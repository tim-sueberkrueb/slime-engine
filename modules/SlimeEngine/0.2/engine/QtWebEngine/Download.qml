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
import QtWebEngine 1.2

QtObject {
    property var __downloadItem

    property real progress: (__downloadItem.receivedBytes/__downloadItem.totalBytes) * 100
    property string path: __downloadItem.path
    property string mimeType: __downloadItem.mimeType

    function download() {
        __downloadItem.accept();
    }

    function cancel() {
        __downloadItem.cancel();
    }

    signal finished()
    signal failed()

    Component.onCompleted: {
        __downloadItem.stateChanged.connect(function(){
            if (__downloadItem.state == WebEngineDownloadItem.DownloadCompleted)
                finished();
            else if (__downloadItem.state == WebEngineDownloadItem.DownloadInterrupted)
                failed();
        });
    }
}
