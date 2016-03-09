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
import com.canonical.Oxide 1.9
import "../base"
import "../../CertificateError.js" as CertificateError
import "../../LoadStatus.js" as LoadStatus
import "../../NewViewRequest.js" as NewViewRequest
import "../../Feature.js" as Feature
import "../../MessageLevel.js" as MessageLevel


Holding {
    core: webview

    property string usContext: "oxide://"
    property alias request: webview.request

    onReadyChanged: {
        if (ready)
            webview.finishCreation();
    }

    WebContext {
        id: webcontext
        userScripts: [
            UserScript {
                context: usContext
                url: Qt.resolvedUrl("oxide-user.js")
            }
        ]
    }

    Component {
        id: downloadComponent
        Download {}
    }

    WebView {
        id: webview
        anchors.fill: parent
        incognito: pipe.profile.incognito
        context: webcontext

        property real zoomFactor: pipe ? pipe.zoomFactor : 1
        onZoomFactorChanged: console.warn("Warning: zoomFactor is not supported with Oxide, yet.")
        property string backendName: "Oxide"

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
                pipe.loadingChanged(Events.getLoadingChangedEvent(event.url, status, event.isError, event.errorCode, event.errorString));
        }

        onFullscreenRequested: {
            pipe.fullScreenRequested(Requests.getFullScreenRequest(webview, fullscreen));
        }

        onNewViewRequested: {
            var oxideBackendComponent = Qt.createComponent("WebView.qml");
            var backendObject = oxideBackendComponent.createObject(null, {"request": request});

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

            pipe.newViewRequested(Requests.getNewViewRequest(webview, request, destination, backendObject));
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
            pipe.certificateError(Errors.getCertificateError(webview, error, error.url, type, error.overridable));
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
            pipe.consoleMessage(l, message, lineNumber, sourceId);
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
            pipe.featureRequested(Requests.getFeatureRequest(webview, request.origin, f, false, request));
        }

        onGeolocationPermissionRequested: {
            pipe.featureRequested(Requests.getFeatureRequest(webview, request.origin, Requests.featureType.location, false, request));
        }

        onDownloadRequested: {
            pipe.profile.downloadRequested(Requests.getDownloadRequest(pipe.profile, request, downloadComponent, request.mimeType))
        }

        function finishCreation() {
            webview.url = pipe ? pipe.url: Qt.resolvedUrl("");
            pipe.urlChanged.connect(function(){
                if (webview.url != pipe.url)
                    webview.url = pipe.url;
            });

            pipe.bind("url",            function(){ return webview.url          });
            pipe.bind("canGoBack",      function(){ return webview.canGoBack    });
            pipe.bind("canGoForward",   function(){ return webview.canGoForward });
            pipe.bind("icon",           function(){ return webview.icon         });
            pipe.bind("isFullScreen",   function(){ return webview.fullscreen   });
            pipe.bind("loadProgress",   function(){ return webview.loadProgress });
            pipe.bind("title",          function(){ return webview.title        });

            pipe.runJavaScript = function(script, callback){
                var req = webview.rootFrame.sendMessage(usContext, "RUN_JAVASCRIPT", {"script": script});
                req.onreply = function (msg) {
                    callback(msg.result);
                }
                req.onerror = function (code, explanation) {
                    console.error("Error " + code + " trying to run JavaScript: " + explanation);
                }
            }
            pipe.getHtml = function(callback){
                var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {});
                req.onreply = function (msg) {
                    callback(msg.html);
                }
                req.onerror = function (code, explanation) {
                    console.error("Error " + code + " trying to get HTML: " + explanation);
                }
            }
            pipe.setHtml = function(html, baseUrl){
                if (typeof baseUrl == 'undefined')
                    baseUrl = "";
                url = baseUrl;
                webview.loadHtml(html, baseUrl);
            }
            pipe.findText = function (text, backwards, caseSensitive, callback){
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
            pipe.cancelFullScreen = function(){
                webview.fullscreen = false;
            }
            pipe.goBack = webview.goBack;
            pipe.goForward = webview.goForward;
            pipe.reload = webview.reload
            pipe.stop = webview.stop
            pipe.ready();
        }
    }
}
