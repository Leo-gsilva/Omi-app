//
//  DetalheModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
enum TipoDetalhe {
    case tempo(Int16)
    case pessoas(String)
    
    var textoFormatado: String {
        switch self {
        case .tempo(let minutos):
            return "\(minutos) min"
        case .pessoas(let quantidade):
            return "\(quantidade) pessoas"
        }
    }
    
    var iconePadrao: String {
        switch self {
        case .tempo:
            return "clock"
        case .pessoas:
            return "chart.pie"
        }
    }
}
