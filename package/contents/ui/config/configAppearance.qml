import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksvg as KSvg

import "code/tools.js" as Tools

KCM.SimpleKCM {
	id: configAppearance
	Layout.fillWidth: false
	
	property alias cfg_fontSize: fontSize.value
	property string cfg_iconOnline: plasmoid.configuration.iconOnline
	property string cfg_iconOffline: plasmoid.configuration.iconOffline
	
	GridLayout {
		columns: 2
		
		PlasmaComponents.Label {
			text: i18n("Font size:")
		}
		
		QQC2.SpinBox {
			id: fontSize
			implicitWidth: onlineIconButton.width
			from: 1
			to: 32
		}
		
		
		PlasmaComponents.Label {
			text: i18n("Online icon:")
		}
		
		QQC2.Button {
			id: onlineIconButton

			Kirigami.FormData.label: i18n("Icon:")

			implicitWidth: onlinePreviewFrame.width + Kirigami.Units.smallSpacing * 2
			implicitHeight: onlinePreviewFrame.height + Kirigami.Units.smallSpacing * 2
			hoverEnabled: true

			Accessible.name: i18nc("@action:button", "Choose an icon for Online Status")
			Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_iconOnline)
			Accessible.role: Accessible.ButtonMenu

			QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
			QQC2.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_iconOnline)
			QQC2.ToolTip.visible: onlineIconButton.hovered && cfg_iconOnline.length > 0

			KIconThemes.IconDialog {
				id: onlineIconDialog
				onIconNameChanged: {
					cfg_iconOnline = iconName || Tools.defaultIconName;
				}
			}

			onPressed: onlineIconMenu.opened ? onlineIconMenu.close() : onlineIconMenu.open()

			KSvg.FrameSvgItem {
				id: onlinePreviewFrame
				anchors.centerIn: parent
				imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
						? "widgets/panel-background" : "widgets/background"
				width: Kirigami.Units.iconSizes.medium + fixedMargins.left + fixedMargins.right * 2
				height: Kirigami.Units.iconSizes.medium + fixedMargins.top + fixedMargins.bottom

				Kirigami.Icon {
					anchors.centerIn: parent
					width: Kirigami.Units.iconSizes.medium
					height: width
					source: Tools.iconOrDefault(Plasmoid.formFactor, cfg_iconOnline)
				}
			}

			QQC2.Menu {
				id: onlineIconMenu

				// Appear below the button
				y: parent.height

				QQC2.MenuItem {
					text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
					icon.name: "document-open-folder"
					Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Online Status")
					onClicked: onlineIconDialog.open()
				}
				QQC2.MenuItem {
					text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
					icon.name: "edit-clear"
					enabled: cfg_iconOnline !== Tools.defaultIconName
					onClicked: cfg_iconOnline = Tools.defaultIconName
				}
				QQC2.MenuItem {
					text: i18nc("@action:inmenu", "Remove icon")
					icon.name: "delete"
					enabled: cfg_iconOnline !== "" && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
					onClicked: cfg_iconOnline = ""
				}
			}
		}
		
		PlasmaComponents.Label {
			text: i18n("Offline icon:")
		}
		
		QQC2.Button {
			id: offlineIconButton

			Kirigami.FormData.label: i18n("Icon:")

			implicitWidth: offlinePreviewFrame.width + Kirigami.Units.smallSpacing * 2
			implicitHeight: offlinePreviewFrame.height + Kirigami.Units.smallSpacing * 2
			hoverEnabled: true

			Accessible.name: i18nc("@action:button", "Choose an icon for Offline Status")
			Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_iconOffline)
			Accessible.role: Accessible.ButtonMenu

			QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
			QQC2.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_iconOffline)
			QQC2.ToolTip.visible: offlineIconButton.hovered && cfg_iconOffline.length > 0

			KIconThemes.IconDialog {
				id: offlineIconDialog
				onIconNameChanged: {
					cfg_iconOffline = iconName || Tools.defaultIconName;
				}
			}

			onPressed: offlineIconMenu.opened ? offlineIconMenu.close() : offlineIconMenu.open()

			KSvg.FrameSvgItem {
				id: offlinePreviewFrame
				anchors.centerIn: parent
				imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
						? "widgets/panel-background" : "widgets/background"
				width: Kirigami.Units.iconSizes.medium + fixedMargins.left + fixedMargins.right * 2
				height: Kirigami.Units.iconSizes.medium + fixedMargins.top + fixedMargins.bottom

				Kirigami.Icon {
					anchors.centerIn: parent
					width: Kirigami.Units.iconSizes.medium
					height: width
					source: Tools.iconOrDefault(Plasmoid.formFactor, cfg_iconOffline)
				}
			}

			QQC2.Menu {
				id: offlineIconMenu

				// Appear below the button
				y: parent.height

				QQC2.MenuItem {
					text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
					icon.name: "document-open-folder"
					Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Offline Status")
					onClicked: offlineIconDialog.open()
				}
				QQC2.MenuItem {
					text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
					icon.name: "edit-clear"
					enabled: cfg_iconOffline !== Tools.defaultIconName
					onClicked: cfg_iconOffline = Tools.defaultIconName
				}
				QQC2.MenuItem {
					text: i18nc("@action:inmenu", "Remove icon")
					icon.name: "delete"
					enabled: cfg_iconOffline !== "" && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
					onClicked: cfg_iconOffline = ""
				}
			}
		}
	}
}
