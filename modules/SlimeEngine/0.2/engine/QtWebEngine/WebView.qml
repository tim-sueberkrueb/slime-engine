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
import "../../components"
import "../utils"

EngineElement {
    id: engine
    property var request

    property alias url: webview.url
    property var webview: webview
    property bool loaded: false
    property var profile: w.profile.__engineInstance.profile

    readonly property bool canGoBack: webview.canGoBack
    readonly property bool canGoForward: webview.canGoForward
    readonly property url icon: webview.icon
    readonly property bool isFullScreen: webview.isFullScreen
    readonly property int loadProgress: webview.loadProgress
    readonly property string title: webview.title

    function runJavaScript(script, callback){
        webview.runJavaScript(script, callback);
    }

    function getHtml(callback){
        webview.runJavaScript("document.documentElement.innerHTML", callback);
    }

    function setHtml(html, baseUrl){
        if (typeof baseUrl == 'undefined')
            baseUrl = "";
        url = baseUrl;
        webview.loadHtml(html, baseUrl);
    }

    function findText(text, backwards, caseSensitive, callback){
        var flags;
        if (backwards)
            flags = WebEngineView.FindBackward
        if (caseSensitive)
            flags |= WebEngineView.FindCaseSensitively
        webview.findText(text, flags, callback);
    }

    function cancelFullScreen(){
        webview.fullScreenCancelled();
    }

    function goBack() {  webview.goBack(); }
    function goForward() { webview.goForward(); }
    function reload() { webview.reload(); }
    function stop() { webview.stop(); }

    engineName: "QtWebEngine"
    componentName: "WebView"

    WebEngineView {
        id: webview
        anchors.fill: parent

        zoomFactor: active && w ? w.zoomFactor : 1
        profile: engine.profile

        onLoadingChanged: {
            var status;
            switch(loadRequest.status) {
                case WebEngineView.LoadStartedStatus:
                    status = LoadStatus.LoadStarted;
                    break;
                case WebEngineView.LoadStoppedStatus:
                    status = LoadStatus.LoadStopped;
                    break;
                case WebEngineView.LoadSucceededStatus:
                    status = LoadStatus.LoadSucceeded;
                    break;
                case WebEngineView.LoadFailedStatus:
                    status = LoadStatus.LoadFailed;
                    break;
            }
            if (w && active)    // Known issue: the first loading event (LoadStarted) might get lost
                w.loadingChanged(Events.getLoadingChangedEvent(loadRequest.url, status, loadRequest.errorCode != 0, loadRequest.errorCode, loadRequest.errorString));
        }

        onFullScreenRequested: {
            w.fullScreenRequested(Requests.getFullScreenRequest(webview, request.toggleOn, request, engineName));
        }

        onNewViewRequested: {
            var qtWebEngineBackendComponent = Qt.createComponent("WebView.qml");
            var backendObject = qtWebEngineBackendComponent.createObject(null, { profile:  webview.profile });
            request.openIn(backendObject.webview);

            var destination;
            switch (request.destination) {
                case WebEngineView.NewViewInWindow:
                    destination = NewViewRequest.NewViewInWindow;
                    break;
                case WebEngineView.NewViewInTab:
                    destination = NewViewRequest.NewViewInTab;
                    break;
                case WebEngineView.NewViewInDialog:
                    destination = NewViewRequest.NewViewInDialog;
                    break;
                case WebEngineView.NewViewInBackgroundTab:
                    destination = NewViewRequest.NewViewInBackgroundTab;
                    break;
            }
            w.newViewRequested(Requests.getNewViewRequest(webview, request, destination, backendObject));
        }

        onCertificateError: {
            error.defer();
            var type = 0;
            switch(error.certError) {
                case error.SslPinnedKeyNotInCertificateChain:
                    type = CertificateError.BadIdentity;
                    break;
                case error.CertificateDateInvalid:
                    type = CertificateError.Expired;
                    break;
                case error.ErrorDateInvalid:
                    type = CertificateError.DateInvalid;
                    break;
                case error.CertificateAuthorityInvalid:
                    type = CertificateError.AuthorityInvalid;
                    break;
                case error.CertificateRevoked:
                    type = CertificateError.Revoked;
                    break;
                case error.CertificateInvalid:
                    type = CertificateError.Invalid;
                    break;
                case error.CertificateWeakKey:
                    type = CertificateError.Insecure;
                    break;
                case error.CertificateWeakSignatureAlgorithm:
                    type = CertificateError.Insecure;
                    break;
                default:
                    type = CertificateError.Generic;
            }
            w.certificateError(Errors.getCertificateError(webview, error, error.url, type, error.overridable));
        }

        onJavaScriptConsoleMessage: {
            var l = "";
            switch(level) {
                case WebEngineView.InfoMessageLevel:
                    l = MessageLevel.Info
                    break;
                case WebEngineView.WarningMessageLevel:
                    l = MessageLevel.Warning
                    break;
                case WebEngineView.ErrorMessageLevel:
                    l = MessageLevel.Error
                    break;
            }
            w.consoleMessage(l, message, lineNumber, sourceID)
        }

        onFeaturePermissionRequested: {
            var f;
            switch(feature) {
                case WebEngineView.Geolocation:
                    f = Feature.Location;
                    break;
                case WebEngineView.MediaAudioCapture:
                    f = Feature.AudioCapture;
                    break;
                case WebEngineView.MediaVideoCapture:
                    f = Feature.VideoCapture;
                    break;
                case WebEngineView.MediaAudioVideoCapture:
                    f = Feature.AudioVideoCapture;
                    break;
            }
            w.featureRequested(Requests.getFeatureRequest(webview, securityOrigin, f, feature));
        }

        onWindowCloseRequested: {
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
