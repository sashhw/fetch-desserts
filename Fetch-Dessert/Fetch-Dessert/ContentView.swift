//
//  ContentView.swift
//  Fetch-Dessert
//
//  Created by Sasha Walkowski on 10/31/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var desserts: [Dessert] = []
    @State private var selectedDessert: Dessert?
    @State private var dessertDetails: DessertDetails?
    @State private var isPresented = false

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Text("Desserts")
                    .font(.largeTitle)

                Image(systemName: "birthday.cake")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
            List {
                ForEach(desserts, id: \.self) { dessert in
                    HStack(alignment: .center) {
                        AsyncImage(url: URL(string: dessert.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)

                        Text(dessert.name)
                            .font(.body)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .frame(width: 15)
                            .aspectRatio(contentMode: .fit)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let id = dessert.id {
                            selectedDessert = dessert
                            Task {
                                await fetchDetails(id: id)
                            }
                            isPresented = true
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                Task {
                    do {
                        let fetchedDesserts = try await viewModel.fetch()
                        desserts = fetchedDesserts.sorted {
                            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                if let dessertDetails = dessertDetails {
                    DetailSheetView(details: dessertDetails, isPresented: $isPresented)
                }
            }
        }
    }

    func fetchDetails(id: String) async {
        do {
            let details = try await viewModel.fetchDetails(id: id)
            dessertDetails = details
        } catch {
            print("Error fetching details: \(error)")
        }
    }

}

struct DetailSheetView: View {
    let details: DessertDetails
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: details.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(5)

                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 14, height: 14)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }

                Text(details.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Ingredients")
                        .font(.headline)
                        .bold()

                    Text(details.joinedIngredientsMeasurements)
                        .font(.body)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.secondary)
                        .opacity(0.1)
                }
                .padding(.horizontal, 60)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Instructions")
                        .font(.headline)

                    Text(details.instructionsWithBreak)
                        .font(.subheadline)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.secondary)
                        .opacity(0.1)
                }
                .padding(15)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
