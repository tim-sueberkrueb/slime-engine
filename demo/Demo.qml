/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3
import SlimeEngine 0.1


ApplicationWindow {
    id: window
    title: "Slime Demo"
    width: 640
    height: 480

    property var downloadModel: []

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: webview.icon
                    sourceSize: Qt.size(16, 16)
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: webview.title
                }

                TextField {
                    id: inputUrl
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.fillWidth: true
                    text: "https://google.com"

                    Binding {
                        target: inputUrl
                        property: "text"
                        value: webview.url
                    }

                    onAccepted: {
                        webview.url = text;
                    }
                }
            }

            Profile {
                id: profile
                incognito: false
                onDownloadRequested: {
                    console.log("Download requested", request, request.mimeType)
                    var download = request.accept();
                    console.log("Got download item", download)
                    download.progressChanged.connect(function(){console.log("Download progress changed:", download.progress)})
                    downloadModel.push(download);
                    downloadModelChanged();
                }
            }

            WebView {
                id: webview
                Layout.fillHeight: true
                Layout.fillWidth: true

                url: inputUrl.text
                zoomFactor: zoomSlider.value
                profile: profile

                onLoadingChanged: {
                    console.log("Loading changed", event.statusName, event.url, event.errorCode);
                }

                onFullScreenRequested: {
                    console.log("FullScreen requested")
                    if (request.toggleOn)
                        window.showFullScreen();
                    else
                        window.showNormal();
                    request.accept();
                }

                onNewViewRequested: {
                    console.log("New view requested, destination: %1".arg(request.destinationName))
                    request.openIn(secondWebView);
                }

                onCertificateError: {
                    console.log("Certificate error:", error,  error.typeName);
                    error.allow();
                }

                onConsoleMessage: {
                    console.log("Console message:", level, message, lineNumber, sourceId)
                }

                onFeatureRequested: {
                    console.log("Feature requested:", request.featureName, request.origin)
                    request.accept();
                }
            }

            WebView {
                id: secondWebView
                profile: profile
                Layout.fillHeight: url != ""
                Layout.fillWidth: true

                onFeatureRequested: {
                    console.log("Feature requested:", request.featureName, request.origin)
                    request.accept();
                }
            }
        }

        Flickable {
            Layout.fillHeight: true
            width: columnLayout.childrenRect.width

            contentHeight: columnLayout.childrenRect.height

            ColumnLayout {
                id: columnLayout

                Button {
                    text: "Go Back"
                    enabled: webview.canGoBack
                    onClicked: webview.goBack()
                }

                Button {
                    text: "Go Forward"
                    enabled: webview.canGoForward
                    onClicked: webview.goForward()
                }

                Button {
                    text: "Reload"
                    onClicked: webview.reload()
                }

                Button {
                    text: "Stop"
                    onClicked: webview.stop()
                }

                Button {
                    text: "Set HTML"
                    onClicked: {
                        webview.setHtml("Hello World!")
                    }
                }

                Button {
                    text: "Get HTML"
                    onClicked: {
                        webview.getHtml(function(html){
                            console.log(html)
                        });
                    }
                }

                Button {
                    text: "Run JavaScript"
                    onClicked: {
                        webview.runJavaScript("84/2", function(result) {
                            console.log("Evaluated JavaScript: " + result)
                        });
                        webview.runJavaScript("console.log('Hello from JavaScript!')");
                    }
                }

                TextField {
                    id: inputFind
                }

                CheckBox {
                    id: chbFindBackward
                    text: "Backward"
                }

                CheckBox {
                    id: chbFindCaseSensitive
                    text: "Case Sensitive"
                }

                Button {
                    text: "Find"
                    onClicked: {
                        webview.findText(inputFind.text, chbFindBackward.checked, chbFindCaseSensitive.checked)
                    }
                }

                Button {
                    text: "Cancel fullscreen"
                    enabled: webview.isFullScreen
                    onClicked: {
                        webview.cancelFullScreen();
                        window.showNormal();
                    }
                }

                Label {
                    text: "Zoom"
                    visible: Slime.backend !== "Oxide"
                }

                Slider {
                    id: zoomSlider
                    visible: Slime.backend !== "Oxide"
                    minimumValue: 0.25
                    maximumValue: 5
                    value: 1
                }

                Label {
                    text: "Downloads"
                }

                ListView {
                    width: parent.width
                    height: 256

                    model: downloadModel

                    delegate: Item {
                        width: parent.width
                        height: 96

                        property var download: downloadModel[index]
                        onDownloadChanged: console.log(download)

                        Column {
                            anchors.fill: parent

                            Label {
                                text: "Path: %1".arg(download.path)
                            }

                            ProgressBar {
                                minimumValue: 0
                                maximumValue: 1
                                value: download.progress
                            }

                            Button {
                                text: "Cancel"
                                onClicked: {
                                    download.cancel();
                                    text = "Canceled";
                                    enabled = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
