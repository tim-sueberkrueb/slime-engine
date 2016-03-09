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

Element {
    id: element
    objectName: "WebView"

    readonly property bool canGoBack: pipe.canGoBack
    readonly property bool canGoForward: pipe.canGoForward
    readonly property url icon: pipe.icon
    readonly property bool isFullScreen: pipe.isFullScreen
    readonly property int loadProgress: pipe.loadProgress
    readonly property string title: pipe.title
    property alias url: pipe.url
    property alias zoomFactor: pipe.zoomFactor // Not yet supported with Oxide
    property alias profile: pipe.profile

    function findText(text, backwards, caseSensitive, callback) {
        pipe.findText(text, backwards, caseSensitive, callback);
    }

    function cancelFullScreen() {
        pipe.cancelFullScreen();
    }

    function goBack(){
        pipe.goBack();
    }

    function goForward(){
        pipe.goForward();
    }

    function reload(){
        pipe.reload();
    }

    function runJavaScript(script, callback) {
        pipe.runJavaScript(script, callback);
    }

    function getHtml(callback) {
        pipe.getHtml(callback);
    }

    function setHtml(html, baseUrl){
        pipe.setHtml(html, baseUrl);
    }

    function stop(){
        pipe.stop();
    }

    function openRequest(request) {
        backend.openRequest(request);
    }

    signal loadingChanged(var event)
    signal fullScreenRequested(var request)
    signal newViewRequested(var request)
    signal featureRequested(var request)
    signal consoleMessage(string level, string message, int lineNumber, string sourceId)
    signal certificateError(var error)

    Pipe {
        id: pipe
        property bool canGoBack
        property bool canGoForward
        property url icon
        property bool isFullScreen
        property int loadProgress
        property string title
        property url url
        property real zoomFactor
        property Profile profile: Profile {}

        property var findText
        property var cancelFullScreen
        property var goBack
        property var goForward
        property var reload
        property var runJavaScript
        property var getHtml
        property var setHtml
        property var stop

        signal fullScreenRequested (var request)
        onFullScreenRequested: {
            element.fullScreenRequested(request);
        }

        signal newViewRequested (var request)
        onNewViewRequested: {
            element.newViewRequested(request);
        }

        signal featureRequested(var request)
        onFeatureRequested: {
            element.featureRequested(request);
        }

        signal loadingChanged (var event)
        onLoadingChanged: {
            element.loadingChanged(event);
        }
        signal consoleMessage(string level, string message, int lineNumber, string sourceId)
        onConsoleMessage: {
            element.consoleMessage(level, message, lineNumber, sourceId)
        }

        signal certificateError(var error)
        onCertificateError: {
            element.certificateError(error);
        }

    }

    backend: WebViewBackend {
        target: element
        pipe: pipe
    }
}
