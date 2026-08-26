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
    
    var erroIngrediente: String?
    var erroPasso: String?
    var erroReceita: String?
    
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
    var tempoDePreparoTexto: String = "" {
            didSet {
                let apenasNumeros = tempoDePreparoTexto.filter { $0.isNumber }
                
                let limiteDigtos = 3
                let limitado = String(apenasNumeros.prefix(limiteDigtos))
                
                if limitado != tempoDePreparoTexto {
                    tempoDePreparoTexto = limitado
                }
            }
        }
    var porcoesTexto = "" {
        didSet {
            let apenasNumeros = porcoesTexto.filter { $0.isNumber }
            
            let limiteDigtos = 3
            let limitado = String(apenasNumeros.prefix(limiteDigtos))
            
            if limitado != porcoesTexto {
                porcoesTexto = limitado
            }
        }
    }
    var dificuldade = ""
    var imagem: Data?
    
    //MARK: - Ingredientes
    // Lista dos itens que o usuário foi adicionando na tela
    var ingredientesAdicionados: [IngredienteAdicionado] = []
    
    // Campos temporários para digitar
    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""{
        didSet {
            let apenasNumeros = quantidadeTexto.filter { $0.isNumber }
            
            let limiteDigtos = 3
            let limitado = String(apenasNumeros.prefix(limiteDigtos))
            
            if limitado != quantidadeTexto {
                quantidadeTexto = limitado
            }
        }
    }
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
        guard !nomeIngredienteTexto.isEmpty else {
            erroIngrediente = "Informe o nome do ingrediente"
            return
        }
        guard let quantidade = Double(quantidadeTexto), quantidade > 0 else {
            erroIngrediente = "Quantidade inválida - use apenas números"
            return
        }
        guard !medidaTexto.isEmpty else {
            erroIngrediente = "Informe a medida (Ex: xícara, colher de sopa, ml)"
            return
        }
        
        erroIngrediente = nil
        let novoItem = IngredienteAdicionado(nome: nomeIngredienteTexto, quantidade: quantidade, medida: medidaTexto)
        ingredientesAdicionados.append(novoItem)
        
        // Limpa os campos para o próximo ingrediente
        nomeIngredienteTexto = ""
        quantidadeTexto = ""
        medidaTexto = ""
    }
    
    //MARK: - ADICIONAR PASSO
    func adicionarPasso() {
        guard !nomeDoPasso.isEmpty else {
            erroPasso = "Dê um nome para essa etapa"
            return }
        guard !descricaoDoPasso.isEmpty else {
            erroPasso = "Descreva o que fazer nessa etapa da receita"
            return
        }
        
        erroPasso = nil
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
    
    func salvarReceitaNoBanco() -> Bool {
        guard !titulo.isEmpty else {
            erroReceita = "Dê um título para a receita"
            return false
        }
        guard !ingredientesAdicionados.isEmpty else {
            erroReceita = "Adicione pelo menos um ingrediente em sua receita"
            return false
        }
        guard !passosAdicionados.isEmpty else {
            erroReceita = "Adicione pelo menos uma etapa em sua receita"
            return false
        }
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
                erroReceita = nil
                print("Receita criada com sucesso!")
                return true
                
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
                erroReceita = nil
                print("Receita atualizada com sucesso! Ingredientes: \(ingredientesAdicionados.count), Passos: \(passosAdicionados.count), Receita:\(titulo)")
                return true
            }
            
//            //AVISA QUEM ESTIVER ESCUTANDO QUE SALVOU!
//            onSalvar?()
            
        } catch {
            erroReceita = "Não foi possível salvar a receita. Tente novamente"
            print("Erro ao salvar: \(error)")
            return false
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
