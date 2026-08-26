//
//  S.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI

enum FontesApp {
    
    static let titulo = Font.custom(
        "Dosis",
        size: 32,
        relativeTo: .largeTitle
    )
        .weight(.bold)
    
    static let tituloComTexto = Font.custom(
        "Dosis",
        size: 32,
        relativeTo: .largeTitle
    )
        .weight(.semibold)
    
    static let subtitulo = Font.custom(
        "Dosis",
        size: 20,
        relativeTo: .title3
    )
        .weight(.semibold)
    
    
    static let corpo = Font.custom(
        "Dosis",
        size: 17,
        relativeTo: .body
    )
        .weight(.medium)
    
    
    static let ExtraBold = Font.custom(
        "Dosis",
        size: 32,
        relativeTo: .body
    )
        .weight(.heavy)
    
    static let Botao = Font.custom(
        "Dosis",
        size: 16,
        relativeTo: .body
    )
        .weight(.heavy)
    
    static let Semibold = Font.custom(
        "Dosis",
        size: 14,
        relativeTo: .body
    )
        .weight(.semibold)
    
    static let CorpoPreview = Font.custom(
        "Dosis",
        size: 14,
        relativeTo: .body
    )
        .weight(.medium)
}



    
