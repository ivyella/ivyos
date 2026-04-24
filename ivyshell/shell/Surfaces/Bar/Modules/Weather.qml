import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services

Rectangle {
    color:         Theme.color.bg2
    radius:        Theme.radius.lg
    height:        Theme.height.sm
    implicitWidth: weatherLayout.implicitWidth + Theme.padding.md
    visible:       Weather.ready

    RowLayout {
        id: weatherLayout
        spacing: Theme.spacing.sm

        Rectangle {
            color:         Theme.color.bg3
            height:        Theme.height.sm
            radius:        Theme.radius.lg
            implicitWidth: weatherIcon.implicitWidth + Theme.padding.sm * 2

            MdIcons {
                id:               weatherIcon
                anchors.centerIn: parent
                text:             Weather.icon
                iconSize:         Theme.icon.sm
                color:            Theme.color.accent0
                fill:             1
            }
        }

        Text {
            text:           Weather.feelsLike + Weather.unitSymbol
            color:          Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family:    Theme.font.ui
            font.weight:    Theme.font.normal
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    Weather.toggleUnit()
    }
}