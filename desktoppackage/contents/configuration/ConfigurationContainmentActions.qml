/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0

Item {
    id: root

    signal configurationChanged
    implicitWidth: mainColumn.implicitWidth
    implicitHeight: mainColumn.implicitHeight

    property var prettyStrings: {
        "LeftButton": i18nd("plasma_shell_org.kde.plasma.desktop", "Left-Button"),
        "RightButton": i18nd("plasma_shell_org.kde.plasma.desktop", "Right-Button"),
        "MidButton": i18nd("plasma_shell_org.kde.plasma.desktop", "Middle-Button"),
        "BackButton": i18nd("plasma_shell_org.kde.plasma.desktop", "Back-Button"),
        "ForwardButton": i18nd("plasma_shell_org.kde.plasma.desktop", "Forward-Button"),

        "wheel:Vertical": i18nd("plasma_shell_org.kde.plasma.desktop", "Vertical-Scroll"),
        "wheel:Horizontal": i18nd("plasma_shell_org.kde.plasma.desktop", "Horizontal-Scroll"),

        "ShiftModifier": i18nd("plasma_shell_org.kde.plasma.desktop", "Shift"),
        "ControlModifier": i18nd("plasma_shell_org.kde.plasma.desktop", "Ctrl"),
        "AltModifier": i18nd("plasma_shell_org.kde.plasma.desktop", "Alt"),
        "MetaModifier": i18nd("plasma_shell_org.kde.plasma.desktop", "Meta")
    }

    function saveConfig() {
        configDialog.currentContainmentActionsModel.save();
    }

    Connections {
        target: configDialog.currentContainmentActionsModel
        onConfigurationChanged: root.configurationChanged()
    }

    GridLayout {
        id: mainColumn
        flow: GridLayout.TopToBottom
        y: 25
        width: parent.width

        Repeater {
            id: actionsRepeater
            model: configDialog.currentContainmentActionsModel

            MouseEventInputButton {
                Layout.column: 0
                Layout.row: index
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                defaultText: {
                    var splitAction = model.action.split(';');

                    var button = splitAction[0];
                    var modifiers = (splitAction[1] || "").split('|').filter(function (item) {
                        return item !== "NoModifier";
                    });

                    var parts = modifiers;
                    modifiers.push(button);

                    return parts.map(function (item) {
                        return prettyStrings[item] || item;
                    }).join(i18nc("Concatenation sign for shortcuts, e.g. Ctrl+Shift", "+"));
                }
                eventString: model.action
                onEventStringChanged: {
                    configDialog.currentContainmentActionsModel.update(index, eventString, model.pluginName);
                }
            }
        }

        Repeater {
            model: configDialog.currentContainmentActionsModel

            QtControls.ComboBox {
                id: pluginsCombo
                Layout.fillWidth: true
                Layout.column: 1
                Layout.row: index
                // both MouseEventInputButton and this ComboBox have fillWidth for a uniform layout
                // however, their implicit sizes is taken into account and they compete against
                // each other for available space. By setting an insane preferredWidth we give
                // ComboBox a greater share of the available space
                Layout.preferredWidth: 9000
                model: configDialog.containmentActionConfigModel
                textRole: "name"
                property bool initialized: false
                Component.onCompleted: {
                    for (var i = 0; i < configDialog.containmentActionConfigModel.count; ++i) {
                        if (configDialog.containmentActionConfigModel.get(i).pluginName == pluginName) {
                            pluginsCombo.currentIndex = i;
                            break;
                        }
                    }
                    pluginsCombo.initialized = true;
                }
                onCurrentIndexChanged: {
                    if (initialized && configDialog.containmentActionConfigModel.get(currentIndex).pluginName != pluginName) {
                        configDialog.currentContainmentActionsModel.update(index, action, configDialog.containmentActionConfigModel.get(currentIndex).pluginName);
                    }
                }
            }
        }

        Repeater {
            model: configDialog.currentContainmentActionsModel

            RowLayout {
                Layout.column: 2
                Layout.row: index

                QtControls.Button {
                    iconName: "configure"
                    width: height
                    enabled: model.hasConfigurationInterface
                    onClicked: {
                        configDialog.currentContainmentActionsModel.showConfiguration(index, this);
                    }
                }
                QtControls.Button {
                    iconName: "dialog-information"
                    width: height
                    onClicked: {
                        configDialog.currentContainmentActionsModel.showAbout(index, this);
                    }
                }
                QtControls.Button {
                    iconName: "list-remove"
                    width: height
                    onClicked: {
                        configDialog.currentContainmentActionsModel.remove(index);
                    }
                }
            }
        }

        MouseEventInputButton {
            anchors.left: parent.left
            defaultText: i18nd("plasma_shell_org.kde.plasma.desktop", "Add Action");
            onEventStringChanged: {
                configDialog.currentContainmentActionsModel.append(eventString, "org.kde.contextmenu");
            }
        }
    }

}
