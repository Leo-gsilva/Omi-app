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
                    ).contextMenu {
                        if viewModel.livroAberto, let receitaParaExcluir = viewModel.receitaAtual {
                            Button(role: .destructive) {
                                viewModel.excluirReceita(receitaParaExcluir)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    }
                    
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
