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
import "../../components/NewViewRequest.js" as NewViewRequest
import "../../components/Feature.js" as Feature

QtObject {
    property Component fullScreenRequestComponent: Component {
        QtObject {
            objectName: "FullScreenRequest"
            property bool toggleOn: true
            property var __request
            property var __webview
            property string __engine

            function accept() {
                if (__engine == "QtWebEngine")
                    __request.accept();
                else if (__engine == "Oxide")
                    __webview.fullscreen = toggleOn;
            }
        }
    }

    property Component newViewRequestComponent: Component {
        QtObject {
            id: request
            objectName: "NewViewRequest"
            property var __request
            property var __webview
            property var __backend
            property int destination: 1

            property string destinationName: NewViewRequest.names[destination]

            function openIn(webview) {
                console.warn("Warning: NewViewRequest.openIn() is no longer supported in SlimeEngine >= 0.2");
                console.warn("This is an application bug.");
                webview.openRequest(request);
            }
        }
    }

    property Component featureRequestComponent: Component {
        QtObject {
            id: request
            objectName: "FeatureRequest"
            property var __request
            property var __webview
            property int __feature
            property string __engine
            property url origin
            property int feature: 0

            property string featureName: Feature.names[feature]

            function accept() {
                if (__engine == "QtWebEngine") {
                    __webview.grantFeaturePermission(origin, __feature, true);
                }
                else if (__engine == "Oxide")
                    __request.allow();
            }

            function deny() {
                if (__engine == "QtWebEngine") {
                    __webview.grantFeaturePermission(origin, __feature, false);
                }
                else if (__engine.backendName == "Oxide")
                    __request.deny();
            }

        }
    }

    property Component downloadRequestComponent: Component {
        QtObject {
            id: request
            objectName: "DownloadRequest"
            property var __request
            property var __profile
            property var __component
            property string __engine
            property string mimeType

            function accept() {
                var download;
                if (__engine == "QtWebEngine") {
                    download = __component.createObject(null, {"__downloadItem": __request});
                    download.download();
                    return download;
                }
                else if (__engine == "Oxide") {
                    download = __component.createObject(null, {"__request": __request});
                    download.download();
                    return download;
                }
            }
        }
    }

    function getFullScreenRequest(webview, toggleOn, request, engine) {
        return fullScreenRequestComponent.createObject(null, {"__webview": webview, "__request": request, "__engine": engine, "toggleOn": toggleOn});
    }

    function getNewViewRequest(webview, request, destination, backend) {
        return newViewRequestComponent.createObject(null, {"__webview": webview, "__request": request, "__backend": backend, "destination": destination});
    }

    function getFeatureRequest(webview, origin, feature, __feature, engine, request) {
        return featureRequestComponent.createObject(null, {"__webview": webview, "__request": request, "origin": origin, "feature": feature, "__feature": __feature, "__engine": engine});
    }

    function getDownloadRequest(profile, request, component, mimeType, engine) {
        return downloadRequestComponent.createObject(null, {"__profile": profile, "__request": request, "__component": component, "mimeType": mimeType, "__engine": engine})
    }
}
