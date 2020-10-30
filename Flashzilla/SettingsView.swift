//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Paul Richardson on 30.10.2020.
//

import SwiftUI

/*
TODO: store the settings
*/

struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode
	@Binding var repeatQuestion: Bool
	
	var body: some View {
		NavigationView {
				HStack {
					Toggle("Repeat the question when the answer is wrong", isOn: $repeatQuestion)
				}
				.padding()
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
		SettingsView(repeatQuestion: .constant(true))
	}
}
