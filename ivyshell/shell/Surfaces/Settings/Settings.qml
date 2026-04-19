pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell.Io  
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Reusables.Theme
import qs.Reusables.MdIcons

import qs.Surfaces.Settings.Pages

Singleton {
    id: root

    property bool visible: false
    property string activePage: "about"

        function toggle(): void {
            root.visible = !root.visible
        }
    

    Window {
        visible: root.visible
        width: 800
        height: 560
        title: "IvyShell Settings"
        color: Theme.color.bg0
        onClosing: root.visible = false
        
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Sidebar ──────────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: Theme.color.bg2
                radius: Theme.radius.lg

                // square off the right corners
                Rectangle {
                    anchors.right: parent.right
                    width: parent.radius
                    height: parent.height
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.md
                    spacing: Theme.spacing.sm

                    // ── Profile ──────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: profileRow.implicitHeight + Theme.spacing.md * 2
                        color: Theme.color.bg2
                        radius: Theme.radius.md

                        RowLayout {
                            id: profileRow
                             anchors.fill: parent
                            anchors.margins: Theme.spacing.md
                            spacing: Theme.spacing.sm

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Theme.color.accent0

                                MdIcons {
                                    id: tmpUserIcon
                                    anchors.centerIn: parent
                                    text: "account_circle"
                                    iconSize: Theme.icon.lg
                                    color: Theme.color.fg1
                                }
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                Text {
                                    text: "Ivy"
                                    color: Theme.color.fg0
                                    font.pixelSize: Theme.font.md
                                    font.family: Theme.font.ui
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "I use NixOS btw :3"
                                    color: Theme.color.fg2
                                    font.pixelSize: Theme.font.xs
                                    font.family: Theme.font.ui
                                }
                            }
                        }
                    }

                    // ── Nav ──────────────────────────────────────────
                    Text {
                        text: "General"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                        leftPadding: Theme.spacing.xs
                    }

                    NavItem {
                        label: "About"
                        page: "about"
                        icon: "info"
                        activePage: root.activePage
                        onActivate: root.activePage = "about"
                    }
                    NavItem {
                        label: "Displays"
                        page: "displays"
                        icon: "monitor"
                        activePage: root.activePage
                        onActivate: root.activePage = "displays"
                    }

                    Text {
                        text: "Appearance"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                        leftPadding: Theme.spacing.xs
                        topPadding: Theme.spacing.xs
                    }

                    NavItem {
                        label: "Theme"
                        page: "theme"
                        icon: "palette"
                        activePage: root.activePage
                        onActivate: root.activePage = "theme"
                    }

                    NavItem {
                        label: "Wallpaper"
                        page: "wallpaper"
                        icon: "wallpaper"
                        activePage: root.activePage
                        onActivate: root.activePage = "wallpaper"
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ── Content area ─────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent
                    sourceComponent : root.activePage === "theme"    ? themePage
                                    : root.activePage === "wallpaper" ? wallpaperPage
                                    : root.activePage === "about" ? aboutPage
                                    : root.activePage === "displays"   ? displaysPage
                                    : aboutPage
                }

                Component { id: themePage; ThemePage {} }
                Component { id: wallpaperPage; WallpaperPage {} }
                Component { id: aboutPage; AboutPage {} }
                Component { id: displaysPage; DisplayPage {} }
            }
        }
    }
}