//
//  ContentView.swift
//  SwiftMvGql
//
//  Created by Tomoki Kobayashi on 2024/07/06.
//

import Model
import SwiftUI
import SWGraphQL

public struct ContentView: View {
    @StateObject private var query: Query = .init(query: GraphQL.AllFilmsQuery())
    
    public var body: some View {
        ZStack {
            VStack {
                if query.state.isLoading {
                    Text("Loading ...")
                }
                
                if let error = query.state.error {
                    Text(error.localizedDescription)
                }
                
                List(query.state.data?.allFilms?.films ?? [], id: \.hashValue) { film in
                    Text(film?.title ?? "nil")
                }
                .refreshable {
                    query.update()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
