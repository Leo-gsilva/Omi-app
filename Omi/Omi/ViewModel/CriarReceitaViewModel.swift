//
//  CriarReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import Observation
import SwiftUI

@Observable
final class CriarReceitaViewModel {
    
    
    private let repo: ReceitaRepositorio
    private var modo: Modo = .criar
    var onSalvar: (() -> Void)?
    
    init(repo: ReceitaRepositorio, modo: Modo) {
        self.repo = repo
        self.modo = modo
        
        if case .editar(let receita) = modo {
            preencherComReceitaExistente(receita)
        }
    }
    
    var estaEditando: Bool {
        if case .editar = modo {return true}
        return false
    }
    
    var tituloDaTela: String {
        estaEditando ? "Editar de Receita" : "Anotar Receita"
    }
    
    // MARK: - Receita
    var titulo = ""
    var categoria: CategoriaReceita = .refeicao
    var descricao = ""
    var tempoDePreparoTexto = ""
    var porcoesTexto = ""
    var dificuldade = ""
    var imagem: Data?
    
    //MARK: - Ingredientes
    // Lista dos itens que o usuário foi adicionando na tela
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    
    // Campos temporários para digitar
    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""
    var medidaTexto = ""
    
    //MARK: - Passos
    var passosAdicionados: [PassoAdicionado] = []
    
    var nomeDoPasso: String = ""
    var descricaoDoPasso: String = ""
    var tempoPassoTexto: String = ""
    var imagemPasso: Data?
    
    //MARK: - FUNÇÕES
    //MARK: - INGREDIENTE
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
    
    //MARK: - ADICIONAR PASSO
    func adicionarPasso() {
        guard !nomeDoPasso.isEmpty, !descricaoDoPasso.isEmpty else { return }
        
        let passo = PassoAdicionado(etapa: passosAdicionados.count + 1, nome: nomeDoPasso, texto: descricaoDoPasso, tempoEstimado: Int(tempoPassoTexto) ?? 0)
        
        passosAdicionados.append(passo)
        
        nomeDoPasso = ""
        descricaoDoPasso = ""
        tempoPassoTexto = ""
    }
    
    // MARK: - Actions
    func preencherComReceitaExistente(_ receita: ReceitaModel) {
        titulo = receita.titulo
        categoria = receita.categoria
        descricao = receita.descricao
        tempoDePreparoTexto = String(receita.tempoDePreparo)
        porcoesTexto = receita.porcoes
        dificuldade = receita.dificuldade ?? ""
        
        ingredientesAdicionados = receita.ingredientes.map {
            IngredienteAdicionado(nome: $0.nome, quantidade: Double($0.quantidade) ?? 0, medida: $0.medida)
        }
        
        passosAdicionados = receita.passos.map {
            PassoAdicionado(etapa: Int($0.etapa), nome: $0.nome, texto: $0.texto, tempoEstimado: Int($0.tempoEstimado))
        }
    }
    
    func salvarReceitaNoBanco() {
        do {
            _ = imagem?.base64EncodedString() ?? ""
            
            switch modo {
            case .criar:
                try repo.criarReceita(
                    titulo: titulo,
                    categoria: categoria.rawValue,
                    descricao: descricao,
                    imagem: imagem,
                    tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                    porcoes: porcoesTexto,
                    dificuldade: dificuldade.isEmpty ? nil : dificuldade,
                    ingredientes: ingredientesAdicionados,
                    passos: passosAdicionados
                )
                print("Receita criada com sucesso!")
                
            case .editar(let receitaOriginal):
                try repo.atualizarReceitaCompleta(
                    id: receitaOriginal.id,
                    titulo: titulo,
                    categoria: categoria.rawValue,
                    descricao: descricao,
                    imagem: imagem ?? nil,
                    tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                    porcoes: porcoesTexto,
                    dificuldade: dificuldade.isEmpty ? nil : dificuldade,
                    ingredientes: ingredientesAdicionados,
                    passos: passosAdicionados
                )
                print("Receita atualizada com sucesso!")
            }
            
            //AVISA QUEM ESTIVER ESCUTANDO QUE SALVOU!
            onSalvar?()
            
        } catch {
            print("Erro ao salvar: \(error)")
        }
    }
    // REMOVER INGREDIENTE DA LISTA
        func removerIngrediente(at offsets: IndexSet) {
            ingredientesAdicionados.remove(atOffsets: offsets)
        }

        // REMOVER PASSO DA LISTA
        func removerPasso(at offsets: IndexSet) {
            passosAdicionados.remove(atOffsets: offsets)
            
            // Reorganiza o número das etapas para não ficar bagunçado
            for (index, _) in passosAdicionados.enumerated() {
                passosAdicionados[index].etapa = index + 1
            }
        }
}
