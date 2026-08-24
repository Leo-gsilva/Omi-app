import SwiftUI

struct TelaInicial: View {
    
    @Bindable var viewModel: LivroReceitasViewModel
    @State private var pesquisa = ""
    
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
                    
                    // Livro
                    LivroInterativo(
                        viewModel: viewModel
                    )
                    
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
}

#Preview {
    TelaInicial(
        viewModel: LivroReceitasViewModel.preview
    )
}
