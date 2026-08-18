//
//  OmiApp.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import SwiftUI
import CoreData

@main
struct OmiApp: App {
    // In iOS 17 with @Observable, the App should own the ViewModel using @State.
    // We initialize the context, repo, and ViewModel all in one clean line.
    @State private var viewModel = IngredientesViewModel(
        repo: ReceitasRepo(context: PersistenceController.shared.container.viewContext)
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
