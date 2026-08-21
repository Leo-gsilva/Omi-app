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
                if onboardingConcluido {
                    NavigationStack(path: $router.path) {
                        TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: persistentController.container.viewContext)))
                    }
                    .navigationDestination(for: Rota.self) { rota in
                        RotasDestinoView(rota: rota)
                    }
                } else {
                    NavigationStack(path: $router.path) {
                        OnboardingView(viewModel: OnboardingViewModel())
                            .navigationDestination(for: Rota.self) { rota in
                                RotasDestinoView(rota: rota)
                            }
                    }
                }
            }
            .environment(\.managedObjectContext, persistentController.container.viewContext)
            .environment(router)
        }
    }
