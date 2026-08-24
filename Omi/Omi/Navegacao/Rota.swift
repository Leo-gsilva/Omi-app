//
//  NavigationModel.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//
import Foundation

enum Rota: Hashable, Identifiable {
    case telaInicial
    case detalheReceita(ReceitaModel)
    
    // Add an optional recipe to the route
    case criarOuEditarReceita(ReceitaModel?)
    case onboarding
    
    // Required for Identifiable so .sheet() works
    var id: String {
        switch self {
        case .telaInicial: return "telaInicial"
        case .detalheReceita(let r): return "detalhe-\(r.id)"
        case .criarOuEditarReceita(let r): return "criarEditar-\(r?.id.uuidString ?? "novo")"
        case .onboarding: return "onboarding"
        }
    }
}
