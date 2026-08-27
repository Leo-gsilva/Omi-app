### Link Github: 
```https://github.com/Leo-gsilva/Omi-app```

###  Arquivo: `./Omi/Omi/ViewModel/LivroDeReceitasViewModel.swift`

```swift
//
//  LivroDeReceitasViewModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Observation
import SwiftData
import SwiftUI

@Observable
final class LivroReceitasViewModel {
    var paginaAtual: Int = 0                          
    var categoriaAtual: CategoriaReceita = .cafeDaManha
    private(set) var receitas: [ReceitaModel] = []
    var livroAberto: Bool = false
    var pesquisa: String = ""
    
    private let repo: ReceitaRepositorio
    private var observer: NSObjectProtocol?
    // Recebe protocolo e não a classe
    
    init(repo: ReceitaRepositorio) {
        self.repo = repo
        carregarReceitas()
        observarMudancas()
    }
    
    var receitasFiltradas: [ReceitaModel] {
        guard !pesquisa.isEmpty else {
            return receitas.filter { $0.categoria == categoriaAtual }
        }
        
       
        return receitas.filter { receita in
            receita.titulo.localizedCaseInsensitiveContains(pesquisa) ||
            receita.descricao.localizedCaseInsensitiveContains(pesquisa) ||
            receita.categoria.rawValue.localizedCaseInsensitiveContains(pesquisa) ||
            receita.ingredientes.contains {
                $0.nome.localizedCaseInsensitiveContains(pesquisa)
            }
        }
    }
    
    func buscarPorNome(_ nome: String) {
        pesquisa = nome
        paginaAtual = 0
    }
    
    var totalPaginas: Int {
        receitasFiltradas.count
    }
    
   
    var receitaAtual: ReceitaModel? {
        guard paginaAtual >= 1, paginaAtual <= receitasFiltradas.count else { return nil }
        return receitasFiltradas[paginaAtual - 1]
    }
    
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
    
    func abrirLivro() {
        guard !livroAberto else { return }
        livroAberto = true
    }
    
    func selecionarCategoria(_ categoria: CategoriaReceita) {
        categoriaAtual = categoria
        paginaAtual = 0
    }
    
    private func observarMudancas() {
        observer = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave,
            object: nil,
            queue: .main ){ [weak self] _ in
                self?.carregarReceitas()
            }
    }
    
    
    func avancar() {
        if totalPaginas == 0 {
            let categoriaAntes = categoriaAtual
            proximaCategoria()
            if categoriaAtual != categoriaAntes {
                paginaAtual = totalPaginas > 0 ? 1 : 0
            }
            
            return
        }
        if paginaAtual < totalPaginas {
            paginaAtual += 1
        } else {
            let categoriaAntes = categoriaAtual
            proximaCategoria()
            if categoriaAtual != categoriaAntes {
                paginaAtual = 0
            }
        }
    }
    
    func voltar() {
        if totalPaginas == 0 {
            let categoriaAntes = categoriaAtual
            categoriaAnterior()
            if categoriaAtual != categoriaAntes {
                paginaAtual = totalPaginas > 0 ? totalPaginas : 0
            }
            
            return
        }
        if paginaAtual > 1 {
            paginaAtual -= 1
        } else {
            let categoriaAntes = categoriaAtual
            categoriaAnterior()
            if categoriaAtual != categoriaAntes {
                paginaAtual = max(totalPaginas, 0)
            }
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
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

```

---

###  Arquivo: `./Omi/Omi/ViewModel/DetalhesReceitaViewModel.swift`

```swift
//
//  DetalhesReceitaViewModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 19/08/26.
//
import SwiftUI
import Observation

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
        guard let id = receita?.id else { return }
        do {
            if let receitaAtualizada = try repo.buscarReceita(id: id) {
                self.receita = receitaAtualizada
                print("🔄 [SUCESSO] Receita atualizada na tela de detalhes: \(receitaAtualizada.titulo)")
            }
        } catch {
            print("Erro ao carregar detalhes: \(error)")
        }
    }
}

```

---

###  Arquivo: `./Omi/Omi/ViewModel/CriarReceitaViewModel.swift`

```swift
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
    var tempoDePreparoFormatado: String {
        tempoDePreparoTexto.isEmpty ? "" : "\(tempoDePreparoTexto) min"
    }

    var porcoesFormatado: String {
        porcoesTexto.isEmpty ? "" : "\(porcoesTexto) pessoas"
    }
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
        imagem = receita.imagem
        
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

```

---

###  Arquivo: `./Omi/Omi/ViewModel/CategoriaViewModel.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/ViewModel/IngredientesViewModel.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/ViewModel/OnboardingViewModel.swift`

```swift
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
            titulo: "Edite as receitas",
            descricao: "Adicione ",
            palavraDestaque: "fotos, \n",
            palavraDestaque2: "etapas na sua receita.",
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
}

```

---

###  Arquivo: `./Omi/Omi/Navegacao/Rota.swift`

```swift
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
    case onboarding
    case editarReceita(ReceitaModel)
    //case categoriaSheetView
}

extension Rota: Identifiable {
    // Como Rota já é hashable, ela serve como seu próprio id
    var id: Self { self }
}

```

---

###  Arquivo: `./Omi/Omi/Navegacao/AppRouter.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/Model/DataModel.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/Model/ModoModel.swift`

```swift
//
//  ModoModel.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 24/08/26.
//
enum Modo {
    case criar
    case editar(ReceitaModel)
}

```

---

###  Arquivo: `./Omi/Omi/Model/DetalhesReceita.swift`

```swift
//
//  DetalhesReceita.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 26/08/26.
//
enum DetalheReceita {
    case tempo(Int16)
    case pessoas(String)

    var texto: String {
        switch self {
        case .tempo(let minutos): return "\(minutos) min"
        case .pessoas(let qtd): return "\(qtd) pessoas"
        }
    }
}

```

---

###  Arquivo: `./Omi/Omi/Model/CategoriaModel.swift`

```swift
//
//  CategoriaModel.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import SwiftUI

enum CategoriaReceita: String, CaseIterable, Identifiable {
    case cafeDaManha = "Café da Manhã"
    case refeicao = "Refeição"
    case saudavel = "Saudável"
    case sobremesa = "Sobremesa"
    case lanche = "Lanche"

    var id: String {
        rawValue
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

```

---

###  Arquivo: `./Omi/Omi/Model/DetalheModel.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/Model/OnboardingModel.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/ReceitaPageView.swift`

```swift
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
    
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        GeometryReader{ geo in
            ScrollView{
                VStack (spacing: 16){
                    Section{
                        VStack (spacing: 4){
                            if let imagemData = receita.imagem,
                               let uiImage = UIImage(data: imagemData) {
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 426, height: 118)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 226, height: 118)
                        
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        DividerPersonalizado()
                            .padding(.horizontal, 30)
                        
                        Text(receita.titulo)
                            .font(FontesApp.tituloComTexto)
                            .frame(maxWidth: 200, maxHeight: 40)
                            .lineLimit(1)
                        
                        HStack{
                            Image("Tempo")
                            Text("\(receita.tempoDePreparo) min")
                            Image("Fatia")
                            Text("\(receita.porcoes) pessoas")
                        }
                        .font(FontesApp.Semibold)
                        
                    }
                    
                    Text(receita.descricao)
                        .frame(maxWidth: 200, maxHeight: 100)
                        .lineLimit(1)
                    
                    BotaoOnboarding(textoBotao: "Abrir Receita Completa") {
                        router.push(.detalheReceita(receita))
                    }
                    .frame(width: geo.size.width * 0.60)
                    
                }
            }
            .onTapGesture {
                router.push(.detalheReceita(receita))
            }
        }
    }
}

#Preview {
    NavigationStack{
        ReceitaPageView(
            receita: ReceitaModel(
                id: UUID(),
                titulo: "Bolo de Cenoura ADADADADA",
                categoria: .sobremesa,
                descricao: "Receita de teste para Preview.",
                imagem: nil,
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
                    PassoModel(id: UUID(), etapa: 1, nome: "Misture", texto: "Bata tudo no liquidificador.", tempoEstimado: 5),
                    PassoModel(id: UUID(), etapa: 2, nome: "Asse", texto: "Leve ao forno por 40 min.", tempoEstimado: 40)
                ]
            )
        )
    }
    .environment(AppRouter())
}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/BarradeTags.swift`

```swift
//
//  BarradeTags.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 21/08/26.
//

import SwiftUI

struct BarraDeTags: View {
    @Bindable var viewModel: LivroReceitasViewModel

    private let ordemCategorias: [CategoriaReceita] = [
        .cafeDaManha, .refeicao, .saudavel, .sobremesa, .lanche
    ]

    private let tagPorCategoria: [CategoriaReceita: String] = [
        .cafeDaManha: "TagVermelha",
        .refeicao:      "TagAzul",
        .saudavel:      "TagVerde",
        .sobremesa:   "TagAmarela",
        .lanche:     "TagLaranja"
    ]

    var body: some View {
        GeometryReader { geo in
            
            HStack(spacing: 3) {
                
                ForEach(ordemCategorias) { categoria in
                    
                    Image(tagPorCategoria[categoria] ?? "TagVermelha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.10)
                        .offset(
                            y: viewModel.categoriaAtual == categoria
                            ? -14
                            : 0
                        )
                        .contentShape(
                            Rectangle()
                        )
                        .onTapGesture {
                            viewModel.selecionarCategoria(categoria)
                        }
                        .animation(
                            .spring(
                                response: 0.35,
                                dampingFraction: 0.7
                            ),
                            value: viewModel.categoriaAtual
                        )
                }
            }
            .padding(.horizontal, geo.size.width * 0.35)
           
        }
    }
}

#Preview {
    BarraDeTags(viewModel: .preview)
}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/postitOnboarding.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/CartaoClaro.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/ReceitaHeroView.swift`

```swift
//
//  ReceitaHeroView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 20/08/26.
//
import SwiftUI

struct ReceitaHeroView: View {
    let imagemData: Data?
    let titulo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { geo in
              Group {
                    if let imagemData, let uiImage = UIImage(data: imagemData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                    }
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
    ReceitaHeroView(imagemData: nil, titulo: "olha")
}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/TituloSecao.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/CategoriaSheetView.swift`

```swift
////
////  CategoriaSheetView.swift
////  Omi
////
////  Created by Leonardo Gonçalves da Silva on 23/08/26.
////
//
//import SwiftUI
//
//struct CategoriaSheetView: View {
//    @Environment(\.dismiss) private var fechar
//
//    let categoriaSelecionada: CategoriaReceita?
//    var aoSelecionar: (CategoriaReceita) -> Void
//
//    var body: some View {
//        ZStack {
//            Color(.cordoFundo)
//                .ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 20) {
//                HStack {
//                    Button(action: { fechar() }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundStyle(.cordosTextos)
//                            .padding(10)
//                            .background(.ultraThinMaterial, in: Circle())
//                    }
//
//                    Spacer()
//
//                    Text("Adicionar categoria")
//                        .font(FontesApp.subtitulo)
//                        .foregroundStyle(.cordosTextos)
//
//                    Spacer()
//
//                    Button(action: { fechar() }) {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundStyle(.white)
//                            .padding(10)
//                            .background(Color(.cordosTextos), in: Circle())
//                    }
//                }
//
//                Text("Selecione uma etiqueta com o nome da categoria que você quer escolher para sua receita.")
//                    .font(FontesApp.corpo)
//                    .foregroundStyle(.cordosTextos.opacity(0.7))
//
//                VStack(spacing: 16) {
//                    ForEach(CategoriaReceita.allCases) { categoria in
//                        CategoriaEtiquetaButton(
//                            categoria: categoria,
//                            selecionada: categoria == categoriaSelecionada,
//                            aoSelecionar: {
//                                aoSelecionar(categoria)
//                                fechar()
//                            }
//                        )
//                    }
//                }
//
//                Spacer()
//            }
//            .padding(20)
//        }
//    }
//}
//
//#Preview {
//    CategoriaSheetView(categoriaSelecionada: .sobremesa, aoSelecionar: { _ in })
//}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/FormularioReceitaView.swift`

```swift
//
//  FormularioReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 25/08/26.
//
import SwiftUI
import PhotosUI

struct FormularioReceitaView: View {
    @Bindable var viewModel: CriarReceitaViewModel
    @State private var itemSelecionado: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: Foto
            VStack(alignment: .leading, spacing: 6) {
                Text("Adicionar foto")
                    .font(FontesApp.corpo)
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
            
            // MARK: Título
            VStack(alignment: .leading, spacing: 6) {
                Text("Título da Receita")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos)
                
                TextField("Ex: Bolo de chocolate", text: $viewModel.titulo)
                
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.corFundoCapsula))
                    .clipShape(Capsule())
            }
            
            // MARK: Porções
            VStack(alignment: .leading, spacing: 6) {
                Text("Porções")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)

                HStack {
                    TextField("Ex: 5", text: $viewModel.porcoesTexto)
                        .keyboardType(.numberPad)
                    Text("pessoas")
                        .foregroundStyle(.cordosTextos.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
            }
            
            // MARK: Tempo de preparo
            VStack(alignment: .leading, spacing: 6) {
                Text("Tempo de preparo")
                    .font(FontesApp.Semibold)
                    .foregroundStyle(.cordosTextos)

                HStack {
                    TextField("Ex: 30", text: $viewModel.tempoDePreparoTexto)
                        .keyboardType(.numberPad)
                    Text("min")
                        .foregroundStyle(.cordosTextos.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
            }
            
            // MARK: Categoria
            VStack(alignment: .leading, spacing: 6) {
                Text("Categoria")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos)
                Picker("Categoria", selection: $viewModel.categoria) {
                    ForEach(CategoriaReceita.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .frame(width: .infinity)
                .pickerStyle(.automatic)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.corFundoCapsula))
                .clipShape(Capsule())
            }
            
           
            
            
            // MARK: Descrição
            VStack(alignment: .leading, spacing: 6) {
                Text("Descrição:")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos)
                
                TextEditor(text: $viewModel.descricao)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(.corFundoCapsula))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // MARK: Ingredientes
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredientes:")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos)
                
                VStack(spacing: 8) {
                    TextField("Ingrediente (ex: Chocolate)", text: $viewModel.nomeIngredienteTexto)
                    Divider()
                    TextField("Quantidade (ex: 1)", text: $viewModel.quantidadeTexto)
                        .keyboardType(.numberPad)
                    Divider()
                    TextField("Medida (ex: xícara)", text: $viewModel.medidaTexto)
                    
                    Button(action: { viewModel.adicionarIngrediente() }) {
                        Label("Adicionar Ingrediente", systemImage: "plus")
                            .font(FontesApp.Semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 4)
                    
                    if let erro = viewModel.erroIngrediente {
                        Text(erro)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(Color(.corFundoCapsula))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.ingredientesAdicionados.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("• \(item.quantidade.formatted()) \(item.medida) - \(item.nome)")
                                .font(FontesApp.corpo)
                                .foregroundStyle(.cordosTextos)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.ingredientesAdicionados.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 8)
                        DividerPersonalizado()
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // MARK: Modo de preparo
            VStack(alignment: .leading, spacing: 8) {
                Text("Modo de Preparo:")
                    .font(FontesApp.corpo)
                    .foregroundStyle(.cordosTextos)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Nome da etapa", text: $viewModel.nomeDoPasso)
                    Divider()
                    Text("Descrição do Passo:")
                        .font(FontesApp.corpo)
                        .foregroundStyle(.cordosTextos)
                    TextEditor(text: $viewModel.descricaoDoPasso)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .background(Color.cordoFundo)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Button(action: { viewModel.adicionarPasso() }) {
                        Label("Adicionar Etapa", systemImage: "plus")
                            .font(FontesApp.Semibold)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let erro = viewModel.erroPasso {
                        Text(erro)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(Color(.corFundoCapsula))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.passosAdicionados.enumerated()), id: \.offset) { index, passo in
                        HStack {
                            Text("Etapa \(index + 1): \(passo.nome)")
                                .font(FontesApp.corpo)
                                .foregroundStyle(.cordosTextos)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.passosAdicionados.remove(at: index)
                                // Reorganiza o número das etapas automaticamente
                                for i in 0..<viewModel.passosAdicionados.count {
                                    viewModel.passosAdicionados[i].etapa = i + 1
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 8)
                        DividerPersonalizado()
                    }
                }
            }
            
        }
        .padding(20)
    }
}
//#Preview {
//    FormularioReceitaView(viewModel: CriarReceitaViewModel.preview)
//}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/CapsulaDetalhes.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/TrocarPagina.swift`

```swift
//
//  TrocarPagina.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TrocarPagina: View {
    @Bindable var viewModel: LivroReceitasViewModel
      
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
                
                Text("\(viewModel.livroAberto ? viewModel.paginaAtual : 0)/\(viewModel.totalPaginas)")
                    
                    .font(FontesApp.TrocaPagina)
                    .foregroundStyle(Color.cordosTextos)
                    .frame(width: geo.size.width * 0.20,height: 50)
        
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
        viewModel: LivroReceitasViewModel.preview,
        voltar: {},
        avancar: {}
    )
}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/DividerPersonalizado.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/ProgressoOnboarding.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/BotaoOnboarding.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/ReceitaEtapaCardView.swift`

```swift
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
//    let imagemData: Data?

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
        }
    }
}
#Preview {
    ReceitaEtapaCardView(numero: 1, nome: "Leo", texto: "ola")
}

```

---

###  Arquivo: `./Omi/Omi/View/Componentes/LivroInterativo.swift`

```swift
//
//  LivroInterativo.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 24/08/26.
//

import SwiftUI


struct LivroInterativo: View {
    @Bindable var viewModel: LivroReceitasViewModel
    @State private var pesquisa = ""
    
    private let animacaoLivro = Animation.spring(
        response: 0.65,
        dampingFraction: 0.78
    )
    private let coresPorCategoria: [CategoriaReceita: String] = [
        .cafeDaManha: "albumAbertoVermelho",
        .refeicao:      "albumAbertoAzul",
        .saudavel:      "albumAbertoVerde",
        .sobremesa:   "albumAbertoAmarelo",
        .lanche:     "albumAbertoLaranja"
    ]

    private var nomePaginaAtual: String {
        coresPorCategoria[viewModel.categoriaAtual] ?? "albumAbertoVermelho"
    }
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                if viewModel.livroAberto {
                            BarraDeTags(viewModel: viewModel)
                        
                    }

                Image(nomePaginaAtual)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 1.00)
                    .opacity(viewModel.livroAberto ? 1 : 0)
                    .ignoresSafeArea(edges: .all)
                    .id(nomePaginaAtual)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: nomePaginaAtual)
                    .allowsHitTesting(false)
                
                if viewModel.livroAberto {
                    LivroReceitasViewSimples(viewModel: viewModel)
                        .frame(
                            width: geo.size.width * 0.75,
                            height: geo.size.height * 0.55
                        )
                        .padding(.leading, geo.size.width * 0.23)
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
                    .padding(.horizontal, 30)
                    
            }

            .onTapGesture {
                
                abrirLivro()
            }
            .animation(
                .easeInOut(duration: 0.4),
                value: viewModel.paginaAtual
            )
        }
    }
    private func abrirLivro() {
        
        guard !viewModel.livroAberto else { return }
    
        withAnimation(animacaoLivro) {
            viewModel.abrirLivro()
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.50
        ) {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.livroAberto = true
            }
        }
    }
}

#Preview {
    LivroInterativo(viewModel: LivroReceitasViewModel.preview)
}


    

```

---

###  Arquivo: `./Omi/Omi/View/TelaDeApresetacao.swift`

```swift
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
                
                Image("Ovo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:geo.size.height * 0.35)
                
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


#Preview{
    TelaDeApresetacao(viewModel: OnboardingViewModel())
}

```

---

###  Arquivo: `./Omi/Omi/View/EditarReceitaView.swift`

```swift
//
//  EditarReceitaView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 25/08/26.
//
//

import SwiftUI
import PhotosUI

struct EditarReceitaView: View {
    @Environment(\.dismiss) private var voltar
    @State var viewModel: CriarReceitaViewModel
 
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    FormularioReceitaView(viewModel: viewModel)
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
                        if viewModel.salvarReceitaNoBanco() {
                            voltar()
                        }
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

```

---

###  Arquivo: `./Omi/Omi/View/DetalhesReceitaView.swift`

```swift
//    //
//    //  DetalhesReceitaView.swift
//    //  Omi
//    //
//    //  Created by Igor Carrasco on 19/08/26.
//    //
//
import SwiftUI

struct DetalhesReceitaView: View {
    @State var viewModel: DetalhesReceitaViewModel
    @State private var mostrarEdicao = false
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        ZStack(alignment: .bottomLeading){
                            ReceitaHeroView(
                                imagemData: viewModel.receita?.imagem,
                                titulo: viewModel.receita?.titulo ?? ""
                            )
                            HStack(){
                                CapsulaDetalhes(detalhe: .tempo(viewModel.receita?.tempoDePreparo ?? 1))
                                    .position(
                                        x: geo.size.width * 0.15,y: geo.size.width * 0.48)
                                CapsulaDetalhes(detalhe: .pessoas(viewModel.receita?.porcoes ?? "1"))
                                    .position(x: geo.size.width * -0.03,y: geo.size.width * 0.48)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Descrição:")
                            CartaoClaro {
                                Text(viewModel.receita?.descricao ?? "")
                                    .font(FontesApp.corpo)
                                    .foregroundStyle(.cordosTextos)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Categoria:")
                            CartaoClaro{
                                if let categoria = viewModel.receita?.categoria {
                                    Text(categoria.rawValue)
                                        .font(FontesApp.corpo)
                                        .foregroundStyle(.cordosTextos)
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            TituloSecao(texto: "Ingredientes:")
                            CartaoClaro {
                                ForEach(viewModel.receita?.ingredientes ?? [IngredienteModel(id: UUID(), nome: "None", quantidade: "0", medida: "ml")]) { item in
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
                                ForEach(viewModel.receita?.passos ?? [PassoModel(id: UUID(), etapa: 0, nome: "None", texto: "None", tempoEstimado: 1)]) { passo in
                                    ReceitaEtapaCardView(
                                        numero: passo.etapa,
                                        nome: passo.nome,
                                        texto: passo.texto
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
                    item: "Confira a receita de \(viewModel.receita?.titulo ?? "") no Omi!\n\n\(viewModel.receita?.descricao ?? "")",
                    subject: Text(viewModel.receita?.titulo ?? ""),
                    message: Text("Enviado via Omi App")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button ("Editar") {
                    if let receitaAtual = viewModel.receita {
                        router.apresentarSheet(.editarReceita(receitaAtual))
                    }
                }
            }
        }
        // Quando a sheet fechar (vira nil), recarrega os detalhes sozinhos!
        .onChange(of: router.sheetAtual) { antigaRota, novaRota in
          
                viewModel.carregarDetalhes()
            
        }
    }
}

#Preview {
    NavigationStack{
        DetalhesReceitaView(
            viewModel: DetalhesReceitaViewModel.preview
        )
    }
    .environment(AppRouter())
}

```

---

###  Arquivo: `./Omi/Omi/View/TelaInicial.swift`

```swift
import SwiftUI

struct TelaInicial: View {
    @Environment(AppRouter.self) private var router
    @Bindable var viewModel: LivroReceitasViewModel
    @State private var pesquisa = ""
    @FocusState private var buscaAtiva: Bool
    
    var naviTitle: String {
        if !viewModel.livroAberto {
            return "Receita"
        } else {
            return "\(viewModel.categoriaAtual.rawValue)"
            
        }
    }
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("fundo")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer()
                    LivroInterativo(
                        viewModel: viewModel
                    )
                    
                    TrocarPagina(
                        viewModel: viewModel,
                        voltar: {
                            withAnimation(
                                .easeInOut(duration: 0.4)
                            ) {
                                viewModel.voltar()
                            }
                        },
                        avancar: {
                            if !viewModel.livroAberto {
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
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Image(
                        systemName: "magnifyingglass"
                    )
                    
                    TextField("Pesquisar", text: $pesquisa)
                        .textFieldStyle(.plain)
                        .focused($buscaAtiva)
                        .onChange(of: pesquisa) { _, novoValor in
                            viewModel.buscarPorNome(novoValor)
                        }
                }
                .padding(.horizontal, 27)
                .frame(height: 45)
                .contentShape(Rectangle())
                .onTapGesture {
                    buscaAtiva = true
                    pesquisa = ""
                    viewModel.buscarPorNome("")
                }
                
                Spacer()
                
                Button {
                    router.apresentarSheet(.criarReceita)
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
        .navigationTitle(naviTitle)
        
    }
}

#Preview {
    NavigationStack{
        TelaInicial(viewModel: LivroReceitasViewModel.preview)
    }
    .environment(AppRouter())
}

```

---

###  Arquivo: `./Omi/Omi/View/Onboarding5.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/LivroReceitasViewSimples.swift`

```swift
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
        if viewModel.receitasFiltradas.isEmpty {
            ContentUnavailableView("Nenhuma receita nessa categoria", systemImage: "book")
                .font(FontesApp.titulo)
        } else {
            TabView(selection: $viewModel.paginaAtual) {
                ForEach(Array(viewModel.receitasFiltradas.enumerated()), id: \.element.id) { index, receita in
                    ReceitaPageView(
                        receita: receita
                    )
                    .tag(index + 1) // +1 pq a página atual é 1-index
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    LivroReceitasViewSimples(viewModel: .preview)
}

```

---

###  Arquivo: `./Omi/Omi/View/RotasDestinoView.swift`

```swift
//
//  RotasDestinoView.swift
//  Omi
//
//  Created by Igor Carrasco on 20/08/26.
//

import SwiftUI
import SwiftData

// Único lugar do App que transforma Rota em View

struct RotasDestinoView: View {
    let rota: Rota
    
    @Environment(\.modelContext) private var contexto
    
    var body: some View {
        switch rota {
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel())
            
        case .telaInicial:
            TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: contexto)))
        
        case .detalheReceita(let receita):
            DetalhesReceitaView(viewModel: DetalhesReceitaViewModel(receita: receita, repo: ReceitaRepositorioSwiftData(context: contexto)))
            
        case .criarReceita:
            CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioSwiftData(context: contexto), modo: .criar))
        
        case .editarReceita(let receitaParaEditar):
            EditarReceitaView(viewModel: CriarReceitaViewModel(
                repo: ReceitaRepositorioSwiftData(context: contexto),
                modo: .editar(receitaParaEditar) // Se aqui estiver .criar, ele vai duplicar a receita
            ))
            
//        case .categoriaSheetView:
//            CategoriaSheetView(categoriaSelecionada: .refeicao, aoSelecionar: { _ in } )
        }
    }
}

```

---

###  Arquivo: `./Omi/Omi/View/CriarReceitaView.swift`

```swift
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
    @State var viewModel: CriarReceitaViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.cordoFundo)
                    .ignoresSafeArea()
                
                ScrollView {
                    if let erro = viewModel.erroReceita {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                    FormularioReceitaView(viewModel: viewModel)
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
                        if viewModel.salvarReceitaNoBanco() {
                            voltar()
                        }
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

#Preview {
    CriarReceitaView(viewModel: CriarReceitaViewModel.preview)
}

```

---

###  Arquivo: `./Omi/Omi/View/Onboarding3.swift`

```swift
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
                
                
                
                Image(pagina.imagem)
                    .resizable()
                    .scaledToFit()
                    .frame(width:geo.size.height * 0.40)
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

```

---

###  Arquivo: `./Omi/Omi/View/Onboarding1.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/View/Onboarding4.swift`

```swift
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
        viewModel.paginas[3]
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
                    .frame(width:geo.size.height * 0.35)
                
                Spacer()
                
                VStack{
                    Text(pagina.descricao)
                        .font(FontesApp.tituloComTexto)
                    +
                    Text(pagina.palavraDestaque)
                        .font(FontesApp.ExtraBold)
                    
                    +
                    Text("Ingredientes ")
                        .font(FontesApp.ExtraBold)
                    +
                    Text("e\n")
                        .font(FontesApp.tituloComTexto)
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

```

---

###  Arquivo: `./Omi/Omi/View/OnboardingView.swift`

```swift
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
            default:
                Onboarding5(viewModel: viewModel)
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

```

---

###  Arquivo: `./Omi/Omi/View/Onboarding2.swift`

```swift
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
            VStack {
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
                    .offset(y: -geometry.size.height * 0.18)
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

```

---

###  Arquivo: `./Omi/Omi/OmiApp.swift`

```swift
//
//  OmiApp.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import SwiftUI
import SwiftData

@main
struct OmiApp: App {
    @State private var router = AppRouter()
    
    // Le do UserDefaults quando é finalizado pelo finalizarOnboarding()
    // @AppStorage observa a notificação de mudança
    @AppStorage("onboardingConcluido") private var onboardingConcluido: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                Group{
                    if onboardingConcluido {
                        TelaInicial(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: PersistenceSwiftData.container.mainContext)))
                    } else {
                        OnboardingView()
                    }
                }
                .navigationDestination(for: Rota.self) { rota in
                    RotasDestinoView(rota: rota)
                }
            }
            .modelContainer(PersistenceSwiftData.container)
            .environment(router)
            .preferredColorScheme(.light) // ou .dark
            // Aprensenta o criatReceita como um modal, separada da pilha (path). Usa o mesmo RotasDestinoView
            // Muda só como a tela aparece (como sheet, não empurrada na pilha).
            .sheet(item: $router.sheetAtual) { rota in
                RotasDestinoView(rota: rota)
                    .modelContainer(PersistenceSwiftData.container) // Passa o modelContainer novamente pra evitar perda de contexto no futuro, explicitando qual é o contexto a ser observado
            }
        }
    }
}

```

---

###  Arquivo: `./Omi/Omi/Font/Fontes.swift`

```swift
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
    
    static let CorpoPreview = Font.custom(
        "Dosis",
        size: 14,
        relativeTo: .body
    )
        .weight(.medium)
    
    
    static let TrocaPagina = Font.custom(
        "SFCompactRounded-Medium",
        size: 16,
        relativeTo: .body
    )
        
    
}
    

```

---

###  Arquivo: `./Omi/Omi/Data/ReceitaRepositorioSwiftData.swift`

```swift
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
        guard let receita = try buscarReceitaEntity(id: id) else { return }

        // 1. Atualiza os campos escalares
        receita.titulo = titulo
        receita.categoria = categoria
        receita.descricao = descricao
        receita.imagem = imagem
        receita.tempoDePreparo = tempoDePreparo
        receita.porcoes = porcoes
        receita.dificuldade = dificuldade
        receita.dataAtualizacao = Date()

        // 2. Remove as relações antigas (o deleteRule .cascade nas próprias
        //    relações não se aplica aqui — estamos deletando os "filhos"
        //    individualmente, não a receita inteira, então precisa ser manual)
        for relacaoAntiga in receita.ingredientesDaReceita {
            contexto.delete(relacaoAntiga)
        }
        for passoAntigo in receita.passos {
            contexto.delete(passoAntigo)
        }

        // 3. Recria ingredientes a partir da lista nova vinda da tela
        for item in ingredientes {
            let ingrediente = try buscarOuCriarIngrediente(nome: item.nome)
            let relacao = IngredienteDaReceita(quantidade: String(item.quantidade), medida: item.medida)
            contexto.insert(relacao)
            relacao.receita = receita
            relacao.ingrediente = ingrediente
        }

        // 4. Recria passos a partir da lista nova vinda da tela
        for item in passos {
            let passo = PassoReceita(etapa: Int16(item.etapa), nome: item.nome, texto: item.texto, tempoEstimado: Int16(item.tempoEstimado))
            passo.receita = receita
            contexto.insert(passo)
        }

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
}

extension Notification.Name {
    static let repositorioAtualizado = Notification.Name("Omi.repositorioAtualizado")
}

```

---

###  Arquivo: `./Omi/Omi/Data/PreviewData.swift`

```swift
//
//  PreviewData.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation
import SwiftData

// Como aqui é sobre Preview e també importa o SwiftData, posso chamar extensions do que preciso criar para passar chamar no preview do que receber a view model
extension LivroReceitasViewModel {
    static var preview: LivroReceitasViewModel {
        LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: PersistenceSwiftData.container.mainContext))
    }
}

extension ReceitaRepositorioSwiftData {
    static var preview: ModelContext {
        PersistenceSwiftData.preview.mainContext
    }
}

extension CriarReceitaViewModel {
    static var preview: CriarReceitaViewModel {
        CriarReceitaViewModel(repo: ReceitaRepositorioSwiftData(context: PersistenceSwiftData.container.mainContext), modo: .criar)
    }
}

extension DetalhesReceitaViewModel {
    static var preview: DetalhesReceitaViewModel {
        DetalhesReceitaViewModel(
            receita: ReceitaModel(
                id: UUID(),
                titulo: "Bolo de Cenoura",
                categoria: .sobremesa,
                descricao: "O bolo de cenoura é uma receita clássica e amada por todos! Com sua massa fofinha e saborosa, esse bolo é perfeito para um lanche da tarde ou como sobremesa em qualquer ocasião.",
                imagem: nil,
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
                    PassoModel(id: UUID(), etapa: 1, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40),
                    PassoModel(id: UUID(), etapa: 2, nome: "Massa do Bolo", texto: "Bata as cenouras, os ovos e o óleo no liquidificador.", tempoEstimado: 40)
                    
                ]
            ),
            repo: ReceitaRepositorioSwiftData(context: PersistenceSwiftData.container.mainContext)
        )
    }
}

```

---

###  Arquivo: `./Omi/Omi/Data/ReceitaSwiftDataClasses.swift`

```swift
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

```

---

###  Arquivo: `./Omi/Omi/Data/ReceitaRepositorioProtocolo.swift`

```swift
//
//  ReceitasRepositorio.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import Foundation

// Contrato de acesso a dados, facilita a migração. Quando trocar para SwiftData, basta criar um ReceitaRepositorioSwiftData( ReceitaRepositorio)
protocol ReceitaRepositorio {
    // MARK: - Receita
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
    
    // MARK: - Passo
    func buscarPassos(receitaId: UUID) throws -> [PassoModel]
    
    func criarPasso(
        receitaId: UUID,
        etapa: Int16,
        nome: String,
        texto: String,
        tempoEstimado: Int16
    ) throws
    
    func atualizarPasso(
        id: UUID,
        novaEtapa: Int16,
        novoNome: String,
        novoTexto: String,
        novoTempoEstimado: Int16
    ) throws
    
    func deletarPasso(id: UUID) throws
    
    // MARK: - Ingredientes
    func buscarIngredientes() throws -> [IngredienteCadastradoModel]
    
    func deletarIngrediente(id: UUID) throws
    
    func atualizarIngredienteDaReceita(
        id: UUID,
        novaQuantidade: String,
        novaMedida: String
    ) throws
    
    func criarIngredienteAvulso(nome: String) throws -> IngredienteCadastradoModel
}

```

---

###  Arquivo: `./Omi/Omi/Data/PersistenceSwiftData.swift`

```swift
//
//  PersistenceSwiftData.swift
//  Omi
//
//  Created by Igor Carrasco on 25/08/26.
//

import SwiftData

enum PersistenceSwiftData {
    static let container: ModelContainer = {
        let schema = Schema([Receita.self, Ingrediente.self, IngredienteDaReceita.self, PassoReceita.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Erro ao criar ModelContainer: \(error)")
        }
    }()
    
    // Equivalente ao PersistenceController.preview
    static let preview: ModelContainer = {
        let schema = Schema([Receita.self, Ingrediente.self, IngredienteDaReceita.self, PassoReceita.self])
        
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        let contexto = container.mainContext
        for i in 1...5 {
            let receita = Receita(titulo: "Receita \(i)", categoria: "sobremesa", descricao: "Descrição \(i)", imagem: nil, tempoDePreparo: 20, porcoes: "4", dificuldade: nil)
            contexto.insert(receita)
        }
        try? contexto.save()
        return container
    } ()
}

```

---

