//
//  ReceitaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation

struct IngredienteAdicionado: Identifiable {
    let id = UUID()
    let nome: String
    let quantidade: Double
    let medida: String
}

struct PassoAdicionado: Identifiable {
    let id = UUID()
    var etapa: Int
    let nome: String
    let texto: String
    let tempoEstimado: Int
//    let imagem: Data?
}

// Versão de leitura de uma receita, só para exibição
// Nenhuma View deve conhecer a entity `Receita` Core Data
struct ReceitaModel: Identifiable, Hashable {
    let id: UUID
    var titulo: String
    var categoria: CategoriaReceita
    var descricao: String
    var imagem: Data?
    var tempoDePreparo: Int16
    var porcoes: String
    var dificuldade: String?
    var dataCriacao: Date
    var dataAtualizacao: Date?
    var ingredientes: [IngredienteModel]
    var passos: [PassoModel]
}

struct IngredienteModel: Identifiable, Hashable {
    let id: UUID
    var nome: String
    var quantidade: String
    var medida: String
}

struct PassoModel: Identifiable, Hashable {
    let id: UUID
    var etapa: Int16
    var nome: String
    var texto: String
    var tempoEstimado: Int16
//    var imagem: Data?
}

// Representa a entitidade Ingrediente pura
struct IngredienteCadastradoModel: Identifiable, Hashable {
    let id: UUID
    var nome: String
}
