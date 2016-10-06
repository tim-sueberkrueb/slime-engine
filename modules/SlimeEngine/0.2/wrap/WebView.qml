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
import "../components"

Wrap {
    id: webviewWrap
    __componentName: "WebView"
    __init: Init {
        script: function() {
            if (__engineName === "Oxide") {
                if (request) {
                    var engine = request.__backend;
                    webviewWrap.__engineInstance = engine;
                    engine.wrapInstance = webviewWrap;
                    engine.parent = webviewWrap;
                    engine.anchors.fill = webviewWrap;
                    engine.active = true;
                }
                else {
                    wrapInstance.__createEngineComponent();
                    wrapInstance.__createEngineInstance({
                        request: request ? request.__request : null,
                        url: url
                    });
                }
            }

            if (__engineName === "QtWebEngine") {
                if (request) {
                    var engine = request.__backend;
                    webviewWrap.__engineInstance = engine;
                    engine.wrapInstance = webviewWrap;
                    engine.parent = webviewWrap;
                    engine.anchors.fill = webviewWrap;
                    engine.active = true;
                }
                else {
                    wrapInstance.__createEngineComponent();
                    wrapInstance.__createEngineInstance({
                        url: url
                    });
                }
            }
        }
    }

    property url url: Qt.resolvedUrl("about:blank")

    property double zoomFactor: 1
    property WebProfile profile: WebProfile {}
    property var request

    readonly property bool canGoBack: __engineInstance.canGoBack
    readonly property bool canGoForward: __engineInstance.canGoForward
    readonly property url icon: __engineInstance.icon
    readonly property bool isFullScreen: __engineInstance.isFullScreen
    readonly property int loadProgress: __engineInstance.loadProgress
    readonly property int loadStatus: __engineInstance.loadStatus
    readonly property string title: __engineInstance.title

    function findText(text, backwards, caseSensitive, callback) {
        __engineInstance.findText(text, backwards, caseSensitive, callback);
    }

    function cancelFullScreen() {
        __engineInstance.cancelFullScreen();
    }

    function goBack(){
        __engineInstance.goBack();
    }

    function goForward(){
        __engineInstance.goForward();
    }

    function reload(){
        __engineInstance.reload();
    }

    function runJavaScript(script, callback) {
        __engineInstance.runJavaScript(script, callback);
    }

    function getHtml(callback) {
        __engineInstance.getHtml(callback);
    }

    function setHtml(html, baseUrl){
        __engineInstance.setHtml(html, baseUrl);
    }

    function stop(){
        __engineInstance.stop();
    }

    function openRequest(request) {
        console.warn("Warning: WebView.openRequest() is no longer supported in SlimeEngine >= 0.2");
        console.warn("This is an application bug.");
    }

    signal loadingChanged(var event)
    signal fullScreenRequested(var request)
    signal newViewRequested(var request)
    signal featureRequested(var request)
    signal consoleMessage(string level, string message, int lineNumber, string sourceId)
    signal certificateError(var error)
    signal closeRequested()
}
