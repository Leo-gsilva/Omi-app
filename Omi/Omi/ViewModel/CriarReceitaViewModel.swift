//
//  CriarReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI
import Observation

// Agora a struct temporária guarda apenas a String do nome!
struct IngredienteAdicionado: Identifiable {
    let id = UUID()
    let nome: String
    let quantidade: Double
    let medida: String
}

@Observable
class CriarReceitaViewModel {
    var titulo = ""
    var categoria = ""
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = "Fácil"
    
    // Lista dos itens que o usuário foi adicionando na tela
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    
    // Campos temporários para digitar
    var nomeIngredienteTexto = "" // <-- Mudou aqui!
    var quantidadeTexto = ""
    var medidaTexto = ""
    
    private let repo: ReceitasRepo
    
    init(repo: ReceitasRepo) {
        self.repo = repo
    }
    
    func adicionarNaLista() {
        guard !nomeIngredienteTexto.isEmpty,
              let quantidade = Double(quantidadeTexto),
              !medidaTexto.isEmpty else { return }
        
        let novoItem = IngredienteAdicionado(nome: nomeIngredienteTexto, quantidade: quantidade, medida: medidaTexto)
        ingredientesAdicionados.append(novoItem)
        
        // Limpa os campos para o próximo ingrediente
        nomeIngredienteTexto = ""
        quantidadeTexto = ""
        medidaTexto = ""
    }
    
    func salvarReceitaNoBanco() {
        let tempo = Int16(tempoDePreparoTexto) ?? 0
        let porcoes = porcoesTexto
        
        do {
            // AQUI ACONTECE A MÁGICA: Transformamos os textos digitados em objetos do CoreData!
            let tuplas = try ingredientesAdicionados.map { item -> (Ingrediente, Double, String) in
                // O repo procura o texto. Se achar, vincula. Se não, cria!
                let ingredienteCoreData = try repo.buscarOuCriarIngrediente(nome: item.nome)
                return (ingredienteCoreData, item.quantidade, item.medida)
            }
            
            try repo.criarReceita(
                titulo: titulo,
                categoria: categoria,
                descricao: descricao,
                imagem: "imagem_padrao",
                tempoDePreparo: tempo,
                porcoes: porcoes,
                dificuldade: dificuldade,
                //ingredientesComMedida: tuplas as! [(ingrediente: Ingrediente, quantidade: String, medida: String)]
            )
            print("Receita e ingredientes salvos perfeitamente!")
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }
}
