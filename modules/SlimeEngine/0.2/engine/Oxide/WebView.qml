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
import com.canonical.Oxide 1.15
import "../../components"
import "../utils"

EngineElement {
    id: engine
    property string usContext: "oxide://"
    property alias request: webview.request
    property alias url: webview.url
    property bool loaded: false
    property var profile: w.profile

    readonly property bool canGoBack: webview.canGoBack
    readonly property bool canGoForward: webview.canGoForward
    readonly property url icon: webview.icon
    readonly property bool isFullScreen: webview.fullscreen
    readonly property int loadProgress: webview.loadProgress
    readonly property string title: webview.title

    property Component downloadComponent: Component {
        Download {}
    }

    engineName: "Oxide"
    componentName: "WebView"

    function runJavaScript(script, callback){
        var req = webview.rootFrame.sendMessage(usContext, "RUN_JAVASCRIPT", {"script": script});
        req.onreply = function (msg) {
            callback(msg.result);
        }
        req.onerror = function (code, explanation) {
            console.error("Error " + code + " trying to run JavaScript: " + explanation);
        }
    }

    function getHtml(callback){
        var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {});
        req.onreply = function (msg) {
            callback(msg.html);
        }
        req.onerror = function (code, explanation) {
            console.error("Error " + code + " trying to get HTML: " + explanation);
        }
    }

    function setHtml(html, baseUrl){
        if (typeof baseUrl == 'undefined')
            baseUrl = "";
        url = baseUrl;
        webview.loadHtml(html, baseUrl);
    }

    function findText(text, backwards, caseSensitive, callback){
        webview.findController.text = text;
        if (backwards)
            webview.findController.previous();
        else
            webview.findController.next();
        if (caseSensitive)
            webview.findController.caseSensitive = true;
        else
            webview.findController.caseSensitive = false;
        if (callback)
            callback(webview.findController.count);
    }

    function cancelFullScreen(){
        webview.fullscreen = false;
    }

    function goBack() {  webview.goBack(); }
    function goForward() { webview.goForward(); }
    function reload() { webview.reload(); }
    function stop() { webview.stop(); }

    WebView {
        id: webview
        anchors.fill: parent

        zoomFactor: active && w ? w.zoomFactor : 1
        incognito: engine.profile

        context: WebContext {
            id: webcontext
            userScripts: [
                UserScript {
                    context: usContext
                    url: Qt.resolvedUrl("oxide-user.js")
                }
            ]
        }

        onLoadEvent: {
            var status;
            switch(event.type) {
            case LoadEvent.TypeStarted:
                status = LoadStatus.LoadStarted;
                break;
            case LoadEvent.TypeStopped:
                status = LoadStatus.LoadStopped;
                break;
            case LoadEvent.TypeSucceeded:
                status = LoadStatus.LoadSucceeded;
                break;
            case LoadEvent.TypeFailed:
                status = LoadStatus.LoadFailed;
                break;
            default:
                status = -1;
            }
            if (status !== -1)
                w.loadingChanged(Events.getLoadingChangedEvent(event.url, status, event.isError, event.errorCode, event.errorString));
        }

        onFullscreenRequested: {
            w.fullScreenRequested(Requests.getFullScreenRequest(webview, fullscreen, true, engineName));
        }

        onNewViewRequested: {
            var oxideBackendComponent = Qt.createComponent("WebView.qml");
            var backendObject = oxideBackendComponent.createObject(null, {"request": request, "profile": profile});

            var destination;
            switch (request.disposition) {
            case NewViewRequest.DispositionNewWindow:
                destination = NewViewRequest.NewViewInWindow;
                break;
            case NewViewRequest.DispositionNewForegroundTab:
                destination = NewViewRequest.NewViewInTab;
                break;
            case NewViewRequest.DispositionNewPopup:
                destination = NewViewRequest.NewViewInDialog;
                break;
            case NewViewRequest.DispositionNewBackgroundTab:
                destination = NewViewRequest.NewViewInBackgroundTab;
                break;
            }

            w.newViewRequested(Requests.getNewViewRequest(webview, request, destination, backendObject));
        }

        onCertificateError: {
            var type = 0;
            switch(error.certError) {
            case error.ErrorBadIdentity:
                type = CertificateError.BadIdentity;
                break;
            case error.ErrorExpired:
                type = CertificateError.Expired;
                break;
            case error.ErrorDateInvalid:
                type = CertificateError.DateInvalid;
                break;
            case error.ErrorAuthorityInvalid:
                type = CertificateError.AuthorityInvalid;
                break;
            case error.ErrorRevoked:
                type = CertificateError.Revoked;
                break;
            case error.ErrorInvalid:
                type = CertificateError.Invalid;
                break;
            case error.ErrorInsecure:
                type = CertificateError.Insecure;
                break;
            default:
                type = CertificateError.Generic;
            }
            w.certificateError(Errors.getCertificateError(webview, error, error.url, type, error.overridable));
        }

        onJavaScriptConsoleMessage: {
            var l = "";
            switch (level) {
            case WebView.LogSeverityVerbose:
                l = MessageLevel.Info
                break;
            case WebView.LogSeverityInfo:
                l = MessageLevel.Info
                break;
            case WebView.LogSeverityWarning:
                l = MessageLevel.Warning
                break;
            case WebView.LogSeverityError:
                l = MessageLevel.Warning
                break;
            case WebView.LogSeverityErrorReport:
                l = MessageLevel.Warning
                break;
            case WebView.LogSeverityFatal:
                l = MessageLevel.Warning
                break;
            }
            w.consoleMessage(l, message, lineNumber, sourceId);
        }

        onMediaAccessPermissionRequested: {
            var f;
            if (request.isForAudio)
                f = Feature.AudioCapture;
            else if (request.isForAudio && request.isForVideo)
                f = Feature.AudioVideoCapture;
            else if (request.isForVideo)
                f = Feature.VideoCapture;
            else if (request.isForAudio)
                f = Feature.AudioCapture;
            w.featureRequested(Requests.getFeatureRequest(webview, request.origin, f, false, request));
        }

        onGeolocationPermissionRequested: {
            w.featureRequested(Requests.getFeatureRequest(webview, request.origin, Feature.Location, false, request));
        }

        onDownloadRequested: {
            w.profile.downloadRequested(Requests.getDownloadRequest(w.profile, request, downloadComponent, request.mimeType, engineName));
        }

        onCloseRequested: {
            w.closeRequested();
        }

        Binding {
            when: active
            target: w
            property: "url"
            value: webview.url
        }

        Connections {
            enabled: active
            target: w
            onUrlChanged: {
                if (webview.url != w.url)
                    webview.url = w.url;
            }
        }
    }
}
