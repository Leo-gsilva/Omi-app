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

struct PassoAdicionado: Identifiable {
    let id = UUID()
    let etapa: Int
    let nome: String
    let texto: String
    let tempoEstimado: Int
}

@Observable
final class CriarReceitaViewModel {
    
    // Receita
    var titulo = ""
    var categoria: CategoriaReceita = .almoco
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = ""
    
    // Ingredientes
    // Lista dos itens que o usuário foi adicionando na tela
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    
    // Campos temporários para digitar
    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""
    var medidaTexto = ""
    
    // Passos
    var passosAdicionados: [PassoAdicionado] = []
    
    var nomeDoPasso: String = ""
    var descricaoDoPasso: String = ""
    var tempoPassoTexto: String = ""
    
    private let repo: ReceitasRepo
    
    init(repo: ReceitasRepo) {
        self.repo = repo
    }
    
    // FUNÇÕES
    // INGREDIENTE
    func adicionarIngrediente() {
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
    
    // ADICIONAR PASSO
    func adicionarPasso() {
        guard !nomeDoPasso.isEmpty, !descricaoDoPasso.isEmpty else { return }
        
        let passo = PassoAdicionado(etapa: passosAdicionados.count + 1, nome: nomeDoPasso, texto: descricaoDoPasso, tempoEstimado: Int(tempoPassoTexto) ?? 0)
        
        passosAdicionados.append(passo)
        
        nomeDoPasso = ""
        descricaoDoPasso = ""
        tempoPassoTexto = ""
    }
    
    func salvarReceitaNoBanco() {
//        let tempo = Int16(tempoDePreparoTexto) ?? 0
//        let porcoes = porcoesTexto
        
        do {
            // AQUI ACONTECE A MÁGICA: Transformamos os textos digitados em objetos do CoreData!
//            let tuplas = try ingredientesAdicionados.map { item -> (Ingrediente, Double, String) in
//                // O repo procura o texto. Se achar, vincula. Se não, cria!
//                let ingredienteCoreData = try repo.buscarOuCriarIngrediente(nome: item.nome)
//                return (ingredienteCoreData, item.quantidade, item.medida)
//            }
            
            try repo.criarReceita(
                titulo: titulo,
                categoria: categoria.rawValue,
                descricao: descricao,
                imagem: "imagem_padrao",
                tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                porcoes: porcoesTexto,
                dificuldade: dificuldade,
                ingredientes: ingredientesAdicionados,
                passos: passosAdicionados
            )
            print("Receita e ingredientes salvos perfeitamente!")
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }
}
