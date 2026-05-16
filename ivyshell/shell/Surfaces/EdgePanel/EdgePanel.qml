pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Reusables.Theme
import qs.Reusables.Components

PanelWindow {
    id: root
    aboveWindows: true  

    // ── REQUIRED ─────────────────────────────────────────────────────────────
    required property var screen
    property string edge: "top"
    property string variant: "default"

    // ── DEBUG ────────────────────────────────────────────────────────────────
    property bool debug: true
    property bool debugNoAnimation: true

    // ── OVERRIDES ────────────────────────────────────────────────────────────
    property var overrideCornerRadius:     null
    property var overrideExclusiveZone:    null
    property var overrideAnimDuration:     null
    property var overrideExpandedSize:     null
    property var overrideCollapsedSize:    null

    property bool expanded: true

    // ── VARIANTS ─────────────────────────────────────────────────────────────
    readonly property var _variants: ({
        bar: {
            cornerRadius: 0,
            exclusiveZone: -1,
            animDuration: 0,
            expandedSize: -1,
            collapsedSize: -1,
            showCorners: false,
        },
        dock: {
            cornerRadius: 12,
            exclusiveZone: 0,
            animDuration: 180,
            expandedSize: -1,
            collapsedSize: 2,
            showCorners: true,
        },
        panel: {
            cornerRadius: 12,
            exclusiveZone: 0,
            animDuration: 150,
            expandedSize: -1,
            collapsedSize: 0,
            showCorners: true,
        },
        default: {
            cornerRadius: 10,
            exclusiveZone: 0,
            animDuration: 150,
            expandedSize: -1,
            collapsedSize: 0,
            showCorners: true,
        },
    })

    readonly property var _cfg: _variants[variant] ?? _variants["default"]

    readonly property real _cornerRadius: overrideCornerRadius ?? _cfg.cornerRadius
    readonly property int  _animDuration: overrideAnimDuration ?? _cfg.animDuration
    readonly property bool _showCorners:  _cfg.showCorners

    // ── AXIS ─────────────────────────────────────────────────────────────────
    readonly property bool _isHorizontal: edge === "top" || edge === "bottom"
    readonly property bool _isTop: edge === "top"
    readonly property bool _isBottom: edge === "bottom"
    readonly property bool _isLeft: edge === "left"
    readonly property bool _isRight: edge === "right"

    // ── CONTENT SIZE (SAFE) ──────────────────────────────────────────────────
    readonly property real _contentSize: _isHorizontal
        ? Math.max(_contentContainer.implicitHeight, 1)
        : Math.max(_contentContainer.implicitWidth, 1)

    readonly property real _collapsedSize:
        (overrideCollapsedSize ?? _cfg.collapsedSize) < 0
        ? _contentSize
        : (overrideCollapsedSize ?? _cfg.collapsedSize)

    readonly property real _expandedSize:
        (overrideExpandedSize ?? _cfg.expandedSize) < 0
        ? _contentSize
        : (overrideExpandedSize ?? _cfg.expandedSize)

    readonly property real _currentSize:
        expanded ? _expandedSize : _collapsedSize

    // ── WINDOW SETUP ─────────────────────────────────────────────────────────
    screen: root.screen
    color: debug ? "#220000ff" : "transparent"

    implicitWidth:  _isHorizontal ? (root.screen?.width ?? 0) : _expandedSize
    implicitHeight: _isHorizontal ? _expandedSize : (root.screen?.height ?? 0)

    anchors.top: _isTop
    anchors.bottom: _isBottom
    anchors.left: _isLeft
    anchors.right: _isRight

    exclusiveZone: {
        const z = overrideExclusiveZone ?? _cfg.exclusiveZone
        if (z === -1) return _contentSize
        return z
    }

    // ── MASK ─────────────────────────────────────────────────────────────────
    mask: Region {
        item: _visibleRegion
    }

    Rectangle {
        id: _visibleRegion
        visible: root.debug
        color: "#55ff0000"

        x:      _isRight  ? root.width - _slideOffset : 0
        y:      _isBottom ? root.height - _slideOffset : 0
        width:  _isHorizontal ? root.width  : _slideOffset
        height: _isHorizontal ? _slideOffset : root.height
    }

    // ── SLIDE ────────────────────────────────────────────────────────────────
    property real _slideOffset: _currentSize

    Behavior on _slideOffset {
        enabled: !debugNoAnimation
        NumberAnimation {
            duration: root._animDuration
            easing.type: Easing.InOutQuad
        }
    }

    // ── CONTENT CONTAINER ────────────────────────────────────────────────────
    Item {
        id: _contentContainer

        x: _isLeft  ? _slideOffset - implicitWidth
         : _isRight ? root.width - _slideOffset
         : 0

        y: _isTop    ? _slideOffset - implicitHeight
         : _isBottom ? root.height - _slideOffset
         : 0

        implicitWidth:  _isHorizontal
            ? root.width
            : Math.max(childrenRect.width, 1)

        implicitHeight: _isHorizontal
            ? Math.max(childrenRect.height, 1)
            : root.height

        width:  implicitWidth
        height: implicitHeight

        // 🟢 DEBUG: content area
        Rectangle {
            anchors.fill: parent
            color: root.debug ? "#3300ff00" : "transparent"
        }
    }

    // ── CORNERS ──────────────────────────────────────────────────────────────
    Loader {
        active: root._showCorners && root._slideOffset > 0
        sourceComponent: _cornersComponent
    }

    Component {
        id: _cornersComponent
        Item {
            anchors.fill: parent

            InnerCorner {
                radius: root._cornerRadius
                color: Theme.color.bg0

                x: _isLeft   ? root._slideOffset
                 : _isRight  ? root.width - root._slideOffset - radius
                 : 0

                y: _isTop    ? root._slideOffset
                 : _isBottom ? root.height - root._slideOffset - radius
                 : 0

                rotation: _isTop ? 180
                         : _isBottom ? 270
                         : _isLeft ? 90
                         : 0
            }

            InnerCorner {
                radius: root._cornerRadius
                color: Theme.color.bg0

                x: _isLeft   ? root._slideOffset
                 : _isRight  ? root.width - root._slideOffset - radius
                 : root.width - radius

                y: _isTop    ? root._slideOffset
                 : _isBottom ? root.height - root._slideOffset - radius
                 : root.height - radius

                rotation: _isTop ? 270
                         : _isBottom ? 180
                         : _isLeft ? 180
                         : 90
            }
        }
    }

    // ── OUTLINE DEBUG ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.debug ? "cyan" : "transparent"
        border.width: 1
    }
}