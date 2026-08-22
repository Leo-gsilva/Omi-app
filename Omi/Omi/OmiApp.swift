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
    
    // Le do UserDefaults quando é finalizado pelo finalizarOnboarding()
    // @AppStorage observa a notificação de mudança
    @AppStorage("onboardingConcluido") private var onboardingConcluido: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                Group{
                    if onboardingConcluido {
                        TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: persistentController.container.viewContext)))
                    } else {
                        OnboardingView()
                    }
                }
                .navigationDestination(for: Rota.self) { rota in
                    RotasDestinoView(rota: rota)
                }
            }
            .environment(\.managedObjectContext, persistentController.container.viewContext)
            .environment(router)
        }
    }
}
