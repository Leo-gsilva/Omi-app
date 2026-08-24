### Arquivo: \⁠ ./ViewModel/LivroDeReceitasViewModel.swift\ ⁠
⁠ swift
//
//  LivroDeReceitasViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation
import CoreData // PQ esse viewModel importa o coreData? Ta certo?

@Observable
final class LivroReceitasViewModel {
    var categoriaAtual: CategoriaReceita = .sobremesa
    private(set) var receitas: [ReceitaModel] = []
    
    private let repo: ReceitaRepositorio
    private var observer: NSObjectProtocol?
    // Recebe protocolo e não a classe
    
    var livroAberto: Bool = false
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarReceitas()
        observarMudancas()
    }
    
    var receitasFiltradas: [ReceitaModel] {
        receitas.filter { $0.categoria == categoriaAtual }
    }

    var totalPaginas: Int {
        receitasFiltradas.count
    }
    
    var paginaAtual = 0
    
    func carregarReceitas() {
        do {
            receitas = try repo.buscarReceitas()
        } catch {
            print("Erro ao buscar receitas: \(error)")
            receitas = []
        }
    }
    
    func deletar(_ receita: ReceitaModel) {
        do {
            try repo.deletarReceita(id: receita.id)
            carregarReceitas()
        } catch {
            print("Erro ao deletar receita \(error)")
        }
    }
    
    func proximaCategoria() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual)
        else { return }

        let proximoIndice = min(indiceAtual + 1, CategoriaReceita.allCases.count - 1)

        categoriaAtual = CategoriaReceita.allCases[proximoIndice]
    }

    func categoriaAnterior() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual)
        else { return }

        let indiceAnterior = max(indiceAtual - 1, 0)

        categoriaAtual = CategoriaReceita.allCases[indiceAnterior]
    }
    
    // Substitui o que o @fetchRequest faz de graça: reage a saves no contexto e busca novamente
    private func observarMudancas() {
        observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main ){ [weak self] _ in
                self?.carregarReceitas()
            }
    }
    
    // Funcs do antigo TelaInicialViewModel
    func abrirLivro() {
        guard !livroAberto else {
            return
        }

        livroAberto = true
    }

    func avancar() {
        guard paginaAtual < totalPaginas else {
            return
        }

        paginaAtual += 1
    }
    
    func voltar() {
        guard paginaAtual > 1 else {
            return
        }
        
        paginaAtual -= 1
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/DetalhesReceitaViewModel.swift\ ⁠
⁠ swift
//
//  DetalhesReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 19/08/26.
//
import SwiftUI
import Observation

// pelo que li, é mais tranquilo implementar o coredata usando o ObservedObject
@Observable
class DetalhesReceitaViewModel {
    var receita: ReceitaModel?
    
    private let repo: ReceitaRepositorio
    
    init(receita: ReceitaModel, repo: ReceitaRepositorio) {
        self.receita = receita
        self.repo = repo
        carregarDetalhes()
    }
    
    func carregarDetalhes() {
            do {
                receita = try repo.buscarReceitas().first(where: { $0.id == receita?.id })
            } catch {
                print("Erro ao carregar detalhes: \(error)")
            }
        }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/CriarReceitaViewModel.swift\ ⁠
⁠ swift
//
//  CriarReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import Observation
import Foundation


@Observable
final class CriarReceitaViewModel {
    
    // Diferencia se a tela está criando uma receita nova
    // ou editando uma receita já existente.
    enum Modo {
        case criar
        case editar(ReceitaModel)
    }
    
    private let modo: Modo
    private let repo: ReceitaRepositorio   // ✅ protocolo, não a implementação concreta
    
    init(modo: Modo, repo: ReceitaRepositorio) {
        self.modo = modo
        self.repo = repo
        
        //        if case .editar(let receita) = modo {
        //            preencherComReceitaExistente(receita)
        //        }
        //    }
        
        var estaEditando: Bool {
            if case .editar = modo { return true }
            return false
        }
        
        var tituloDaTela: String {
            estaEditando ? "Editar receita" : "Anotar receita"
        }
        
        // Receita
        var titulo = ""
        var categoria: CategoriaReceita = .refeicao
        var descricao = ""
        var tempoDePreparoTexto = ""
        var porcoesTexto = ""
        var dificuldade = ""
        var imagem: String   // ✅ Binary Data
        
        // Ingredientes
        var ingredientesAdicionados: [IngredienteAdicionado] = []
        var nomeIngredienteTexto = ""
        var quantidadeTexto = ""
        var medidaTexto = ""
        
        // Passos
        var passosAdicionados: [PassoAdicionado] = []
        var nomeDoPasso: String = ""
        var descricaoDoPasso: String = ""
        var tempoPassoTexto: String = ""
        
        // Preenche os campos da tela a partir de uma receita já existente (modo editar).
        func preencherComReceitaExistente(_ receita: ReceitaModel) {
            titulo = receita.titulo
            categoria = receita.categoria
            descricao = receita.descricao
            tempoDePreparoTexto = String(receita.tempoDePreparo)
            porcoesTexto = receita.porcoes
            dificuldade = receita.dificuldade ?? ""
            imagem = receita.titulo
            
            ingredientesAdicionados = receita.ingredientes.map {
                IngredienteAdicionado(nome: $0.nome, quantidade: Double($0.quantidade) ?? 0, medida: $0.medida)
            }
            
            passosAdicionados = receita.passos.map {
                PassoAdicionado(etapa: Int($0.etapa), nome: $0.nome, texto: $0.texto, tempoEstimado: Int($0.tempoEstimado))
            }
        }
        
        func adicionarIngrediente() {
            guard !nomeIngredienteTexto.isEmpty,
                  let quantidade = Double(quantidadeTexto),
                  !medidaTexto.isEmpty else { return }
            
            let novoItem = IngredienteAdicionado(nome: nomeIngredienteTexto, quantidade: quantidade, medida: medidaTexto)
            ingredientesAdicionados.append(novoItem)
            
            nomeIngredienteTexto = ""
            quantidadeTexto = ""
            medidaTexto = ""
        }
        
        func adicionarPasso() {
            guard !nomeDoPasso.isEmpty, !descricaoDoPasso.isEmpty else { return }
            
            let passo = PassoAdicionado(
                etapa: passosAdicionados.count + 1,
                nome: nomeDoPasso,
                texto: descricaoDoPasso,
                tempoEstimado: Int(tempoPassoTexto) ?? 0
            )
            
            passosAdicionados.append(passo)
            
            nomeDoPasso = ""
            descricaoDoPasso = ""
            tempoPassoTexto = ""
        }
        
        func salvarReceitaNoBanco() {
            do {
                switch modo {
                case .criar:
                    try repo.criarReceita(
                        titulo: titulo,
                        categoria: categoria.rawValue,
                        descricao: descricao,
                        imagem: imagem,                       // ✅ Data?
                        tempoDePreparo: Int16(tempoDePreparoTexto) ?? 0,
                        porcoes: porcoesTexto,
                        dificuldade: dificuldade.isEmpty ? nil : dificuldade,
                        ingredientes: ingredientesAdicionados,
                        passos: passosAdicionados
                    )
                    
                case .editar(let receitaOriginal):
                    try repo.atualizarReceitaCompleta(
                        id: receitaOriginal.id,
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
                }
                
                print("Receita salva com sucesso!")
            } catch {
                print("Erro ao salvar: \(error)")
            }
        }
    }
    
    // MARK: - Preview
    //extension CriarReceitaViewModel {
    //    @MainActor
    //    static var preview: CriarReceitaViewModel {
    //        let context = PersistenceController.preview.container.viewContext
    //        let repo = ReceitaRepositorioCoreData(context: context)
    //        return CriarReceitaViewModel(modo: .criar, repo: repo)
    //    }
    //}
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/TelainicialViewModel.swift\ ⁠
⁠ swift
//
//  Telainicial.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI
import Observation

@Observable
class TelaInicialViewModel {
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
    }
    
    var receitas: [ReceitaModel] = []
    var paginaAtual: Int = 0
    var totalPaginas = 1
    
    var livroAberto: Bool = false
    
    func getTotalPaginas() -> Int {
        return receitas.count
    }
    
    func abrirLivro() {
        guard !livroAberto else {
            return
        }

        livroAberto = true
    }

    func avancar() {
        guard paginaAtual < totalPaginas else {
            return
        }

        paginaAtual += 1
    }
    
    func voltar() {
        guard paginaAtual > 1 else {
            return
        }
        
        paginaAtual -= 1
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/CategoriaViewModel.swift\ ⁠
⁠ swift
//
//  CategoriaViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation

@Observable
final class CategoriaViewModel {
    var categoriaAtual: CategoriaReceita = .cafeDaManha

    func proximaCategoria() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual) else { return }

        let proximoIndice = min(indiceAtual + 1, CategoriaReceita.allCases.count - 1)

        categoriaAtual = CategoriaReceita.allCases[proximoIndice]
    }

    func categoriaAnterior() {
        guard let indiceAtual = CategoriaReceita.allCases.firstIndex(of: categoriaAtual) else { return }

        let indiceAnterior = max(indiceAtual - 1, 0)

        categoriaAtual = CategoriaReceita.allCases[indiceAnterior]
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/IngredientesViewModel.swift\ ⁠
⁠ swift
//
//  IngredientesViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import SwiftUI
import Observation

@Observable
class IngredientesViewModel {
    // Look how clean this is! No @Published needed.
    var itens: [IngredienteCadastradoModel] = []
    
    // We make the repo private so the View can't touch it directly.
    private let repo: ReceitaRepositorio
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarIngredientes()
    }
    
    func carregarIngredientes() {
        do {
            itens = try repo.buscarIngredientes()
        } catch {
            print("Erro ao buscar: \(error)")
        }
    }
    
    func adicionar(nome: String) {
        guard !nome.isEmpty else { return }
        do {
            _ = try repo.criarIngredienteAvulso(nome: nome)
            carregarIngredientes()
        } catch {
            print("Erro ao adicionar: \(error)")
        }
    }
    
    func deletar(offsets: IndexSet) {
        offsets.map { itens[$0] }.forEach { ingrediente in
            do {
                try repo.deletarIngrediente(id: ingrediente.id)
            } catch {
                print("Erro ao deletar: \(error)")
            }
        }
        carregarIngredientes()
    }
}
 ⁠

---

### Arquivo: \⁠ ./ViewModel/OnboardingViewModel.swift\ ⁠
⁠ swift
//
//  OnboardingViewModel.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    var postitAtivo: Int? = nil
    var paginaAtual: Int = 0
    var finalizado: Bool = false
    
    let totalDePaginas = 6
    
    let paginas: [OnboardingModel] = [
        OnboardingModel(
            titulo: "O que o app faz?",
            descricao: "Esse é o seu ",
            palavraDestaque: "álbum \nde receitas.",
            palavraDestaque2: nil,
            imagem: "AlbumOnboarding"
            
        ),
        
        OnboardingModel(
            titulo: "Crie categorias",
            descricao: "Organize suas receitas,\n por ",
            palavraDestaque: "categorias ",
            palavraDestaque2: "etiquetas.",
            imagem: "Albumcortadoonboarding"
        ),
        
        OnboardingModel(
            titulo: "Adicione Receitas",
            descricao: "Você pode ",
            palavraDestaque: "adicionar novas receitas",
            palavraDestaque2: " para seu álbum.",
            imagem: "ImageAdicionarpag3"
        ),
        
        OnboardingModel(
            titulo: "Edite suas receitas",
            descricao: "No botão Editar, você pode  no álbum.   ",
            palavraDestaque: "mudar suas receitas",
            palavraDestaque2: nil,
            imagem: "Editarpag4",
        ),
        
        OnboardingModel(
            titulo: "Veja sua receitas ",
            descricao:"na sua\n receita, você pode\n",
            palavraDestaque: "tocar ",
            palavraDestaque2: "vê-la com\n mais detalhes.",
            imagem: "livropag5"
        )
    ]
    
//    var totalDePaginas: Int {
//        paginas.count
//    }
    
//    var paginaAtualModel: OnboardingModel {
//        paginas[paginaAtual+1]
//    }
    
    func continuar() {
        if paginaAtual < totalDePaginas - 1 {
            paginaAtual += 1
            print(paginaAtual)
        } else {
            finalizado = true
        }
    }
    
    func voltar() {
        guard paginaAtual > 0 else { return }
        
        paginaAtual -= 1
    }
    
    func iniciarAnimacaoPostIts() async {
        
        while !Task.isCancelled {
            
            for index in 0..<5 {
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    postitAtivo = index
                }
                
                try? await Task.sleep(for: .milliseconds(500))
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    postitAtivo = nil
                }
                
                try? await Task.sleep(for: .milliseconds(150))
            }
        }
    }
    
//    private func finalizarOnboarding() {
//        finalizado = true
//        print("Onboarding finalizado")
//    }
}
 ⁠

---

### Arquivo: \⁠ ./Navegacao/Rota.swift\ ⁠
⁠ swift
//
//  NavigationModel.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import Foundation

enum Rota: Hashable {
    case telaInicial
    case detalheReceita(ReceitaModel)
    case criarReceita
//    case listaIngredientes
    case onboarding
}
 ⁠

---

### Arquivo: \⁠ ./Navegacao/AppRouter.swift\ ⁠
⁠ swift
//
//  AppRouter.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import Observation
import SwiftUI

@Observable
final class AppRouter {
    var path = NavigationPath()
    
    var sheetAtual: Rota?
    
    func push(_ rota: Rota) {
        path.append(rota)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popATodas() {
        path.removeLast(path.count)
    }
    
    func apresentarSheet(_ rota: Rota) {
        sheetAtual = rota
    }
    
    func fecharSheet() {
        sheetAtual = nil
    }
    
    // não é push ou pop, ele troca a raiz do app inteiro
    func finalizarOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingConcluido")
    }
}
 ⁠

---

### Arquivo: \⁠ ./Model/DataModel.swift\ ⁠
⁠ swift
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
    let etapa: Int
    let nome: String
    let texto: String
    let tempoEstimado: Int
}

// Versão de leitura de uma receita, só para exibição
// Nenhuma View deve conhecer a entity `Receita` Core Data
struct ReceitaModel: Identifiable, Hashable {
    let id: UUID
    var titulo: String
    var categoria: CategoriaReceita
    var descricao: String
    var imagem: String
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
    var imagem: String
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
        PassoModel(id: id ?? UUID(), etapa: etapa, nome: nome ?? "", texto: texto ?? "", tempoEstimado: tempoEstimado,  imagem: imagem!)
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
                    etapa: passo.etapa + 1,
                    nome: passo.nome ?? "",
                    texto: passo.texto ?? "",
                    tempoEstimado: passo.tempoEstimado,
                    imagem: ""
                )
            }
            .sorted { $0.etapa < $1.etapa }
        
        return ReceitaModel(
            id: id ?? UUID(),
            titulo: titulo ?? "",
            categoria: CategoriaReceita(
                rawValue: categoria ?? "") ?? .sobremesa,
            descricao: descricao ?? "",
            imagem: "", 
            tempoDePreparo: tempoDePreparo,
            porcoes: porcoes ?? "",
            dataCriacao: dataCriacao ?? Date(),
            dataAtualizacao: dataAtualizacao,
            ingredientes: ingredientesModel,
            passos: passosModel)
    }
}
 ⁠

---

### Arquivo: \⁠ ./Model/CategoriaModel.swift\ ⁠
⁠ swift
//
//  CategoriaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI

enum CategoriaReceita: String, CaseIterable, Identifiable {
    case sobremesa
    case refeicao
    case saudavel
    case lanche
    case cafeDaManha

    var id: String { rawValue }

    var nomeExibicao: String {
        switch self {
        case .sobremesa: return "Sobremesa"
        case .refeicao: return "Refeição"
        case .saudavel: return "Saudável"
        case .lanche: return "Lanche"
        case .cafeDaManha: return "Café da Manhã"
        }
    }

    // Ajuste os RGB pra bater com os hex exatos do Figma se tiver acesso a eles
    var cor: Color {
        switch self {
        case .sobremesa: return Color(.corSobremesa)
        case .refeicao: return Color(.corRefeicao)
        case .saudavel: return Color(.corSaudavel)
        case .lanche: return Color(.corLanche)
        case .cafeDaManha: return Color(.corCafe)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./Model/DetalheModel.swift\ ⁠
⁠ swift
//
//  DetalheModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
enum TipoDetalhe {
    case tempo(Int16)
    case pessoas(String)
    
    var textoFormatado: String {
        switch self {
        case .tempo(let minutos):
            return "\(minutos) min"
        case .pessoas(let quantidade):
            return "\(quantidade) pessoas"
        }
    }
    
    var iconePadrao: String {
        switch self {
        case .tempo:
            return "clock"
        case .pessoas:
            return "chart.pie"
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./Model/OnboardingModel.swift\ ⁠
⁠ swift
//
//  OnboardingModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import Foundation

struct OnboardingModel {
    let titulo: String
    let descricao: String
    let palavraDestaque: String
    let palavraDestaque2: String?
    let imagem: String
    
}
 ⁠

---

### Arquivo: \⁠ ./View/ReceitaPageView.swift\ ⁠
⁠ swift
//
//  ReceitaPageView.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI

struct ReceitaPageView: View {
    //ReceitaModel, não Receita (entidade) - Não chama CoreData
    let receita: ReceitaModel
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 12) {
                Section{
                    Text(receita.titulo)
                        .font(.title)
                        .bold()
                    
                    Text("data de criação: \(receita.dataCriacao.formatted(.dateTime))")
                            .font(.caption)
                    
                    Text(receita.categoria.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack{
                        Text("Tempo: \(receita.tempoDePreparo) min")
                        Text("Porções: \(receita.porcoes)")
                    }
                    Text("Categoria: \(receita.categoria.rawValue)")
                }
                
                Divider()
                
                Text(receita.descricao)
                            
                if !receita.passos.isEmpty {
                    Text("Modo de preparo")
                        .font(.headline)
                    
                    ForEach(receita.passos) { passo in
                        Text("\(passo.etapa). \(passo.nome)")
                            .fontWeight(.semibold)
                        Text(passo.texto)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ReceitaPageView(
        receita: ReceitaModel(
            id: UUID(),
            titulo: "Bolo de Cenoura",
            categoria: .sobremesa,
            descricao: "Receita de teste para Preview.",
            imagem: "",
            tempoDePreparo: 45,
            porcoes: "8",
            dificuldade: "Fácil",
            dataCriacao: Date(),
            dataAtualizacao: nil,
            ingredientes: [
                IngredienteModel(id: UUID(), nome: "Cenoura", quantidade: "3", medida: "unidades"),
                IngredienteModel(id: UUID(), nome: "Farinha", quantidade: "2", medida: "xícaras")
            ],
            passos: [
                PassoModel(id: UUID(), etapa: 1, nome: "Misture", texto: "Bata tudo no liquidificador.", tempoEstimado: 5, imagem: ""),
                PassoModel(id: UUID(), etapa: 2, nome: "Asse", texto: "Leve ao forno por 40 min.", tempoEstimado: 40, imagem: "")
            ]
        )
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/postitOnboarding.swift\ ⁠
⁠ swift
//
//  postitOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI
struct PostitOnboarding: View {
    
    let imagem: String
    let ativo: Bool
    
    var body: some View {
        Image(imagem)
            .resizable()
            .scaledToFit()
            .offset(y: ativo ? -20 : 0)
            .animation(
                .easeInOut(duration: 0.35),
                value: ativo
            )
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/CartaoClaro.swift\ ⁠
⁠ swift
//
//  CartaoClaro.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct CartaoClaro<Content: View>: View {
    @ViewBuilder var conteudo: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            conteudo
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.cordoFundoTexto))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    }
}
#Preview {
    CartaoClaro {
        VStack(alignment: .leading, spacing: 10) {
            Text("Etapa 2: OLA")
                .font(FontesApp.subtitulo)
                .foregroundStyle(.cordosTextos)
            
            Divider()
            
            Text("oi")
                .font(FontesApp.corpo)
                .foregroundStyle(.cordosTextos)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/EtiquetaSeta.swift\ ⁠
⁠ swift
//
//  EtiquetaSeta.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct EtiquetaSeta: Shape {
    func path(in rect: CGRect) -> Path {
        let ponta = rect.height / 2
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

 ⁠

---

### Arquivo: \⁠ ./View/Componentes/ReceitaHeroView.swift\ ⁠
⁠ swift
//
//  ReceitaHeroView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct ReceitaHeroView: View {
    let imagemData: String
    let titulo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { geo in
              Group {
//                    if let imagemData, let uiImage = UIImage(data: imagemData) {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                    } else {
                        Image("Bolo")
                            .resizable()
                            .scaledToFill()
                 //   }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
            }
            .aspectRatio(308.0 / 188.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Text(titulo)
                .font(FontesApp.titulo)
                .foregroundStyle(.cordosTextos)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.cordoFundoTexto))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
    }
}
#Preview {
    ReceitaHeroView(imagemData: "", titulo: "olha")
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/CampoTextoArredondado.swift\ ⁠
⁠ swift
//
//  CampoTextoArredondado.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct CampoTextoArredondado: View {
    let rotulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo)
                .font(FontesApp.Semibold)
                .foregroundStyle(.cordosTextos)

            TextField(placeholder, text: $texto)
                .font(FontesApp.corpo)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
        }
    }
}
#Preview {
    CampoTextoArredondado(rotulo: "Título da Receita", placeholder: "Ex: Bolo de chocolate", texto: .constant(""))
        .padding()
}
    
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/Playground/CriarReceitaMockView.swift\ ⁠
⁠ swift
//
//  CriarReceitaMockView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
//
//  MockCriarReceitaPreview.swift
//  Omi
//
//  ⚠️ ARQUIVO TEMPORÁRIO — só pra visualizar o layout e testar ajustes visuais.
//  Tudo aqui é mockado (não usa CoreData, ViewModel real, nem os componentes
//  reais do projeto) pra não conflitar com nada. Pode deletar esse arquivo
//  quando terminar de decidir o visual com o time.
//

import SwiftUI
import PhotosUI

// MARK: - Mock: Fontes (copia local só pra esse arquivo funcionar sozinho)
// Se seu FontesApp real já existir no projeto, pode apagar esse enum
// e usar o de verdade — deixei aqui só pra esse arquivo compilar isolado.
private enum FontesAppMock {
    static let titulo = Font.custom("Dosis", size: 32, relativeTo: .largeTitle).weight(.bold)
    static let subtitulo = Font.custom("Dosis", size: 20, relativeTo: .title3).weight(.semibold)
    static let corpo = Font.custom("Dosis", size: 17, relativeTo: .body).weight(.medium)
    static let semibold = Font.custom("Dosis", size: 14, relativeTo: .body).weight(.semibold)
}

// MARK: - Mock: Categoria
private enum CategoriaMock: String, CaseIterable, Identifiable {
    case sobremesa, refeicao, saudavel, lanche, cafeDaManha

    var id: String { rawValue }

    var nomeExibicao: String {
        switch self {
        case .sobremesa: return "Sobremesa"
        case .refeicao: return "Refeição"
        case .saudavel: return "Saudável"
        case .lanche: return "Lanche"
        case .cafeDaManha: return "Café da Manhã"
        }
    }

    var cor: Color {
        switch self {
        case .sobremesa: return Color(red: 0.84, green: 0.55, blue: 0.45)
        case .refeicao: return Color(red: 0.68, green: 0.71, blue: 0.62)
        case .saudavel: return Color(red: 0.73, green: 0.80, blue: 0.58)
        case .lanche: return Color(red: 0.96, green: 0.79, blue: 0.51)
        case .cafeDaManha: return Color(red: 0.96, green: 0.68, blue: 0.45)
        }
    }
}

// MARK: - Mock: Ingrediente/Passo temporários (structs simples, sem ligação com banco)
private struct IngredienteMock: Identifiable {
    let id = UUID()
    let nome: String
    let quantidade: String
    let medida: String
}

private struct PassoMock: Identifiable {
    let id = UUID()
    let numero: Int
    let texto: String
}

// MARK: - Mock: "ViewModel" (na real, um @State simples dentro da própria View,
// só pra essa tela mock ter interatividade sem precisar de arquitetura real)
@Observable
private final class CriarReceitaMockState {
    var titulo = ""
    var porcoes = ""
    var tempoDePreparo = ""
    var descricao = ""
    var categoria: CategoriaMock?
    var imagem: UIImage?

    var mostrarSheetCategoria = false

    var nomeIngredienteTexto = ""
    var quantidadeTexto = ""
    var medidaTexto = ""
    var ingredientesAdicionados: [IngredienteMock] = []

    var descricaoDoPasso = ""
    var passosAdicionados: [PassoMock] = []

    func adicionarIngrediente() {
        guard !nomeIngredienteTexto.isEmpty, !quantidadeTexto.isEmpty, !medidaTexto.isEmpty else { return }
        ingredientesAdicionados.append(
            IngredienteMock(nome: nomeIngredienteTexto, quantidade: quantidadeTexto, medida: medidaTexto)
        )
        nomeIngredienteTexto = ""
        quantidadeTexto = ""
        medidaTexto = ""
    }

    func adicionarPasso() {
        guard !descricaoDoPasso.isEmpty else { return }
        passosAdicionados.append(PassoMock(numero: passosAdicionados.count + 1, texto: descricaoDoPasso))
        descricaoDoPasso = ""
    }
}

// MARK: - Componente: Shape de seta (etiqueta de categoria)
private struct EtiquetaSetaMock: Shape {
    func path(in rect: CGRect) -> Path {
        let ponta = rect.height / 2
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Componente: Botão de etiqueta de categoria
private struct CategoriaEtiquetaButtonMock: View {
    let categoria: CategoriaMock
    let selecionada: Bool
    var aoSelecionar: () -> Void

    var body: some View {
        Button(action: aoSelecionar) {
            HStack {
                Text(categoria.nomeExibicao)
                    .font(FontesAppMock.subtitulo)
                    .foregroundStyle(.white)

                Spacer()

                if selecionada {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .padding(.trailing, 24)
                }
            }
            .padding(.leading, 20)
            .padding(.vertical, 18)
            .background(categoria.cor)
            .clipShape(EtiquetaSetaMock())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sheet de categoria
private struct CategoriaSheetMock: View {
    @Environment(\.dismiss) private var fechar
    let categoriaSelecionada: CategoriaMock?
    var aoSelecionar: (CategoriaMock) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.96, blue: 0.85)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: { fechar() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.7))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    Text("Adicionar categoria")
                        .font(FontesAppMock.subtitulo)
                        .foregroundStyle(.black.opacity(0.8))

                    Spacer()

                    Button(action: { fechar() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6), in: Circle())
                    }
                }

                Text("Selecione uma etiqueta com o nome da categoria que você quer escolher para sua receita.")
                    .font(FontesAppMock.corpo)
                    .foregroundStyle(.black.opacity(0.6))

                VStack(spacing: 16) {
                    ForEach(CategoriaMock.allCases) { categoria in
                        CategoriaEtiquetaButtonMock(
                            categoria: categoria,
                            selecionada: categoria == categoriaSelecionada,
                            aoSelecionar: {
                                aoSelecionar(categoria)
                                fechar()
                            }
                        )
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Campo de texto arredondado
private struct CampoTextoMock: View {
    let rotulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo)
                .font(FontesAppMock.semibold)
                .foregroundStyle(.black.opacity(0.8))

            TextField(placeholder, text: $texto)
                .font(FontesAppMock.corpo)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.93, green: 0.90, blue: 0.72))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Botão seletor de categoria
private struct SeletorCategoriaMock: View {
    let categoriaSelecionada: CategoriaMock?
    var aoTocar: () -> Void

    var body: some View {
        Button(action: aoTocar) {
            HStack {
                Text(categoriaSelecionada?.nomeExibicao ?? "Adicionar categoria")
                    .font(FontesAppMock.corpo)
                    .foregroundStyle(categoriaSelecionada == nil ? .black.opacity(0.4) : .black.opacity(0.8))

                Spacer()

                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(10)
                    .background(Color(red: 0.93, green: 0.90, blue: 0.72), in: Circle())
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Foto seletor
private struct FotoSeletorMock: View {
    @Binding var imagemSelecionada: UIImage?
    @State private var itemSelecionado: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Adicionar foto")
                .font(FontesAppMock.semibold)
                .foregroundStyle(.black.opacity(0.8))

            PhotosPicker(selection: $itemSelecionado, matching: .images) {
                HStack(spacing: 12) {
                    if let imagemSelecionada {
                        Image(uiImage: imagemSelecionada)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.black.opacity(0.6))
                    }

                    Text(imagemSelecionada == nil ? "Selecione uma imagem" : "Imagem selecionada")
                        .font(FontesAppMock.corpo)
                        .foregroundStyle(.black.opacity(0.6))

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.93, green: 0.90, blue: 0.72))
                .clipShape(Capsule())
            }
            .onChange(of: itemSelecionado) { _, novoItem in
                Task {
                    guard let dados = try? await novoItem?.loadTransferable(type: Data.self) else { return }
                    imagemSelecionada = UIImage(data: dados)
                }
            }
        }
    }
}

// MARK: - Campo de etapa
private struct EtapaCampoMock: View {
    let numero: Int
    @Binding var texto: String

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("Etapa \(numero):")
                .font(FontesAppMock.corpo)
                .foregroundStyle(.black.opacity(0.8))

            TextField("Ex: Misture os ovos e a manteiga", text: $texto, axis: .vertical)
                .font(FontesAppMock.corpo)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 0.90, blue: 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - TELA PRINCIPAL (MOCK)
struct CriarReceitaMockView: View {
    @Environment(\.dismiss) private var voltar
    @State private var estado = CriarReceitaMockState()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.99, green: 0.96, blue: 0.85)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        FotoSeletorMock(imagemSelecionada: $estado.imagem)

                        CampoTextoMock(rotulo: "Título da Receita", placeholder: "Ex: Bolo de chocolate", texto: $estado.titulo)
                        CampoTextoMock(rotulo: "Porções", placeholder: "Ex: 5 pessoas", texto: $estado.porcoes)
                        CampoTextoMock(rotulo: "Tempo de preparo", placeholder: "Ex: 30 min", texto: $estado.tempoDePreparo)

                        SeletorCategoriaMock(
                            categoriaSelecionada: estado.categoria,
                            aoTocar: { estado.mostrarSheetCategoria = true }
                        )

                        Divider()

                        // MARK: Ingredientes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredientes:")
                                .font(FontesAppMock.semibold)
                                .foregroundStyle(.black.opacity(0.8))

                            VStack(spacing: 8) {
                                TextField("Ingrediente (ex: Chocolate)", text: $estado.nomeIngredienteTexto)
                                Divider()
                                TextField("Quantidade (ex: 1)", text: $estado.quantidadeTexto)
                                    .keyboardType(.decimalPad)
                                Divider()
                                TextField("Medida (ex: xícara)", text: $estado.medidaTexto)
                                Divider()
                                Button {
                                    estado.adicionarIngrediente()
                                } label: {
                                    Label("Adicionar Ingrediente", systemImage: "plus")
                                        .font(FontesAppMock.semibold)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 4)
                            }
                            .padding(16)
                            .background(Color(red: 0.93, green: 0.90, blue: 0.72))
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                            ForEach(estado.ingredientesAdicionados) { item in
                                Text("• \(item.quantidade) \(item.medida) - \(item.nome)")
                                    .font(FontesAppMock.corpo)
                                    .foregroundStyle(.black.opacity(0.8))
                                    .padding(.leading, 8)
                            }
                        }

                        Divider()

                        // MARK: Modo de preparo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Modo de Preparo:")
                                .font(FontesAppMock.semibold)
                                .foregroundStyle(.black.opacity(0.8))

                            ForEach(estado.passosAdicionados) { passo in
                                Text("Etapa \(passo.numero): \(passo.texto)")
                                    .font(FontesAppMock.corpo)
                                    .foregroundStyle(.black.opacity(0.8))
                                    .padding(.leading, 8)
                            }

                            EtapaCampoMock(
                                numero: estado.passosAdicionados.count + 1,
                                texto: $estado.descricaoDoPasso
                            )

                            Button {
                                estado.adicionarPasso()
                            } label: {
                                Label("Adicionar Etapa", systemImage: "plus")
                                    .font(FontesAppMock.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(16)
                            .background(Color(red: 0.93, green: 0.90, blue: 0.72))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Anotar receita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { voltar() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black.opacity(0.7))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { voltar() }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                }
            }
            .sheet(isPresented: $estado.mostrarSheetCategoria) {
                CategoriaSheetMock(
                    categoriaSelecionada: estado.categoria,
                    aoSelecionar: { nova in estado.categoria = nova }
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CriarReceitaMockView()
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/TituloSecao.swift\ ⁠
⁠ swift
//
//  TituloSecao.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct TituloSecao: View {
    let texto: String

    var body: some View {
        Text(texto)
            .font(FontesApp.subtitulo)
            .foregroundStyle(.cordosTextos)
    }
}
#Preview {
    TituloSecao(texto: "Título da seção")
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/CategoriaSheetView.swift\ ⁠
⁠ swift
//
//  CategoriaSheetView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//

import SwiftUI

struct CategoriaSheetView: View {
    @Environment(\.dismiss) private var fechar

    let categoriaSelecionada: CategoriaReceita?
    var aoSelecionar: (CategoriaReceita) -> Void

    var body: some View {
        ZStack {
            Color(.cordoFundo)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: { fechar() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.cordosTextos)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    Text("Adicionar categoria")
                        .font(FontesApp.subtitulo)
                        .foregroundStyle(.cordosTextos)

                    Spacer()

                    Button(action: { fechar() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color(.cordosTextos), in: Circle())
                    }
                }

                Text("Selecione uma etiqueta com o nome da categoria que você quer escolher para sua receita.")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos.opacity(0.7))

                VStack(spacing: 16) {
                    ForEach(CategoriaReceita.allCases) { categoria in
                        CategoriaEtiquetaButton(
                            categoria: categoria,
                            selecionada: categoria == categoriaSelecionada,
                            aoSelecionar: {
                                aoSelecionar(categoria)
                                fechar()
                            }
                        )
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    CategoriaSheetView(categoriaSelecionada: .sobremesa, aoSelecionar: { _ in })
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/FotoSeletorView.swift\ ⁠
⁠ swift
//
//  FotoSeletorView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//

import SwiftUI
import PhotosUI

struct FotoSeletorView: View {
    @Binding var imagemSelecionada: UIImage?
    @State private var itemSelecionado: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Adicionar foto")
                .font(FontesApp.Semibold)
                .foregroundStyle(.cordosTextos)

            PhotosPicker(selection: $itemSelecionado, matching: .images) {
                HStack(spacing: 12) {
                    if let imagemSelecionada {
                        Image(uiImage: imagemSelecionada)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.cordosTextos.opacity(0.7))
                    }

                    Text(imagemSelecionada == nil ? "Selecione uma imagem" : "Imagem selecionada")
                        .font(FontesApp.corpo)
                        .foregroundStyle(.cordosTextos.opacity(0.7))

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
            }
            .onChange(of: itemSelecionado) { _, novoItem in
                Task {
                    guard let dados = try? await novoItem?.loadTransferable(type: Data.self) else { return }
                    imagemSelecionada = UIImage(data: dados)
                }
            }
        }
    }
}
#Preview {

}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/CapsulaDetalhes.swift\ ⁠
⁠ swift
//
//  Capsula.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
import SwiftUI

struct CapsulaDetalhes: View {
   let detalhe: TipoDetalhe
    
    var body: some View {
        HStack(spacing: 8) {
            
            Image(systemName: detalhe.iconePadrao)
                            .font(FontesApp.Semibold)
                            .foregroundStyle(.cordosTextos)
                        
                        Text(detalhe.textoFormatado)
                            .font(FontesApp.Semibold)
                            .foregroundStyle(.cordosTextos)
                
        }
        .padding(.vertical,8)
        .padding(.horizontal)
        .background(.corFundoCapsula)

        .clipShape(Capsule())
        .shadow(radius: 2)
    
    }
}
#Preview {
    CapsulaDetalhes(detalhe: .tempo(100))
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/TrocarPagina.swift\ ⁠
⁠ swift
//
//  TrocarPagina.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TrocarPagina: View {
    
    let paginaAtual: Int
    let totalPaginas: Int
    
    let voltar: () -> Void
    let avancar: () -> Void
    
    var body: some View {
        
        GeometryReader { geo in
            
            HStack {
 
                Button(action: voltar) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
                .frame(
                    width: geo.size.width * 0.30,
                    height: 50
                )
                .contentShape(Rectangle())
                .glassEffect()
                
                Text("\(paginaAtual)/\(totalPaginas)")
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .frame(
                        width: geo.size.width * 0.20,
                        height: 50
                    )
        
                Button(action: avancar) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.black)
                        .font(.system(size: 25))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
                .frame(
                    width: geo.size.width * 0.30,
                    height: 50
                )
                .contentShape(Rectangle())
                .glassEffect()
            }
            .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    TrocarPagina(
        paginaAtual: 1,
        totalPaginas: 5,
        voltar: {},
        avancar: {}
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/DividerPersonalizado.swift\ ⁠
⁠ swift
//
//  DividerDoApp.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 21/08/26.
//
import SwiftUI

struct DividerPersonalizado: View {
    var body: some View {
        Rectangle()
            .fill(Color(.corDivider))
            .frame(height: 2)
    }
}
#Preview{
    DividerPersonalizado()
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/ProgressoOnboarding.swift\ ⁠
⁠ swift
//
//  progressoOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI

struct ProgressoOnboarding: View {

    let paginaAtual: Int
    let totalDePaginas: Int
    
    var body: some View {
        HStack(spacing: 7) {
            
            ForEach(0..<totalDePaginas, id: \.self) { index in
                
                Capsule()
                    .fill(
                        index == paginaAtual - 1
                        ? (Color.cordoBotao)
                        : Color.gray.opacity(0.5)
                    )
                    .frame(width: 30, height: 5)
            }
        }
        .padding(.top, 38)
    }
}

#Preview {
    ProgressoOnboarding(paginaAtual: 0, totalDePaginas: 5)
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/BotaoOnboarding.swift\ ⁠
⁠ swift
//
//  BotaoOnboarding.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//
import SwiftUI

struct BotaoOnboarding: View {
    
    var textoBotao: String = "Confirmar"
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(textoBotao)
                .font(FontesApp.Botao)
                .foregroundStyle(Color.cordoFundo)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.cordoBotao)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
        }
    }
}
#Preview {
    BotaoOnboarding(
        
        action: {}
    )
    
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/CategoriaEtiquetaButton.swift\ ⁠
⁠ swift
//
//  CategoriaEtiquetaButton.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct CategoriaEtiquetaButton: View {
    let categoria: CategoriaReceita
    let selecionada: Bool
    var aoSelecionar: () -> Void

    var body: some View {
        Button(action: aoSelecionar) {
            HStack {
                Text(categoria.nomeExibicao)
                    .font(FontesApp.subtitulo)
                    .foregroundStyle(.white)

                Spacer()

                if selecionada {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .padding(.trailing, 24)
                }
            }
            .padding(.leading, 20)
            .padding(.vertical, 18)
            .background(selecionada ? categoria.cor : categoria.cor.opacity(0.40))
            .clipShape(EtiquetaSeta())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoriaEtiquetaButton(categoria: .cafeDaManha, selecionada: true, aoSelecionar: {})
        .padding()
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/ReceitaEtapaCardView.swift\ ⁠
⁠ swift
//
//  ReceitaEtapaCardView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct ReceitaEtapaCardView: View {
    let numero: Int16
    let nome: String
    let texto: String
    let imagemData: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CartaoClaro {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Etapa \(numero): \(nome)")
                        .font(FontesApp.subtitulo)
                        .foregroundStyle(.cordosTextos)

                    DividerPersonalizado()

                    Text(texto)
                        .font(FontesApp.corpo)
                        .foregroundStyle(.cordosTextos)
                }
            }

//            if let imagemData, let uiImage = UIImage(data: imagemData) {
              GeometryReader { geo in
//                    Image(uiImage: uiImage)
            Image("bolo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                //}
                .aspectRatio(308.0 / 188.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}
#Preview {
    ReceitaEtapaCardView(numero: 1, nome: "Leo", texto: "ola", imagemData: "")
}
 ⁠

---

### Arquivo: \⁠ ./View/Componentes/EtapaCampoView.swift\ ⁠
⁠ swift
//
//  EtapaCampoView\.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//

import SwiftUI

struct EtapaCampoView: View {
    let numero: Int
    @Binding var texto: String

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("Etapa \(numero):")
                .font(FontesApp.corpo)
                .foregroundStyle(.cordosTextos)

            TextField("Ex: Misture os ovos e a manteiga", text: $texto, axis: .vertical)
                .font(FontesApp.corpo)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.corFundoCapsula))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
#Preview {
    EtapaCampoView(numero: 1, texto: .constant(""))
}
 ⁠

---

### Arquivo: \⁠ ./View/TelaDeApresetacao.swift\ ⁠
⁠ swift
//
//  TeladeApresentação.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct TelaDeApresetacao: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                Text("Bem-Vindo(a) ao OVÔ")
                    .font(FontesApp.titulo)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                Text("O seu app para\n anotar as receitas\n do dia a dia!")
                    .multilineTextAlignment(.center)
                    .font(FontesApp.tituloComTexto)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                Image("Ovo0")
                    .resizable()
                    .scaledToFit()
                    .frame(width:geo.size.height * 0.35)
                
                Spacer()
                
                
                BotaoOnboarding(textoBotao: "Continuar") {
//                    router.push(.onboarding)
                    viewModel.continuar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}


#Preview{
    TelaDeApresetacao(viewModel: OnboardingViewModel())
}
 ⁠

---

### Arquivo: \⁠ ./View/DetalhesReceitaView.swift\ ⁠
⁠ swift
//    //
//    //  DetalhesReceitaView.swift
//    //  Omi
//    //
//    //  Created by Igor Carrasco on 19/08/26.
//    //
//
import SwiftUI
//import CoreData

struct DetalhesReceitaView: View {
    let receita: ReceitaModel
    
    
    var body: some View {
        GeometryReader { geo in
            
            
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        ZStack(alignment: .bottomLeading){
                            ReceitaHeroView(
                                imagemData: receita.titulo,
                                titulo: receita.titulo
                            )
                            HStack(){
                                CapsulaDetalhes(detalhe: .tempo(receita.tempoDePreparo))
                                    .position(
                                        x: geo.size.width * 0.15,y: geo.size.width * 0.48)
                                CapsulaDetalhes(detalhe: .pessoas(receita.porcoes))
                                    .position(x: geo.size.width * -0.03,y: geo.size.width * 0.48)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Descrição:")
                            CartaoClaro {
                                Text(receita.descricao)
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Ingredientes:")
                            CartaoClaro {
                                ForEach(receita.ingredientes) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                        Text("\(item.quantidade) \(item.medida) de \(item.nome)")
                                    }
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Modo de Preparo:")
                            VStack(spacing: 16) {
                                ForEach(receita.passos) { passo in
                                    ReceitaEtapaCardView(
                                        numero: passo.etapa,
                                        nome: passo.nome,
                                        texto: passo.texto,
                                        imagemData: passo.nome
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink(
                    item: "Confira a receita de \(receita.titulo) no Omi!\n\n\(receita.descricao)",
                    subject: Text(receita.titulo),
                    message: Text("Enviado via Omi App")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    // Action for edit
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        DetalhesReceitaView(
            receita: ReceitaModel(
                id: UUID(),
                titulo: "Bolo de Cenoura",
                categoria: .sobremesa,
                descricao: "O bolo de cenoura é uma receita clássica e amada por todos! Com sua massa fofinha e saborosa, esse bolo é perfeito para um lanche da tarde ou como sobremesa em qualquer ocasião.",
                imagem: "",
                tempoDePreparo: 40,
                porcoes: "8",
                dificuldade: nil,
                dataCriacao: Date(),
                dataAtualizacao: nil,
                ingredientes: [
                    IngredienteModel(id: UUID(), nome: "cenouras médias", quantidade: "3", medida: "unidades"),
                    IngredienteModel(id: UUID(), nome: "ovos", quantidade: "4", medida: "unidades")
                ],
                passos: [
                    PassoModel(id: UUID(), etapa: 1, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40, imagem: ""),
                    PassoModel(id: UUID(), etapa: 2, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40, imagem: "")
                    
                ]
            )
        )
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/TelaInicial.swift\ ⁠
⁠ swift
//
//  TelaInicial.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TelaInicial: View {
    
    @Bindable var viewModel: LivroReceitasViewModel
//    @Bindable var viewModelLivroSimples: LivroReceitasViewModel
    @State private var pesquisa = ""
    @State private var mostrarLivroAberto = false
    
    private let animacaoLivro = Animation.spring(
        response: 0.65,
        dampingFraction: 0.78
    )
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Image("fundo")
                    .resizable()
                    .ignoresSafeArea()
                
                
                VStack {
                    
                    Text("Receitas")
                        .font(FontesApp.titulo)
                        .padding(.trailing, geo.size.width * 0.45)
                        .padding(geo.size.width * 0.04)
                    
                    
                    ZStack(alignment: .leading) {
                        
                        Image("albumAbertoVermelho")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 1.00)
                            .opacity(viewModel.livroAberto ? 1 : 0)
                            .ignoresSafeArea(edges: .all)
                        
                        if viewModel.livroAberto {
                            LivroReceitasViewSimples(viewModel: viewModel)
                                .frame(
                                    width: geo.size.width * 0.75,
                                    height: geo.size.height * 0.55
                                )
                                .padding(.leading, geo.size.width * 0.12)
                                .transition(.opacity)
                                .zIndex(2)
                        }
                        
                        Image("ReceitaTelaInicial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.90)
                            .rotation3DEffect(
                                .degrees(viewModel.livroAberto ? -90 : 0),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .leading,
                                perspective: 0.35
                            )
                            .shadow(color: .black.opacity(0.25), radius: 14, x: 8, y: 10)
                            .zIndex(1)
                            .padding(.horizontal, 30)
                    }
                    
                    .clipped()
                    .contentShape(Rectangle())
                                        
                    .onTapGesture {
                        
                        abrirLivro()
                    }
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: viewModel.paginaAtual
                    )
                    
                    TrocarPagina(
                        paginaAtual: viewModel.paginaAtual,
                        totalPaginas: viewModel.totalPaginas,
                        
                        voltar: {
                            withAnimation(
                                .easeInOut(duration: 0.4)
                            ) {
                                viewModel.voltar()
                            }
                        },
                        
                        avancar: {
                            if !viewModel.livroAberto {
                                abrirLivro()
                                return
                            }
                            withAnimation(
                                .easeInOut(duration: 0.4)
                            ) {
                                viewModel.avancar()
                            }
                        }
                    )
                    .frame(height: geo.size.width * 0.18)
                }
            }
        }
        
        .searchable(
            text: $pesquisa,
            prompt: "Pesquisar receitas"
        )
        
        .toolbar {
            
            ToolbarItemGroup(
                placement: .bottomBar
            ) {
                
                HStack {
                    
                    Image(
                        systemName: "magnifyingglass"
                    )
                    
                    TextField(
                        "Pesquisar",
                        text: $pesquisa
                    )
                    .textFieldStyle(.plain)
                }
                .padding(.horizontal, 27)
                .frame(height: 45)
                
                Spacer()
                
                Button {
                    print("Adicionar receita")
                } label: {
                    
                    Image(
                        systemName: "plus"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold
                        )
                    )
                }
            }
        }
    }
    
    private func abrirLivro() {
        
        guard !viewModel.livroAberto else {
            return
        }
    
        withAnimation(animacaoLivro) {
            viewModel.abrirLivro()
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.50
        ) {
            withAnimation(.easeInOut(duration: 0.15)) {
                mostrarLivroAberto = true
            }
        }
        
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.65
        ) {
            viewModel.avancar()
        }
    }
}


#Preview {
    TelaInicial(viewModel: LivroReceitasViewModel.preview)
}
 ⁠

---

### Arquivo: \⁠ ./View/ContentViewCoreDataTestes.swift\ ⁠
⁠ swift
////
////  ContentView.swift
////  Omi
////
////  Created by Leonardo Gonçalves da Silva on 14/08/26.
////
//
//import SwiftUI
//
//struct ContentViewCoreDataTestes: View {
//    // É o contexto do Persistence, lida com a persistência no CoreData
//    @Environment(\.managedObjectContext) private var contexto
//    
//    @State private var mostrarForm: Bool = false
//        
//    var body: some View {
//        NavigationStack {
//            VStack{
//                LivroReceitasViewSimples(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
//            }
//            .navigationTitle("Minhas Receitas")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button{
//                        mostrarForm.toggle()
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                    .sheet(isPresented: $mostrarForm) {
//                        CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    // recebe o .preview que é uma inicialização em ambiente controlado, ambiente de pre-visualização. Em ambiente de produção/buildado o banco tem outros elementos.
//    ContentViewCoreDataTestes()
//        .environment(\.managedObjectContext, ReceitaRepositorioCoreData.preview)
//}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding5.swift\ ⁠
⁠ swift
//
//  Onboarding5.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct Onboarding5: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[4]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
                    .padding(.top, geo.size.height * 0.035)
 
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width:geo.size.height * 0.30)
                
                Spacer()
                
                VStack{
                    Text("Ao ")
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    +
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.ExtraBold)
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
//                    router.push(.telaInicial)
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Tela 5") {
    Onboarding5(
        viewModel: OnboardingViewModel()
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/LivroReceitasViewSimples.swift\ ⁠
⁠ swift
////
////  LivroReceitasViewSimples.swift
////  Omi
////
////  Created by Igor Carrasco on 19/08/26.
////

import SwiftUI

struct LivroReceitasViewSimples: View {
    // repo j[a vem injetado por fora
    // @Bindable permite usar o $viewModel.categoriaAtual com Picker/conteole
    @Bindable var viewModel: LivroReceitasViewModel

    var body: some View {
        Picker("Categoria", selection: $viewModel.categoriaAtual) {
            ForEach(CategoriaReceita.allCases) { categoria in
                Text(categoria.rawValue).tag(categoria)
            }
        }
        .pickerStyle(.segmented)
        
        if viewModel.receitasFiltradas.isEmpty {
            ContentUnavailableView("Nenhuma receita nessa categoria", systemImage: "book")
        } else {
            TabView {
                ForEach(viewModel.receitasFiltradas) { receita in
                    ReceitaPageView(
                        receita: receita
                    )
                }
            }
            .tabViewStyle(.page)
        }
    }
}

#Preview {
    LivroReceitasViewSimples(viewModel: .preview)
}
 ⁠

---

### Arquivo: \⁠ ./View/RotasDestinoView.swift\ ⁠
⁠ swift
//
//  RotasDestinoView.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import SwiftUI

// Único lugar do App que transforma Rota em View

struct RotasDestinoView: View {
    let rota: Rota
    
    @Environment(\.managedObjectContext) private var contexto
    
    var body: some View {
        switch rota {
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel())
            
        case .telaInicial:
            TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
        
        case .detalheReceita(let receita):
            DetalhesReceitaView(receita: receita)
            
        case .criarReceita:
            CriarReceitaView(viewModel: CriarReceitaViewModel(modo: .criar, repo: ReceitaRepositorioCoreData(context: contexto)))
            

            
//        case .listaIngredientes:
//            ListaIngredientesView(viewModel: IngredientesViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./View/CriarReceitaView.swift\ ⁠
⁠ swift
//
//  CriarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 18/08/26.
//
import SwiftUI
import PhotosUI

struct CriarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @Bindable var viewModel: CriarReceitaViewModel
    @State private var itemSelecionado: PhotosPickerItem?   // ✅ estado local do picker
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: Foto (agora funcional, ligada a viewModel.imagem: Data?)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Adicionar foto")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            PhotosPicker(selection: $itemSelecionado, matching: .images) {
                                HStack(spacing: 12) {
                                    if let dados = viewModel.imagem, let uiImage = UIImage(data: dados) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                    }
                                    
                                    Text(viewModel.imagem == nil ? "Selecione uma imagem" : "Imagem selecionada")
                                        .font(FontesApp.corpo)
                                    
                                    Spacer()
                                }
                                .foregroundStyle(.cordosTextos.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                            }
                            .onChange(of: itemSelecionado) { _, novoItem in
                                Task {
                                    if let dados = try? await novoItem?.loadTransferable(type: Data.self) {
                                        viewModel.imagem = dados
                                    }
                                }
                            }
                        }
                        
                        // Recipe Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Título da Receita")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: Bolo de chocolate", text: $viewModel.titulo)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // Portions
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Porções")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: 5 pessoas", text: $viewModel.porcoesTexto)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // Prep Time
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tempo de preparo")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            TextField("Ex: 30 min", text: $viewModel.tempoDePreparoTexto)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.corFundoCapsula))
                                .clipShape(Capsule())
                        }
                        
                        // MARK: Categoria (estava faltando na sua versão — necessário pra salvar corretamente)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Categoria")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            Picker("Categoria", selection: $viewModel.categoria) {
                                ForEach(CategoriaReceita.allCases) { cat in
                                    Text(cat.nomeExibicao).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.corFundoCapsula))
                            .clipShape(Capsule())
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredientes:")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            VStack(spacing: 8) {
                                TextField("Ingrediente (ex: Chocolate)", text: $viewModel.nomeIngredienteTexto)
                                TextField("Quantidade (ex: 1)", text: $viewModel.quantidadeTexto)
                                TextField("Medida (ex: xícara)", text: $viewModel.medidaTexto)
                                
                                Button(action: {
                                    viewModel.adicionarIngrediente()
                                }) {
                                    Label("Adicionar Ingrediente", systemImage: "plus")
                                        .font(FontesApp.Semibold)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 4)
                            }
                            .padding(16)
                            .background(Color(.corFundoCapsula))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            ForEach(viewModel.ingredientesAdicionados) { item in
                                Text("• \(item.quantidade.formatted()) \(item.medida) - \(item.nome)")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Preparation Steps Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Modo de Preparo:")
                                .font(FontesApp.Semibold)
                                .foregroundStyle(.cordosTextos)
                            
                            VStack(spacing: 8) {
                                TextField("Nome da etapa", text: $viewModel.nomeDoPasso)
                                TextEditor(text: $viewModel.descricaoDoPasso)
                                    .frame(minHeight: 80)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Button(action: {
                                    viewModel.adicionarPasso()
                                }) {
                                    Label("Adicionar Etapa", systemImage: "plus")
                                        .font(FontesApp.Semibold)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(16)
                            .background(Color(.corFundoCapsula))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            ForEach(viewModel.passosAdicionados) { passo in
                                Text("Etapa \(passo.etapa): \(passo.nome)")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(viewModel.tituloDaTela)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { voltar() }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.salvarReceitaNoBanco()
                        voltar()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                }
            }
        }
    }
}

#Preview("Criar") {
    CriarReceitaView(viewModel: .preview)
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding3.swift\ ⁠
⁠ swift
//
//  Onboarding3.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct Onboarding3: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[2]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width:geo.size.height * 0.25)
                
                
                Spacer()
                
                VStack{
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.tituloComTexto)
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black.opacity(0.7))
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Tela 3") {
    Onboarding3(
        viewModel: OnboardingViewModel()
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding1.swift\ ⁠
⁠ swift
//
//  Onboarding1.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI

struct Onboarding1: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[0]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width:geo.size.height * 0.35)
                
                
                Spacer()
                
                VStack{
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Tela 1") {
    Onboarding1(
        viewModel: OnboardingViewModel()
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding4.swift\ ⁠
⁠ swift
//
//  Onboarding4.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 18/08/26.
//

import SwiftUI

struct Onboarding4: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[2]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.top, geo.size.height * 0.035)
                
                Spacer()
                
                
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width:geo.size.height * 0.25)
                
                
                Spacer()
                
                VStack{
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.tituloComTexto)
                }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black.opacity(0.7))
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: geo.size.width * 0.80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cordoFundo)
        }
    }
}

#Preview("Tela 4") {
    Onboarding4(
        viewModel: OnboardingViewModel()
    )
}
 ⁠

---

### Arquivo: \⁠ ./View/OnboardingView.swift\ ⁠
⁠ swift
//
//  OnboardingView.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppRouter.self) private var router
    @Bindable var viewModel = OnboardingViewModel()
    
    var body: some View {
        Group{
            switch viewModel.paginaAtual {
            case 0:
                TelaDeApresetacao(viewModel: viewModel)
            case 1:
                Onboarding1(viewModel: viewModel)
            case 2:
                Onboarding2(viewModel: viewModel)
            case 3:
                Onboarding3(viewModel: viewModel)
            case 4:
                Onboarding4(viewModel: viewModel)
            case 5:
                Onboarding5(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .onChange(of: viewModel.finalizado) { _, finalizado in
            if finalizado {
                router.finalizarOnboarding()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
 ⁠

---

### Arquivo: \⁠ ./View/Onboarding2.swift\ ⁠
⁠ swift
//
//  Onboarding2.swift
//  On bording
//
//  Created by Guilherme Alves de Souza on 17/08/26.
//

import SwiftUI
struct Onboarding2: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    private var pagina: OnboardingModel {
        viewModel.paginas[1]
    }
    
    private let postits = [
        "Etiqueta laranja",
        "Etiqueta amarela",
        "Etiqueta verde",
        "Etiqueta azul",
        "Etiqueta vermelha"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack() {
                
                ProgressoOnboarding(
                    paginaAtual: viewModel.paginaAtual,
                    totalDePaginas: viewModel.totalDePaginas - 1
                )
                
                Text(pagina.titulo)
                    .font(FontesApp.titulo)
                    .foregroundStyle(Color.cordosTextos)
                    .padding(.top, geometry.size.height * 0.035)
                
                Spacer()
                
                ZStack() {
                    
                    
                    HStack(spacing: 2) {
                        ForEach(postits.indices, id: \.self) { index in
                            
                            PostitOnboarding(imagem: postits[index],ativo: viewModel.postitAtivo == index)
                            .frame(width: geometry.size.width * 0.099)
                        }
                    }
                    .padding(.leading, geometry.size.height * 0.06)
                    .offset(y: -geometry.size.height * 0.23)
                    Image(pagina.imagem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.70)
                }
                
                
                
                VStack{
                    Text(pagina.descricao)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    Text("com ")
                    +
                    (pagina.palavraDestaque2.map { Text($0) } ?? Text(""))
                        .font(FontesApp.ExtraBold)
                    }
                
                    .font(FontesApp.tituloComTexto)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.cordosTextos)
                
                Spacer()
                
                BotaoOnboarding(textoBotao: "Continuar") {
                    viewModel.continuar()
                }
                .frame(width: min(geometry.size.width * 0.78,305))
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
            .background(Color.cordoFundo)
        }
        .task {
            await viewModel.iniciarAnimacaoPostIts()
        }
    }
}

#Preview("Tela 2") {
    Onboarding2(
        viewModel: OnboardingViewModel()
    )
}
 ⁠

---

### Arquivo: \⁠ ./OmiApp.swift\ ⁠
⁠ swift
    //
    //  OmiApp.swift
    //  Omi
    //
    //  Created by Leonardo Gonçalves da Silva on 14/08/26.
    //

    import SwiftUI
    import CoreData

    @main
    struct OmiApp: App {
        let persistentController = PersistenceController.shared
        @State private var router = AppRouter()
        
        // Le do UserDefaults quando é finalizado pelo finalizarOnboarding()
        // @AppStorage observa a notificação de mudança
        @AppStorage("onboardingConcluido") private var onboardingConcluido: Bool = false

        var body: some Scene {
            WindowGroup {
                if onboardingConcluido {
                    NavigationStack(path: $router.path) {
                        TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: persistentController.container.viewContext)))
                    }
                    .navigationDestination(for: Rota.self) { rota in
                        RotasDestinoView(rota: rota)
                    }
                } else {
                    NavigationStack(path: $router.path) {
                        OnboardingView(viewModel: OnboardingViewModel())
                            .navigationDestination(for: Rota.self) { rota in
                                RotasDestinoView(rota: rota)
                            }
                    }
                }
            }
            .environment(\.managedObjectContext, persistentController.container.viewContext)
            .environment(router)
        }
    }
 ⁠

---

### Arquivo: \⁠ ./Font/Fontes.swift\ ⁠
⁠ swift
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
}


    
 ⁠

---

### Arquivo: \⁠ ./Data/PreviewData.swift\ ⁠
⁠ swift
//
//  PreviewData.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import CoreData

enum PreviewData {
    static func receitas(context: NSManagedObjectContext) {
        for i in 1...5 {
            let receita = Receita(context: context)
            
            receita.id = UUID()
            receita.titulo = "Receita \(i)"
        }
        
        try? context.save()
    }
}

// Como aqui é sobre Preview e també importa o CoreData, posso chamar extensions do que preciso criar para passar chamar no preview
extension LivroReceitasViewModel {
    static var preview: LivroReceitasViewModel {
        LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}

extension TelaInicialViewModel {
    static var preview: TelaInicialViewModel {
        TelaInicialViewModel(repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}

// .preview para o ContentViewCoreDataTestes
extension ReceitaRepositorioCoreData {
    static var preview: NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }
}

extension CriarReceitaViewModel {
    static var preview: CriarReceitaViewModel {
        CriarReceitaViewModel(modo: .criar, repo: ReceitaRepositorioCoreData(context: PersistenceController.preview.container.viewContext))
    }
}
 ⁠

---

### Arquivo: \⁠ ./Data/ReceitaRepositorioCoreData.swift\ ⁠
⁠ swift
//
//  ReceitasRepo.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 17/08/26.
//
import CoreData

// Implementação concreta usando CoreData
final class ReceitaRepositorioCoreData: ReceitaRepositorio {
    private let contexto: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.contexto = context
    }
    
    private func saveData() {
        do {
            try contexto.save()
        } catch {
            contexto.rollback()
            print("ERRO AO SALVAR COREDATA: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create
    
    // O segredo para não duplicar dados!
    private func buscarOuCriarIngrediente(nome: String) throws -> Ingrediente {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)
        
        let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
        // O '[c]' no final do %m avisa o Core Data para ignorar maiúsculas e minúsculas!
        // Assim "Chocolate" e "chocolate" são reconhecidos como o mesmo item.
        request.predicate = NSPredicate(format: "nome == [c] %@", nomeLimpo)
        request.fetchLimit = 1
        
        let resultados = try contexto.fetch(request)
        
        // Se já existe, retorna o que achou no banco
        if let ingredienteExistente = resultados.first {
            return ingredienteExistente
        } else {
            // Se não existe, cria um novo (mas não dá save ainda, vamos salvar tudo junto com a receita)
            let novoIngrediente = Ingrediente(context: contexto)
            novoIngrediente.id = UUID()
            novoIngrediente.nome = nomeLimpo
            return novoIngrediente
        }
    }

    func criarReceita(
        titulo: String,
        categoria: String,
        descricao: String,
        imagem: String,
        tempoDePreparo: Int16,
        porcoes: String,
        dificuldade: String?,
        ingredientes: [IngredienteAdicionado],
        passos: [PassoAdicionado]
    ) throws {
        
        // 1. Cria a Receita principal
        let receita = Receita(context: contexto)
        
        receita.id = UUID()
        receita.titulo = titulo
        receita.categoria = categoria
        receita.descricao = descricao
        receita.imagem = imagem
        receita.tempoDePreparo = tempoDePreparo
        receita.porcoes = porcoes
        receita.dificuldade = dificuldade
        receita.dataCriacao = Date()
        
        // 2. Loop passando por todos os ingredientes que o usuário escolheu
        for item in ingredientes {
            let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
            // Cria a entidade intermediária
            let relacao = IngredienteDaReceita(context: contexto)
            
            relacao.id = UUID()
            relacao.quantidade = String(item.quantidade)
            relacao.medida = item.medida
            relacao.receita = receita
            relacao.ingrediente = ingrediente
        }
        
        // CRIAR OS PASSOS
        for item in passos {
            let passo = PassoReceita(context: contexto)
            
            passo.id = UUID()
            passo.etapa = Int16(item.etapa)
            passo.nome = item.nome
            passo.texto = item.texto
            passo.imagem = nil
            passo.tempoEstimado = Int16(item.tempoEstimado)
            passo.receita = receita
        }
        
        // 4. Salva o contexto (Isso salva a Receita e todas as relações ReceitaIngrediente de uma vez só)
        //            try context.save()
        saveData()
    }
    
    // MARK: - Read
    // Como devolve um [ReceitaModel] e não um [Receita], ele fecha o "vazamento"
    
    func buscarReceitas() throws -> [ReceitaModel] {
            let request = NSFetchRequest<Receita>(entityName: "Receita")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Receita.dataCriacao, ascending: false)]
            let entities = try contexto.fetch(request)
            return entities.map { $0.toModel() }
        }

        func buscarReceita(id: UUID) throws -> ReceitaModel? {
            try buscarReceitaEntity(id: id)?.toModel()
        }

        func buscarIngredientes() throws -> [IngredienteCadastradoModel] {
            let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Ingrediente.nome, ascending: true)]
            let entities = try contexto.fetch(request)
            return entities.map { $0.toModel() }
        }

        func buscarPassos(para receita: Receita) throws -> [PassoReceita] {
            let request = NSFetchRequest<PassoReceita>(entityName: "PassoReceita")
            request.predicate = NSPredicate(format: "receita == %@", receita)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \PassoReceita.etapa, ascending: true)]
            return try contexto.fetch(request)
        }
    // MARK: - Helpers privados de busca por id
    // Um dos poucos lugares do app que ainda "pensa"em NSManagedObject
    private func buscarReceitaEntity(id: UUID) throws -> Receita? {
            let request = NSFetchRequest<Receita>(entityName: "Receita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarPassoEntity(id: UUID) throws -> PassoReceita? {
            let request = NSFetchRequest<PassoReceita>(entityName: "PassoReceita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarIngredienteEntity(id: UUID) throws -> Ingrediente? {
            let request = NSFetchRequest<Ingrediente>(entityName: "Ingrediente")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }

        private func buscarRelacaoEntity(id: UUID) throws -> IngredienteDaReceita? {
            let request = NSFetchRequest<IngredienteDaReceita>(entityName: "IngredienteDaReceita")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try contexto.fetch(request).first
        }
    
    // MARK: - Update
    
    func atualizarReceita(
            id: UUID,
            novoTitulo: String,
            novaCategoria: String,
            novaDescricao: String,
            novaImagem: String,
            novoTempoDePreparo: Int16,
            novasPorcoes: String,
            novaDificuldade: String?
        ) throws {
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
    
    func atualizarReceitaCompleta(
            id: UUID,
            titulo: String,
            categoria: String,
            descricao: String,
            imagem: String,
            tempoDePreparo: Int16,
            porcoes: String,
            dificuldade: String?,
            ingredientes: [IngredienteAdicionado],
            passos: [PassoAdicionado]
        ) throws {
            guard let receita = try buscarReceitaEntity(id: id) else { return }

            receita.titulo = titulo
            receita.categoria = categoria
            receita.descricao = descricao
            receita.imagem = imagem
            receita.tempoDePreparo = tempoDePreparo
            receita.porcoes = porcoes
            receita.dificuldade = dificuldade
            receita.dataAtualizacao = Date()

            // Remove as relações antigas antes de recriar do zero
            if let relacoesAntigas = receita.ingredientesDaReceita as? Set<IngredienteDaReceita> {
                relacoesAntigas.forEach(contexto.delete)
            }
            if let passosAntigos = receita.passo as? Set<PassoReceita> {
                passosAntigos.forEach(contexto.delete)
            }

            for item in ingredientes {
                let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
                let relacao = IngredienteDaReceita(context: contexto)
                relacao.id = UUID()
                relacao.quantidade = String(item.quantidade)
                relacao.medida = item.medida
                relacao.receita = receita
                relacao.ingrediente = ingrediente
            }

            for item in passos {
                let passo = PassoReceita(context: contexto)
                passo.id = UUID()
                passo.etapa = Int16(item.etapa)
                passo.nome = item.nome
                passo.texto = item.texto
                passo.imagem = nil
                passo.tempoEstimado = Int16(item.tempoEstimado)
                passo.receita = receita
            }

            saveData()
        }
    
    func atualizarPasso(
            id: UUID,
            novaEtapa: Int16,
            novoNome: String,
            novoTexto: String,
            novaImagem: String,
            novoTempoEstimado: Int16
        ) throws {
            guard let passo = try buscarPassoEntity(id: id) else { return }

            passo.etapa = novaEtapa
            passo.nome = novoNome
            passo.texto = novoTexto
            passo.imagem = novaImagem
            passo.tempoEstimado = novoTempoEstimado

            saveData()
        }
    
    func atualizarIngredienteDaReceita(
            id: UUID,
            novaQuantidade: String,
            novaMedida: String
        ) throws {
            guard let relacao = try buscarRelacaoEntity(id: id) else { return }

            relacao.quantidade = novaQuantidade
            relacao.medida = novaMedida

            saveData()
        }
    
    // MARK: - Criar passo avulso (fora da criação de receita completa)
    func criarPasso(
        receitaId: UUID,
              etapa: Int16,
              nome: String,
              texto: String,
              imagem: String,
              tempoEstimado: Int16
          ) throws {
              guard let receita = try buscarReceitaEntity(id: receitaId) else { return }

              let passo = PassoReceita(context: contexto)
              passo.id = UUID()
              passo.etapa = etapa
              passo.nome = nome
              passo.texto = texto
              passo.imagem = imagem
              passo.tempoEstimado = tempoEstimado
              passo.receita = receita

              saveData()
          }
    
    func criarIngredienteAvulso(nome: String) throws -> IngredienteCadastradoModel {
            let ingrediente = try buscarOuCriarIngrediente(nome: nome)
            saveData()
            return ingrediente.toModel()
        }
    
    // MARK: - Delete
    // Busca entity pelo id e deleta -  quem chama não precisa ter uma referëncia do NSManagedObject
    func deletarReceita(id: UUID) throws {
            guard let receita = try buscarReceitaEntity(id: id) else { return }
            contexto.delete(receita)
            saveData()
        }
    func deletarPasso(id: UUID) throws {
           guard let passo = try buscarPassoEntity(id: id) else { return }
           contexto.delete(passo)
           saveData()
       }
    
    func deletarIngrediente(id: UUID) throws {
           guard let ingrediente = try buscarIngredienteEntity(id: id) else { return }
           contexto.delete(ingrediente)
           saveData()
       }
    
    
    
}


 ⁠

---

### Arquivo: \⁠ ./Data/Persistence.swift\ ⁠
⁠ swift
//
//  Persistence.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import CoreData

// O NSPersistentContainer monta o NSManagedObjectModel, o NSPersistentStoreCoordinator e entrega um NSManagedObjectContext
// assim o container guarda contexto (rascunho)
struct PersistenceController {
    static let shared = PersistenceController() // É um container que cuida do viewContext do CoreData
    
    // Declara-se o container e precisa ter o mesmo nome do arquivo.xdatamodeld
    let container: NSPersistentContainer
    
    // Inicializa o container e lida com possível erro
    init(emMemoria: Bool = false) {
        container = NSPersistentContainer(name: "Omi")
        
        if emMemoria {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "dev/null")
        }
        
        container.loadPersistentStores { descricao, erro in
            if let erro = erro {
                fatalError("ERRO AO CARREGAR CORE DATA: \(erro.localizedDescription)")
            }
        }
        
        // Configura o container para mesclar automaticamente as mudanças vindas de outros contextos
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Para aplicar nas #Previews das views filhas do App.swift
    @MainActor
    static let preview: PersistenceController = {
        
        let controller = PersistenceController()
        
        let context = controller.container.viewContext
        
        let categorias = ["sobremesa", "salgado", "bebida", "massa", "lanche"]
        
        for i in 1...5 {
            let receita = Receita(context: context)
            
            receita.id = UUID()
            receita.titulo = "Receita \(i)"
            receita.descricao = "Descrição da receita: \(i)"
            receita.categoria = categorias.randomElement()
            receita.tempoDePreparo = Int16(20 + i)
            receita.porcoes = "8"
            receita.dataCriacao = Date()
        }
        
        try? context.save()
        
        return controller
    }()
}


 ⁠

---

### Arquivo: \⁠ ./Data/ReceitaRepositorioProtocolo.swift\ ⁠
⁠ swift
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
    func buscarReceitas() throws -> [ReceitaModel]
    func buscarReceita(id: UUID) throws -> ReceitaModel?
    
    func criarReceita(
        titulo: String,
        categoria: String,
        descricao: String,
        imagem: String,
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
        novaImagem: String,
        novoTempoDePreparo: Int16,
        novasPorcoes: String,
        novaDificuldade: String?
    ) throws
    
    func atualizarReceitaCompleta(
            id: UUID,
            titulo: String,
            categoria: String,
            descricao: String,
            imagem: String,
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
        imagem: String,
        tempoEstimado: Int16
    ) throws
    
    func atualizarPasso(
        id: UUID,
        novaEtapa: Int16,
        novoNome: String,
        novoTexto: String,
        novaImagem: String,
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

 ⁠

---

