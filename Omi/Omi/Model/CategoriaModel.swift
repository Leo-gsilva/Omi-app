//
//  CategoriaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import SwiftUI

enum CategoriaReceita: String, CaseIterable, Identifiable {
    case cafeDaManha = "Café da Manhã"
    case refeicao = "Refeição"
    case saudavel = "Saudável"
    case sobremesa = "Sobremesa"
    case lanche = "Lanche"

    var id: String {
        rawValue
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
