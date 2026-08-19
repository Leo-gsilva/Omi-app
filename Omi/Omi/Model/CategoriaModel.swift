//
//  CategoriaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import CoreData

enum CategoriaReceita: String, CaseIterable, Identifiable {
    case cafeDaManha = "Café da Manhã"
    case almoco = "Almoço"
    case jantar = "Jantar"
    case sobremesa = "Sobremesa"
    case lanches = "Lanches"

    var id: String {
        rawValue
    }
}
