pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Greetd
import Quickshell.Wayland

Singleton {
    id: root

    // ── IvyTheme (inlined) ───────────────────────────────────────────────────
    readonly property var c: ({
        bg0:     "#161615",
        bg1:     "#1c1b1a",
        bg2:     "#222120",
        bg3:     "#3d3a38",
        bg4:     "#4a4644",
        fg0:     "#f2eadd",
        fg1:     "#c7c9a7",
        fg2:     "#929283",
        accent0: "#868868",
        accent1: "#cad193",
        border0: "#47483b",
        red0:    "#b86161",
        green0:  "#668e37"
    })

    readonly property var font: ({
        ui:   "Noto Serif",
        mono: "JetBrains Mono"
    })

    // ── State ────────────────────────────────────────────────────────────────

    property string currentUser: ""
    property string authMessage: ""
    property bool authError: false
    property bool responseRequired: false
    property bool echoResponse: false

    // ── Greetd Handlers ──────────────────────────────────────────────────────

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            root.authMessage = message
            root.authError = error
            root.responseRequired = responseRequired
            root.echoResponse = echoResponse
            if (responseRequired) passwordInput.forceActiveFocus()
        }

        function onAuthFailure(message) {
            root.authMessage = "Incorrect password"
            root.authError = true
            root.responseRequired = false
            passwordInput.text = ""
            usernameInput.forceActiveFocus()
        }

        function onReadyToLaunch() {
            Greetd.launch(["niri-session"], [], true)
        }

        function onError(error) {
            root.authMessage = "Error: " + error
            root.authError = true
        }
    }

    // ── Login Logic ──────────────────────────────────────────────────────────

    function startSession() {
        if (root.currentUser.trim() === "") return
        root.authMessage = ""
        root.authError = false
        Greetd.createSession(root.currentUser.trim())
    }

    function submitPassword() {
        if (!root.responseRequired) return
        Greetd.respond(passwordInput.text)
        passwordInput.text = ""
    }

    function cancelSession() {
        Greetd.cancelSession()
        root.authMessage = ""
        root.authError = false
        root.responseRequired = false
        passwordInput.text = ""
        usernameInput.forceActiveFocus()
    }

    // ── UI ───────────────────────────────────────────────────────────────────

    PanelWindow {
        visible: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }
        color: root.c.bg0

        Component.onCompleted: usernameInput.forceActiveFocus()

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12
            width: 320

            // ── Clock ────────────────────────────────────────────────────────
            Text {
                id: clock
                Layout.alignment: Qt.AlignHCenter
                color: root.c.fg0
                font.pixelSize: 52
                font.family: root.font.ui

                property var now: new Date()
                text: now.toLocaleTimeString(Qt.locale(), "hh:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.now = new Date()
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: root.c.fg2
                font.pixelSize: 13
                font.family: root.font.ui
                text: clock.now.toLocaleDateString(Qt.locale(), "dddd, MMMM d")
            }

            // spacer
            Item { Layout.preferredHeight: 24 }

            // ── Username ─────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: root.c.bg1
                border.width: 1
                border.color: usernameInput.activeFocus ? root.c.accent0 : root.c.border0

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.c.fg0
                    font.pixelSize: 14
                    font.family: root.font.ui
                    placeholderText: "username"
                    placeholderTextColor: root.c.fg2
                    selectByMouse: true
                    enabled: !root.responseRequired

                    onTextChanged: root.currentUser = text
                    onAccepted: root.startSession()
                }
            }

            // ── Password ─────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: root.c.bg1
                border.width: 1
                border.color: passwordInput.activeFocus ? root.c.accent0 : root.c.border0
                visible: root.responseRequired

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.c.fg0
                    font.pixelSize: 14
                    font.family: root.font.ui
                    placeholderText: "password"
                    placeholderTextColor: root.c.fg2
                    echoMode: root.echoResponse ? TextInput.Normal : TextInput.Password
                    selectByMouse: true

                    onAccepted: root.submitPassword()
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.cancelSession()
                            event.accepted = true
                        }
                    }
                }
            }

            // ── Status message ───────────────────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.authMessage
                color: root.authError ? root.c.red0 : root.c.fg2
                font.pixelSize: 12
                font.family: root.font.ui
                visible: root.authMessage !== ""
            }

            // ── Button ───────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: loginMouse.containsMouse ? root.c.accent0 : root.c.bg2
                border.width: 1
                border.color: root.c.border0

                Text {
                    anchors.centerIn: parent
                    text: root.responseRequired ? "Login" : "Next"
                    color: loginMouse.containsMouse ? root.c.bg0 : root.c.fg0
                    font.pixelSize: 14
                    font.family: root.font.ui
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.responseRequired ? root.submitPassword() : root.startSession()
                }
            }
        }
    }
}
