//
//  OmiApp.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import SwiftUI
import SwiftData

@main
struct OmiApp: App {
    @State private var router = AppRouter()
    
    // Le do UserDefaults quando é finalizado pelo finalizarOnboarding()
    // @AppStorage observa a notificação de mudança
    @AppStorage("onboardingConcluido") private var onboardingConcluido: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                Group{
                    if onboardingConcluido {
                        TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: PersistenceSwiftData.container.mainContext)))
                    } else {
                        OnboardingView()
                    }
                }
                .navigationDestination(for: Rota.self) { rota in
                    RotasDestinoView(rota: rota)
                }
            }
            .modelContainer(PersistenceSwiftData.container)
            .environment(router)
            .sheet(item: $router.sheetAtual) { rota in
                RotasDestinoView(rota: rota)
                    .modelContainer(PersistenceSwiftData.container)
            }
        }
    }
}
