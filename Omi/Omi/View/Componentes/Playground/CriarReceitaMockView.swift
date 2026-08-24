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
