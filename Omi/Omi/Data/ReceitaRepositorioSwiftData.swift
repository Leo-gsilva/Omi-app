//
//  ReceitaRepositorioSwiftData.swift
//  Omi
//
//  Created by Igor Carrasco on 25/08/26.
//

import Foundation
import SwiftData

final class ReceitaRepositorioSwiftData: ReceitaRepositorio {
    private let contexto: ModelContext
    
    init(context: ModelContext) {
        self.contexto = context
    }
    
    private func saveData() {
        do {
            try contexto.save()
            print("PASSO 1: 📢 Core Data salvou e disparou o aviso!")
        } catch {
            contexto.rollback()
            print("ERRO AO SALVAR COREDATA: \(error.localizedDescription)")
        }
    }
    
    // MARK: - toModel (mesma ideia da extension no CoreData)
    private func receitaToModel(_ receita: Receita) -> ReceitaModel {
        ReceitaModel(
            id: receita.id,
            titulo: receita.titulo,
            categoria: CategoriaReceita(rawValue: receita.categoria) ?? .sobremesa,
            descricao: receita.descricao,
            imagem: receita.imagem,
            tempoDePreparo: receita.tempoDePreparo,
            porcoes: receita.porcoes,
            dataCriacao: receita.dataCriacao,
            dataAtualizacao: receita.dataAtualizacao,
            ingredientes: receita.ingredientesDaReceita.map {
                IngredienteModel(
                    id: $0.id,
                    nome: $0.ingrediente?.nome ?? "",
                    quantidade: $0.quantidade,
                    medida: $0.medida)
            },
            passos: receita.passos
                .map { PassoModel(
                    id: $0.id,
                    etapa: $0.etapa,
                    nome: $0.nome,
                    texto: $0.texto,
                    tempoEstimado: $0.tempoEstimado
                ) }
                .sorted{ $0.etapa < $1.etapa }
        )
    }
    
    private func passoToModel(_ passo: PassoReceita) -> PassoModel {
        PassoModel(id: passo.id, etapa: passo.etapa, nome: passo.nome, texto: passo.texto, tempoEstimado: passo.tempoEstimado)
    }
    
    //    private func ingredienteToModel(_ ingrediente: Ingre) -> IngredienteModel {
    //        IngredienteModel(id: ingrediente.id, nome: ingrediente, quantidade: ingrediente.quantidade, medida: ingrediente.medida)
    //    }
    
    // #Predicate é a diferença mais visível: troca o NSPredicate(format:...)
    // (string, sem checagem de tipo) por uma closure swift normal, checda em tempo de compilação
    
    // MARK: - Receita
    func buscarReceitas() throws -> [ReceitaModel] {
        let descritor = FetchDescriptor<Receita>(sortBy: [SortDescriptor(\.titulo)])
        return try contexto.fetch(descritor).map(receitaToModel)
    }
    
    func buscarReceita(id: UUID) throws -> ReceitaModel? {
        let descritor = FetchDescriptor<Receita>(predicate: #Predicate { $0.id == id })
        
        return try contexto.fetch(descritor).first.map(receitaToModel)
    }
    
    func criarReceita(titulo: String, categoria: String, descricao: String, imagem: Data?, tempoDePreparo: Int16, porcoes: String, dificuldade: String?, ingredientes: [IngredienteAdicionado], passos: [PassoAdicionado]) throws {
        let receita = Receita(titulo: titulo, categoria: categoria, descricao: descricao, imagem: imagem, tempoDePreparo: tempoDePreparo, porcoes: porcoes, dificuldade: dificuldade)
        
        contexto.insert(receita)
        
        for item in ingredientes {
            let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
            let relacao = IngredienteDaReceita(quantidade: String(item.quantidade), medida: item.medida)
            contexto.insert(relacao)
            relacao.receita = receita
            relacao.ingrediente = ingrediente
        }
        
        for item in passos {
            let passo = PassoReceita(etapa: Int16(item.etapa), nome: item.nome, texto: item.texto, tempoEstimado: Int16(item.tempoEstimado))
            passo.receita = receita
            contexto.insert(passo)
        }
        
        saveData()
    }
    
    func atualizarReceita(id: UUID, novoTitulo: String, novaCategoria: String, novaDescricao: String, novaImagem: Data?, novoTempoDePreparo: Int16, novasPorcoes: String, novaDificuldade: String?) throws {
        guard let receita = try buscarReceitaEntity(id: id) else { return }
        receita.titulo = novoTitulo
        receita.categoria = novaCategoria
        receita.descricao = novaDescricao
        receita.imagem = novaImagem
        receita.tempoDePreparo = novoTempoDePreparo
        receita.porcoes = novasPorcoes
        receita.dificuldade = novaDificuldade
        receita.dataAtualizacao = Date()
        saveData()
    }
    
    func deletarReceita(id: UUID) throws {
        guard let receita = try buscarReceitaEntity(id: id) else { return }
        contexto.delete(receita) // deleteRule: .cascade já apaga passos e ingredientes junts
        saveData()
    }
    
    // MARK: - Passos
    func criarPasso(receitaId: UUID, etapa: Int16, nome: String, texto: String, tempoEstimado: Int16) throws {
        guard let receita = try buscarReceitaEntity(id: receitaId) else { return }
        
        let passo = PassoReceita(etapa: etapa, nome: nome, texto: texto, tempoEstimado: tempoEstimado)
        passo.receita = receita
        contexto.insert(passo)
        saveData()
    }
    
    func buscarPassos(receitaId: UUID) throws -> [PassoModel] {
        let descritor = FetchDescriptor<PassoReceita>(
            predicate: #Predicate { $0.receita?.id == receitaId }
        )
        return try contexto.fetch(descritor).map(passoToModel).sorted{ $0.etapa < $1.etapa}
    }
    
    func atualizarPasso(id: UUID, novaEtapa: Int16, novoNome: String, novoTexto: String, novoTempoEstimado: Int16) throws {
        guard let passo = try buscarPassoEntity(id: id) else { return }
        
        passo.etapa = novaEtapa
        passo.nome = novoNome
        passo.texto = novoTexto
        passo.tempoEstimado = novoTempoEstimado
        
        saveData()
    }
    
    func deletarPasso(id: UUID) throws {
        guard let passo = try buscarPassoEntity(id: id) else { return }
        contexto.delete(passo)
        saveData()
    }
    
    // MARK: - Ingredientes
    func buscarIngredientes() throws -> [IngredienteCadastradoModel] {
        let descritor = FetchDescriptor<Ingrediente>(sortBy: [SortDescriptor(\.nome)])
        return try contexto.fetch(descritor).map { IngredienteCadastradoModel(id: $0.id, nome: $0.nome)}
    }
    
    func atualizarIngredienteDaReceita(id: UUID, novaQuantidade: String, novaMedida: String) throws {
        guard let relacao = try buscarRelacaoEntity(id: id) else { return }
        
        relacao.quantidade = novaQuantidade
        relacao.medida = novaMedida
        
        saveData()
    }
    
    func criarIngredienteAvulso(nome: String) throws -> IngredienteCadastradoModel {
        let ingrediente = try buscarOuCriarIngrediente(nome: nome)
        saveData()
        return IngredienteCadastradoModel(id: ingrediente.id, nome: ingrediente.nome)
    }
    
    func deletarIngrediente(id: UUID) throws {
        guard let ingrediente = try buscarIngredienteEntity(id: id) else { return }
        contexto.delete(ingrediente)
        saveData()
    }
    
    // MARK: - Helpers
    private func buscarOuCriarIngrediente(nome: String) throws -> Ingrediente {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)
        let descritor = FetchDescriptor<Ingrediente>(
            predicate: #Predicate { $0.nome == nomeLimpo }
        )
        if let existente = try contexto.fetch(descritor).first {
            return existente
        }
        let novo = Ingrediente(nome: nomeLimpo)
        contexto.insert(novo)
        return novo
    }
    
    private func buscarReceitaEntity(id: UUID) throws -> Receita? {
        try contexto.fetch(FetchDescriptor<Receita>(predicate: #Predicate { $0.id == id})).first
    }
    
    private func buscarPassoEntity(id: UUID) throws -> PassoReceita? {
        try contexto.fetch(FetchDescriptor<PassoReceita>(predicate: #Predicate { $0.id == id})).first
    }
    
    private func buscarIngredienteEntity(id: UUID) throws -> Ingrediente? {
        try contexto.fetch(FetchDescriptor<Ingrediente>(predicate: #Predicate { $0.id == id})).first
    }
    
    private func buscarRelacaoEntity(id: UUID) throws -> IngredienteDaReceita? {
        try contexto.fetch(FetchDescriptor<IngredienteDaReceita>(predicate: #Predicate { $0.id == id})).first
    }
    
    func atualizarReceitaCompleta(
        id: UUID,
        titulo: String,
        categoria: String,
        descricao: String,
        imagem: Data?,
        tempoDePreparo: Int16,
        porcoes: String,
        dificuldade: String?,
        ingredientes: [IngredienteAdicionado],
        passos: [PassoAdicionado]
    ) throws {
        // 1. Atualiza os dados básicos da receita chamando a função que já tem
        try atualizarReceita(
            id: id,
            novoTitulo: titulo,
            novaCategoria: categoria,
            novaDescricao: descricao,
            novaImagem: imagem,
            novoTempoDePreparo: tempoDePreparo,
            novasPorcoes: porcoes,
            novaDificuldade: dificuldade
        )
        
        // 2. Salva tudo usando o saveData centralizado
        saveData()
    }
}

extension Notification.Name {
    static let repositorioAtualizado = Notification.Name("Omi.repositorioAtualizado")
}
