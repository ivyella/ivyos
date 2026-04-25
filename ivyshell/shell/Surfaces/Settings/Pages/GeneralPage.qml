pragma ComponentBehavior: Bound  
import QtQuick  
import QtQuick.Layouts  
import QtQuick.Controls  
import qs.Reusables.Theme  
import qs.Reusables.MdIcons  
import qs.Services.Config  
  
Item {  
    id: root  
  
    function enumerateFonts() {
        const keywords = ["thin", "light", "regular", "medium", "semibold", "bold",
                          "extrabold", "black", "italic", "oblique", "condensed",
                          "expanded", "narrow", "wide", "heavy", "ultra"]
        const seen = new Set()
        const fonts = []

        for (const name of Qt.fontFamilies()) {
            if (name.startsWith(".")) continue
            const lower = name.toLowerCase()
            const isVariant = keywords.some(k => {
                const idx = lower.lastIndexOf(" " + k)
                return idx !== -1 && idx >= lower.length - k.length - 1
            })
            if (isVariant) continue
            if (seen.has(lower)) continue
            seen.add(lower)
            fonts.push(name)
        }

        fonts.sort()
        fonts.unshift("Default")
        return fonts
    }

    ColumnLayout {  
        anchors.fill:    parent  
        anchors.margins: Theme.spacing.lg  
        spacing:         Theme.spacing.md  
  
        // ── Header ────────────────────────────────────────────────────────────  
        Rectangle {  
            Layout.fillWidth: true  
            implicitHeight:   headerCol.implicitHeight + Theme.spacing.lg * 2  
            color:            Theme.color.bg0  
            radius:           Theme.radius.md  
  
            ColumnLayout {  
                id:                headerCol  
                anchors.centerIn:  parent  
                spacing:           Theme.spacing.xs  
  
                Text {  
                    Layout.alignment: Qt.AlignHCenter  
                    text:             "General"  
                    color:            Theme.color.fg0  
                    font.pixelSize:   Theme.font.lg  
                    font.family:      Theme.font.ui  
                    font.weight:      Font.Bold  
                }  
  
                Text {  
                    Layout.alignment: Qt.AlignHCenter  
                    text:             "Fonts, scaling and appearance"  
                    color:            Theme.color.fg1  
                    font.pixelSize:   Theme.font.sm  
                    font.family:      Theme.font.ui  
                }  
            }  
        }  
  
        // ── Content ───────────────────────────────────────────────────────────  
        Rectangle {  
            Layout.fillWidth:  true  
            Layout.fillHeight: true  
            color:             Theme.color.bg0  
            radius:            Theme.radius.md  
  
            ColumnLayout {  
                anchors.fill:    parent  
                anchors.margins: Theme.spacing.lg  
                spacing:         Theme.spacing.lg  
  
                // ── Fonts ─────────────────────────────────────────────────────  
                Text {  
                    text:           "Fonts"  
                    color:          Theme.color.accent0  
                    font.pixelSize: Theme.font.md  
                    font.family:    Theme.font.ui  
                    font.weight:    Font.Bold  
                }  
  
                // UI Font  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "UI Font"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.ui  
                    }  
  
                    ComboBox {  
                        id: uiFontComboBox  
                        Layout.fillWidth: true  
                        model:        root.enumerateFonts()
                        currentIndex: model.indexOf(Config.fontUi)  
                        onActivated:  Config.setFont(currentText, Config.fontMono, Config.fontScale, Config.fontWeight)  
  
                        Connections {  
                            target: Config  
                            function onFontUiChanged() {  
                                uiFontComboBox.currentIndex = uiFontComboBox.model.indexOf(Config.fontUi)  
                            }  
                        }  
  
                        contentItem: Text {  
                            leftPadding:       Theme.spacing.sm  
                            text:              parent.displayText  
                            color:             Theme.color.fg0  
                            font.pixelSize:    Theme.font.sm  
                            font.family:       parent.currentText || Theme.font.ui  
                            verticalAlignment: Text.AlignVCenter  
                        }  
  
                        background: Rectangle {  
                            radius:       Theme.radius.md  
                            color:        Theme.color.bg2  
                            border.color: Theme.color.border0  
                            border.width: 1  
                        }

                        popup: Popup {
                            width:  parent.width
                            height: 220
                            y:      parent.height + 4

                            background: Rectangle {
                                radius:       Theme.radius.md
                                color:        Theme.color.bg2
                                border.color: Theme.color.border0
                                border.width: 1
                            }

                            contentItem: ListView {
                                clip:  true
                                model: uiFontComboBox.delegateModel
                                ScrollBar.vertical: ScrollBar {}
                            }
                        }
                    }  
                }  
  
                // Mono Font  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "Monospace Font"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.mono  
                    }  
  
                    ComboBox {  
                        id: monoFontComboBox  
                        Layout.fillWidth: true  
                        model:        root.enumerateFonts()
                        currentIndex: model.indexOf(Config.fontMono)  
                        onActivated:  Config.setFont(Config.fontUi, currentText, Config.fontScale, Config.fontWeight)  

                        Connections {  
                            target: Config  
                            function onFontMonoChanged() {  
                                monoFontComboBox.currentIndex = monoFontComboBox.model.indexOf(Config.fontMono)  
                            }  
                        }  
  
                        contentItem: Text {  
                            leftPadding:       Theme.spacing.sm  
                            text:              parent.displayText  
                            color:             Theme.color.fg0  
                            font.pixelSize:    Theme.font.sm  
                            font.family:       parent.currentText || Theme.font.mono  
                            verticalAlignment: Text.AlignVCenter  
                        }  
  
                        background: Rectangle {  
                            radius:       Theme.radius.md  
                            color:        Theme.color.bg2  
                            border.color: Theme.color.border0  
                            border.width: 1  
                        }

                        popup: Popup {
                            width:  parent.width
                            height: 220
                            y:      parent.height + 4
                            
                            background: Rectangle {
                                radius:       Theme.radius.md
                                color:        Theme.color.bg2
                                border.color: Theme.color.border0
                                border.width: 1
                            }

                            contentItem: ListView {
                                clip:  true
                                model: monoFontComboBox.delegateModel
                                ScrollBar.vertical: ScrollBar {}
                            }
                        }
                    }  
                }  
  
                // ── Sliders ───────────────────────────────────────────────────  
                Text {  
                    text:           "Scaling"  
                    color:          Theme.color.accent0  
                    font.pixelSize: Theme.font.md  
                    font.family:    Theme.font.ui  
                    font.weight:    Font.Bold  
                    topPadding:     Theme.spacing.sm  
                }  
  
                // Font Scale  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "Font Scale"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.ui  
                    }  
  
                    Slider {  
                        Layout.fillWidth: true  
                        from:     0.5  
                        to:       2.0  
                        stepSize: 0.05  
                        value:    Config.fontScale  
                        onMoved:  Config.setFont(Config.fontUi, Config.fontMono, value, Config.fontWeight)  
                    }  
  
                    Text {  
                        text:           Config.fontScale.toFixed(2) + "x"  
                        color:          Theme.color.fg1  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.mono  
                        Layout.preferredWidth: 40  
                    }  
                }  
  
                // Font Weight  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "Font Weight"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.ui  
                    }  
  
                    Slider {  
                        Layout.fillWidth: true  
                        from:     100  
                        to:       900  
                        stepSize: 100  
                        value:    Config.fontWeight  
                        onMoved:  Config.setFont(Config.fontUi, Config.fontMono, Config.fontScale, value)  
                    }  
  
                    Text {  
                        text:           Config.fontWeight  
                        color:          Theme.color.fg1  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.mono  
                        Layout.preferredWidth: 40  
                    }  
                }  
  
                // UI Scale  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "UI Scale"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.ui  
                    }  
  
                    Slider {  
                        Layout.fillWidth: true  
                        from:     0.5  
                        to:       2.0  
                        stepSize: 0.05  
                        value:    Config.uiScale  
                        onMoved:  Config.setUiScale(value)  
                    }  
  
                    Text {  
                        text:           Config.uiScale.toFixed(2) + "x"  
                        color:          Theme.color.fg1  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.mono
                        Layout.preferredWidth: 40  
                    }  
                }  
  
                // Border Radius  
                RowLayout {  
                    Layout.fillWidth: true  
                    spacing: Theme.spacing.md  
  
                    Text {  
                        Layout.preferredWidth: 120  
                        text:           "Border Radius"  
                        color:          Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.ui  
                    }  
  
                    Slider {  
                        Layout.fillWidth: true  
                        from:     0  
                        to:       32  
                        stepSize: 1  
                        value:    Config.borderRadius  
                        onMoved:  Config.setBorderRadius(value)  
                    }  
  
                    Text {  
                        text:           Config.borderRadius + "px"  
                        color:          Theme.color.fg1  
                        font.pixelSize: Theme.font.sm  
                        font.family:    Theme.font.mono  
                        Layout.preferredWidth: 40  
                    }  
                }  
  
                Item { Layout.fillHeight: true }  
            }  
        }  
    }  
}