import SwiftUI

struct TelaInicial: View {
    @Environment(AppRouter.self) private var router // necessária para navegação
    @State var viewModel: LivroReceitasViewModel
//    @Bindable var viewModelDetalhes: DetalhesReceitaViewModel
    @State private var pesquisa = ""
    
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
                    
//                    Text("Receitas")
//                        .font(FontesApp.titulo)
//                        .padding(.trailing, geo.size.width * 0.45)
//                        .padding(geo.size.width * 0.04)
                    
                    // Livro
                    LivroInterativo(
                        viewModel: viewModel
                    )
                    
//                    DetalhesReceitaView(viewModel: viewModelDetalhes)
                    
                    // Botões de trocar página
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
                    // Colocar o router e passar pra ele a view
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
