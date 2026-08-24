//
//  ReceitasRepositorio.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation

// Contrato de acesso a dados, facilita a migração. Quando trocar para SwiftData, basta criar um ReceitaRepositorioSwiftData( ReceitaRepositorio)
protocol ReceitaRepositorio {
    // Receita
    func buscarReceitas() throws -> [ReceitaModel] // Busca todo o banco de dados e retorna um ARRAY de receitas
    func buscarReceita(id: UUID) throws -> ReceitaModel? // Busca direto pelo id. Mais eficiente e retornar UMA receita específica se encontrar
    
    func criarReceita(
        titulo: String,
        categoria: String,
        descricao: String,
        imagem: Data?,
        tempoDePreparo: Int16,
        porcoes: String,
        dificuldade: String?,
        ingredientes: [IngredienteAdicionado],
        passos: [PassoAdicionado]
    ) throws
    
    
    
    func atualizarReceita(
        id: UUID,
        novoTitulo: String,
        novaCategoria: String,
        novaDescricao: String,
        novaImagem: Data?,
        novoTempoDePreparo: Int16,
        novasPorcoes: String,
        novaDificuldade: String?
    ) throws
    
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
        ) throws
    
    func deletarReceita(id: UUID) throws
    
    // Passo
    
    func buscarPassos(para receita: Receita) throws -> [PassoReceita] 
    
    func criarPasso(
        receitaId: UUID,
        etapa: Int16,
        nome: String,
        texto: String,
        imagem: Data?,
        tempoEstimado: Int16
    ) throws
    
    func atualizarPasso(
        id: UUID,
        novaEtapa: Int16,
        novoNome: String,
        novoTexto: String,
        novaImagem: Data?,
        novoTempoEstimado: Int16
    ) throws
    
    func deletarPasso(id: UUID) throws
    
    // Ingredientes
    func buscarIngredientes() throws -> [IngredienteCadastradoModel]
    
    func deletarIngrediente(id: UUID) throws
    
    func atualizarIngredienteDaReceita(
        id: UUID,
        novaQuantidade: String,
        novaMedida: String
    ) throws
    
    func criarIngredienteAvulso(nome: String) throws -> IngredienteCadastradoModel
}

