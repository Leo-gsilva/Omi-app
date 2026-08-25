//
//  ReceitaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation

// Agora a struct temporária guarda apenas a String do nome!
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

extension Ingrediente {
    func toModel() -> IngredienteCadastradoModel {
        IngredienteCadastradoModel(id: id ?? UUID(), nome: nome ?? "")
    }
}

extension PassoReceita {
    func toModel() -> PassoModel {
        PassoModel(id: id ?? UUID(), etapa: etapa, nome: nome ?? "", texto: texto ?? "", tempoEstimado: tempoEstimado)
    }
}

// MARK: - Mapeamento Entidade ->
// Único lugar do app que sabe transformar NSManagedObject em Struct de comínio
extension Receita {
    func toModel() -> ReceitaModel {
        let ingredientesModel: [IngredienteModel] = (ingredientesDaReceita as? Set<IngredienteDaReceita> ?? [])
            .compactMap { relacao in
                guard let ingrediente = relacao.ingrediente else { return nil }
                
                return IngredienteModel(
                    id: relacao.id ?? UUID(),
                    nome: ingrediente.nome ?? "",
                    quantidade: relacao.quantidade ?? "",
                    medida: relacao.medida ?? ""
                )
            }
        
        let passosModel: [PassoModel] = (passo as? Set<PassoReceita> ?? [])
            .map { passo in
                PassoModel(
                    id: passo.id ?? UUID(),
                    etapa: passo.etapa,
                    nome: passo.nome ?? "",
                    texto: passo.texto ?? "",
                    tempoEstimado: passo.tempoEstimado
                    //imagem: passo.imagem
                )
            }
            .sorted { $0.etapa < $1.etapa }
        
        return ReceitaModel(
            id: id ?? UUID(),
            titulo: titulo ?? "",
            categoria: CategoriaReceita(
                rawValue: categoria ?? "") ?? .sobremesa,
            descricao: descricao ?? "",
            imagem: imagem,
            tempoDePreparo: tempoDePreparo,
            porcoes: porcoes ?? "",
            dataCriacao: dataCriacao ?? Date(),
            dataAtualizacao: dataAtualizacao,
            ingredientes: ingredientesModel,
            passos: passosModel)
    }
}

