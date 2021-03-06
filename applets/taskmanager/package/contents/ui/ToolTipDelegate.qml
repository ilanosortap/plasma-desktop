/*
*   Copyright 2013 by Sebastian Kügler <sebas@kde.org>
*   Copyright 2014 by Martin Gräßlin <mgraesslin@kde.org>
*   Copyright 2016 by Kai Uwe Broulik <kde@privat.broulik.de>
*   Copyright 2017 by Roman Gilg <subdiff@gmail.com>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQml.Models 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

import org.kde.taskmanager 0.1 as TaskManager

PlasmaExtras.ScrollArea {
    property Item parentTask
    property int parentIndex

    property string appName
    property int pidParent
    property bool isGroup

    property var windows
    readonly property bool isWin: windows !== undefined

    property variant icon
    property url launcherUrl
    property bool isLauncher
    property bool isMinimizedParent

    // Needed for generateSubtext()
    property string displayParent
    property string genericName
    property int virtualDesktopParent
    property bool isOnAllVirtualDesktopsParent
    property var activitiesParent
    //
    readonly property bool isVerticalPanel: plasmoid.formFactor == PlasmaCore.Types.Vertical

    Layout.minimumWidth: contentItem.width
    Layout.maximumWidth: Layout.minimumWidth

    Layout.minimumHeight: contentItem.height
    Layout.maximumHeight: Layout.minimumHeight

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int textWidth: theme.mSize(theme.defaultFont).width * 20

    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

    Component.onCompleted: {
        flickableItem.interactive = Qt.binding(function() {
            return isVerticalPanel ? contentItem.height > viewport.height : contentItem.width > viewport.width
        });
    }

    Item {
        id: contentItem
        width: childrenRect.width
        height: childrenRect.height

        ToolTipInstance {
            visible: !isGroup
        }

        Grid {
            rows: !isVerticalPanel
            columns: isVerticalPanel
            flow: isVerticalPanel ? Grid.TopToBottom : Grid.LeftToRight
            spacing: units.largeSpacing

            visible: isGroup

            Repeater {
                id: groupRepeater
                model: DelegateModel {
                    model: tasksModel
                    rootIndex: tasksModel.makeModelIndex(parentIndex, -1)
                    delegate: ToolTipInstance {}
                }
            }
        }
    }
}
