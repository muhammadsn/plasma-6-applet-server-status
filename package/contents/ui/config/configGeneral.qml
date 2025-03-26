import QtQuick
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Dialogs 
import QtQuick.Layouts 
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickAddons
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.tableview as Tables
import org.kde.ksvg as KSvg

import ".."

KCM.SimpleKCM {
	id: configGeneral
	Layout.fillWidth: true
	
	property string cfg_servers: plasmoid.configuration.servers
	
	property int dialogMode: -1
	
	ServersModel {
		id: serversModel
	}

	Component.onCompleted: {
		serversModel.clear();
		
		var servers = JSON.parse(cfg_servers);
		
		for(var i = 0; i < servers.length; i++) {
			serversModel.append(servers[i]);
		}
	}

	RowLayout {
		anchors.fill: parent
		
		Layout.alignment: Qt.AlignTop | Qt.AlignRight
		
		QQC2.TableView {
			id: serversTable
			model: serversModel
			
			anchors.top: parent.top
			anchors.right: buttonsColumn.left
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.rightMargin: 10
			
			 // Remove or fix the commented-out HeaderComponent if necessary
			// Tables.HeaderComponent {
			// 	role: "active"
			// 	width: 20 // Ensure this is an integer
			// 	contentItem: QQC2.CheckBox {
			// 		checked: model.active
			// 		onClicked: {
			// 			model.active = checked;
			// 			cfg_servers = JSON.stringify(getServersArray());
			// 		}
			// 	}
			// }
			
			QQC2.TableViewColumn {
				id: "nameCol"
				role: "name"
				title: "Name"
				width: 100 // Assign a valid integer value for width
			}
			
			Connections {
				target: serversTable
				onCurrentRowChanged: {
					moveUp.enabled = serversTable.currentRow > 0;
					moveDown.enabled = serversTable.currentRow < serversTable.model.count - 1;
				}
				onDoubleClicked: {
					editServer();
				}
			}
		}
		
		ColumnLayout {
			id: buttonsColumn
			
			anchors.top: parent.top
			
			PlasmaComponents.Button {
				text: "Add..."
				iconSource: "list-add"
				
				onClicked: {
					addServer();
				}
			}
			
			PlasmaComponents.Button {
				text: "Edit"
				iconSource: "edit-entry"
				
				onClicked: {
					editServer();
				}
			}
			
			PlasmaComponents.Button {
				text: "Remove"
				iconSource: "list-remove"
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.remove(serversTable.currentRow);
					
					cfg_servers = JSON.stringify(getServersArray());
				}
			}
			
			PlasmaComponents.Button {
				id: moveUp
				text: i18n("Move up")
				iconSource: "go-up"
				enabled: false
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.move(serversTable.currentRow, serversTable.currentRow - 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow - 1);
				}
			}
			
			PlasmaComponents.Button {
				id: moveDown
				text: i18n("Move down")
				iconSource: "go-down"
				enabled: false
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					serversTable.model.move(serversTable.currentRow, serversTable.currentRow + 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow + 1);
				}
			}
		}
	}
	
	Dialog {
		id: serverDialog
		visible: false
		title: "Server"
		standardButtons: StandardButton.Save | StandardButton.Cancel
		
		onAccepted: {
			var itemObject = {
				name: serverName.text,
				hostname: serverHostname.text,
				refreshRate: serverRefreshRate.value,
				method: serverMethod.currentIndex,
				active: serverActive.checked,
				extraOptions: {
					command: serverCommand.text
				}
			};
			
			if(dialogMode == -1) {
				serversModel.append(itemObject);
			} else {
				serversModel.set(dialogMode, itemObject);
			}
			
			cfg_servers = JSON.stringify(getServersArray());
		}

		ColumnLayout {
			GridLayout {
				columns: 2
				
				PlasmaComponents.Label {
					text: "Name:"
				}
				
				QQC2.TextField {
					id: serverName
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				PlasmaComponents.Label {
					text: "Host name:"
				}
				
				QQC2.TextField {
					id: serverHostname
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				PlasmaComponents.Label {
					text: i18n("Refresh rate:")
				}
				
				QQC2.SpinBox {
					id: serverRefreshRate
					suffix: i18n(" seconds")
					from: 1
					to: 3600
				}
				
				
				PlasmaComponents.Label {
					text: i18n("Check method:")
				}
				
				QQC2.ComboBox {
					id: serverMethod
					model: ["Ping", "PingV6", "HTTP 200 OK", "Command"]
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
					onActivated: {
						if(index == 3)
							commandGroup.visible = true
						else
							commandGroup.visible = false
					}
				}
				
				
				PlasmaComponents.Label {
					text: ""
				}
				
				QQC2.CheckBox {
					id: serverActive
					text: i18n("Active")
				}
			}
			
			QQC2.GroupBox {
				id: commandGroup
				title: "Command"
				visible: false
				
				anchors.left: parent.left
				anchors.right: parent.right
					
				QQC2.TextField {
					id: serverCommand
					width: parent.width
				}
				
				PlasmaComponents.Label {
					anchors.top: serverCommand.bottom
					width: parent.width
					wrapMode: Text.WordWrap
					text: i18n("Use %hostname% to pass server's hostname as an argument or option to the executable.")
				}
			}
		}
	}
	
	function addServer() {
		dialogMode = -1;
		
		serverName.text = ""
		serverHostname.text = ""
		serverRefreshRate.value = 60
		serverMethod.currentIndex = 0
		serverActive.checked = true
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function editServer() {
		dialogMode = serversTable.currentRow;
		
		serverName.text = serversModel.get(dialogMode).name
		serverHostname.text = serversModel.get(dialogMode).hostname
		serverRefreshRate.value = serversModel.get(dialogMode).refreshRate
		serverMethod.currentIndex = serversModel.get(dialogMode).method
		serverActive.checked = serversModel.get(dialogMode).active
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function getServersArray() {
		var serversArray = [];
		
		for(var i = 0; i < serversModel.count; i++) {
			serversArray.push(serversModel.get(i));
		}
		
		return serversArray;
	}

}
