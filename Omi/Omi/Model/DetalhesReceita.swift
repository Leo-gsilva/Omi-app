//
//  DetalhesReceita.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 26/08/26.
//
enum DetalheReceita {
    case tempo(Int16)
    case pessoas(String)

    var texto: String {
        switch self {
        case .tempo(let minutos): return "\(minutos) min"
        case .pessoas(let qtd): return "\(qtd) pessoas"
        }
    }
}
