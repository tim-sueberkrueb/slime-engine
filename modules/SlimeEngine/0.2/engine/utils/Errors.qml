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

pragma Singleton
import QtQuick 2.5
import "../../components/CertificateError.js" as CertificateError

QtObject {
    property Component certificateErrorComponent: Component {
        QtObject {
            objectName: "CertificateError"

            property var __webview
            property var __error

            property url url
            property bool overridable

            property int type
            property string typeName: CertificateError.names[type]

            function allow() {
                if (__webview.backendName == "QtWebEngine")
                    return __error.ignoreCertificateError();
                else if (__webview.backendName == "Oxide")
                    __error.allow();
            }

            function deny() {
                if (__webview.backendName == "QtWebEngine")
                    return __error.rejectCertificate();
                else if (__webview.backendName == "Oxide")
                    __error.deny();
            }
        }
    }

    function getCertificateError(webview, error, url, type, overridable){
        return certificateErrorComponent.createObject(null, {
            "__webview": webview,
            "__error": error,
            "url": url,
            "type": type,
            "overridable": overridable
        });
    }
}
