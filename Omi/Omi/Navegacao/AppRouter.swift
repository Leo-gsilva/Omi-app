//
//  AppRouter.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import Observation
import SwiftUI

@Observable
final class AppRouter {
    var path = NavigationPath()
    
    var sheetAtual: Rota?
    
    func push(_ rota: Rota) {
        path.append(rota)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popATodas() {
        path.removeLast(path.count)
    }
    
    func apresentarSheet(_ rota: Rota) {
        sheetAtual = rota
    }
    
    func fecharSheet() {
        sheetAtual = nil
    }
    
    // não é push ou pop, ele troca a raiz do app inteiro
    func finalizarOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingConcluido")
    }
}
