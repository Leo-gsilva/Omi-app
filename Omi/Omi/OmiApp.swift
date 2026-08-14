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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
