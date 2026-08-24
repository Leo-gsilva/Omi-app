//
//  CategoriaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI

enum CategoriaReceita: String, CaseIterable, Identifiable {
    case sobremesa
    case refeicao
    case saudavel
    case lanche
    case cafeDaManha

    var id: String { rawValue }

    var nomeExibicao: String {
        switch self {
        case .sobremesa: return "Sobremesa"
        case .refeicao: return "Refeição"
        case .saudavel: return "Saudável"
        case .lanche: return "Lanche"
        case .cafeDaManha: return "Café da Manhã"
        }
    }

    // Ajuste os RGB pra bater com os hex exatos do Figma se tiver acesso a eles
    var cor: Color {
        switch self {
        case .sobremesa: return Color(.corSobremesa)
        case .refeicao: return Color(.corRefeicao)
        case .saudavel: return Color(.corSaudavel)
        case .lanche: return Color(.corLanche)
        case .cafeDaManha: return Color(.corCafe)
        }
    }
}
