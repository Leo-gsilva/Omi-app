//
//  ReceitaSwiftDataClasses.swift
//  Omi
//
//  Created by Igor Carrasco on 25/08/26.
//

import Foundation
import SwiftData

@Model
final class Receita {
    var id: UUID
    var titulo: String
    var categoria: String
    var descricao: String
    var imagem: Data?
    var tempoDePreparo: Int16
    var porcoes: String
    var dificuldade: String?
    var dataCriacao: Date
    var dataAtualizacao: Date?
    
    // deleteRule: .cascade -> apagar a receita apaga os passos/relações dela junto
    // Sem precisar configurar "Inverse" manualmente feito no editor do CoreData.
    @Relationship(deleteRule: .cascade, inverse: \PassoReceita.receita)
    var passos: [PassoReceita] = []
    
    @Relationship(deleteRule: .cascade, inverse: \IngredienteDaReceita.receita)
    var ingredientesDaReceita: [IngredienteDaReceita] = []
    
    init(id: UUID = UUID(), titulo: String, categoria: String, descricao: String, imagem: Data?, tempoDePreparo: Int16, porcoes: String, dificuldade: String?, dataCriacao: Date = Date()) {
        self.id = id
        self.titulo = titulo
        self.categoria = categoria
        self.descricao = descricao
        self.imagem = imagem
        self.tempoDePreparo = tempoDePreparo
        self.porcoes = porcoes
        self.dificuldade = dificuldade
        self.dataCriacao = dataCriacao
    }
}

@Model
final class Ingrediente {
    var id: UUID
    var nome: String
    
    init(id: UUID = UUID(), nome: String) {
        self.id = id
        self.nome = nome
    }
}

@Model
final class IngredienteDaReceita {
    var id: UUID
    var quantidade: String
    var medida: String
    var receita: Receita?
    var ingrediente: Ingrediente?
    
    init(id: UUID = UUID(), quantidade: String, medida: String) {
        self.id = id
        self.quantidade = quantidade
        self.medida = medida
    }
}

@Model
final class PassoReceita {
    var id: UUID
    var etapa: Int16
    var nome: String
    var texto: String
    var tempoEstimado: Int16
    var receita: Receita?
    
    init(id: UUID = UUID(), etapa: Int16, nome: String, texto: String, tempoEstimado: Int16) {
        self.id = id
        self.etapa = etapa
        self.nome = nome
        self.texto = texto
        self.tempoEstimado = tempoEstimado
    }
}
