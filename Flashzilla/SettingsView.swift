//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Paul Richardson on 30.10.2020.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		NavigationView {
			List {
				Text("Settings")
			}
			.navigationBarTitle(Text("Settings"))
			.navigationBarItems(trailing: Button("Done", action: dismiss))
			
		}
	}
	
	func dismiss() {
		presentationMode.wrappedValue.dismiss()
	}
	
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
