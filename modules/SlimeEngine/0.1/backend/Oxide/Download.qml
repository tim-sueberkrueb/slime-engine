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
import Ubuntu.DownloadManager 0.1


QtObject {
    id: downloadItem
    objectName: "Download"
    property var __request

    property real progress: __single.progress/100
    property string path: __request.suggestedFilename
    property string mimeType: __request.mimeType

    property SingleDownload __single: SingleDownload {
        onFinished: {
            downloadItem.finished();
        }
    }

    function download() {
        __single.download(__request.url);
        __single.start();
    }

    function cancel() {
        __single.cancel();
    }

    signal finished()
    signal failed()
}
