//
//  ContentView.swift
//  Flashzilla
//
//  Created by Paul Richardson on 21.10.2020.
//

import SwiftUI

extension View {
	func stacked(at position: Int, in total: Int) -> some View {
		let offset = CGFloat(total - position)
		return self.offset(CGSize(width: 0, height: offset * 10))
	}
}

struct ContentView: View {
	
	static let timeAllowed = 100
	
	@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
	@Environment(\.accessibilityEnabled) var accessibilityEnabled
	@State private var cards = [Card]()
	@State private var timeRemaining = timeAllowed
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	@State private var isActive = true
	@State private var showingEditScreen = false
	@State private var showingSettings = false

	var body: some View {
		ZStack {
			// we need to put the image in a geometry reader and constrain the frame width in order to keep everything visible on smaller screens
			GeometryReader { geometry in
				Image(decorative: "background")
					.resizable()
					.scaledToFill()
					.edgesIgnoringSafeArea(.all)
					.frame(maxWidth: geometry.size.width)
			}
			
			VStack {
				if timeRemaining > 0 {
					Text("Time: \(timeRemaining)")
						.font(.largeTitle)
						.foregroundColor(.white)
						.padding(.horizontal, 20)
						.padding(.vertical, 5)
						.background(Capsule()
													.fill(Color.black)
													.opacity(0.75)
							)
					
					ZStack {
						ForEach(0..<cards.count, id: \.self) { index in
							CardView(card: self.cards[index]) {
								withAnimation {
									self.removeCard(at: index)
								}
							}
							.stacked(at: index, in: self.cards.count)
							.allowsHitTesting(index == self.cards.count - 1)
							.accessibility(hidden: index < self.cards.count - 1)
						}
					}
					.allowsHitTesting(timeRemaining > 0)
				} else {
					Text("Time expired!")
						.font(.largeTitle)
						.foregroundColor(.white)
						.padding(.horizontal, 20)
						.padding(.vertical, 5)
						.background(Capsule()
													.fill(Color.red)
													.opacity(0.75)
						)
				}
				if cards.isEmpty || timeRemaining == 0 {
					Button("Start Again", action: resetCards)
						.padding()
						.background(Color.white)
						.foregroundColor(.black)
						.clipShape(Capsule())
				}
			}
			
			VStack {
				HStack {
					Button(action: {
						self.showingSettings = true
					}) {
						Image(systemName: "gear")
							.padding()
							.background(Color.black.opacity(0.7))
							.clipShape(Circle())
					}
					
					
					Spacer()
					
					Button(action: {
						self.showingEditScreen = true
					}) {
						Image(systemName: "plus.circle")
							.padding()
							.background(Color.black.opacity(0.7))
							.clipShape(Circle())
					}
				}
				
				Spacer()
				
			}
			.foregroundColor(.white)
			.font(.largeTitle)
			.padding()
			
			if differentiateWithoutColor || accessibilityEnabled {
				VStack {
					Spacer()
					
					HStack {
						Button(action: {
							withAnimation {
								self.removeCard(at: self.cards.count - 1)
							}
						}) {
						Image(systemName: "xmark.circle")
							.padding()
							.background(Color.black.opacity(0.7))
							.clipShape(Circle())
						}
						.accessibility(label: Text("Wrong"))
						.accessibility(hint: Text("Mark your answer as being incorrect"))
						
						Spacer()
						
						Button(action: {
							withAnimation {
								self.removeCard(at: self.cards.count - 1)
							}
						}) {
						Image(systemName: "checkmark.circle")
							.padding()
							.background(Color.black.opacity(0.7))
							.clipShape(Circle())
						}
						.accessibility(label: Text("Correct"))
						.accessibility(hint: Text("Mark your answer as being correct"))
					}
					.foregroundColor(.white)
					.font(.largeTitle)
					.padding()
				}
			}
		}
		.onReceive(timer) { time in
			guard self.isActive else { return }
			
			if self.timeRemaining > 0 {
				self.timeRemaining -= 1
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			self.isActive = false
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
			if self.cards.isEmpty == false {
				self.isActive = true
			}
		}
		.sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
			EditCard()
		}
		.sheet(isPresented: $showingSettings, onDismiss: resetCards) {
			SettingsView()
		}
		.onAppear(perform: resetCards)
	}
	
	func removeCard(at index: Int) {
		guard index >= 0 else { return }
		cards.remove(at: index)
		if cards.isEmpty {
			isActive = false
		}
	}
	
	func resetCards() {
		timeRemaining = Self.timeAllowed
		isActive = true
		loadData()
	}
	
	func loadData() {
		if let data = UserDefaults.standard.data(forKey: "Cards") {
			if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
				self.cards = decoded
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
