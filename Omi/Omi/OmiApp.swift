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
        @State private var router = AppRouter()

        var body: some Scene {
            WindowGroup {
                NavigationStack(path: $router.path) {
                    TeladeApresentação()
                        .navigationDestination(for: Rota.self) { rota in
                            RotasDestinoView(rota: rota)
                        }
                }
                .environment(\.managedObjectContext, persistentController.container.viewContext)
                .environment(router)
//                ContentViewCoreDataTestes()
//                    .environment(\.managedObjectContext, persistentController.container.viewContext)
            }
        }
    }
