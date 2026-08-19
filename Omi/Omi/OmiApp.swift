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
        let persistentController = PersistenceController.shared
        //@State private var viewModel = OnboardingViewModel()

        var body: some Scene {
            WindowGroup {
                ContentViewCoreDataTestes()
                    .environment(\.managedObjectContext, persistentController.container.viewContext)
                //TeladeApresentação(viewModel: viewModel)
            }
        }
    }
