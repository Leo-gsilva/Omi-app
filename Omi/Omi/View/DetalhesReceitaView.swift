//    //
//    //  DetalhesReceitaView.swift
//    //  Omi
//    //
//    //  Created by Igor Carrasco on 19/08/26.
//    //
//
//    import SwiftUI
//    import CoreData
//
//struct DetalhesReceitaView: View {
//    @State var viewModel: DetalhesReceitaViewModel
//    
//    init(viewModel: DetalhesReceitaViewModel) {
//        self.viewModel = viewModel
//    }
//    
//    var body: some View {
//        ZStack{
//            
//            Color(.cordoFundo) // Use your custom color asset here
//            .ignoresSafeArea()
//            
//            VStack(alignment: .leading){
//                
//                ZStack {
//                    // 1. Added resizable and scaledToFill so the image fills the entire 308x188 box!
//                    Image(viewModel.receita.imagem ?? "Ovo0")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 308, height: 188) // Constrain the image size
//                        .clipped() // Cut off any extra image that spills out
//                    
//                    VStack {
//                        Spacer() // Pushes everything to the bottom
//                        
//                        HStack {
//                            // 2. REMOVED the left Spacer() that was here!
//                            
//                            HStack(spacing: 8){
//                                Image(systemName: "clock")
//                                    .font(FontesApp.Semibold)
//                                Text("\(viewModel.receita.tempoDePreparo) min")
//                                    .font(FontesApp.Semibold)
//                                    .foregroundStyle(.cordosTextos)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Color(.cordoFundo).opacity(0.9))
//                            .clipShape(Capsule())
//                            .shadow(radius: 4)
//                            
//                            HStack(spacing: 8){
//                                Image(systemName: "chart.pie")
//                                    .font(FontesApp.Semibold)
//                                Text("\(viewModel.receita.porcoes ?? "1") pessoas")
//                                    .font(FontesApp.Semibold)
//                                    .foregroundStyle(.cordosTextos)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Color(.cordoFundo).opacity(0.9))
//                            .clipShape(Capsule())
//                            .shadow(radius: 4)
//                            
//                            // 3. KEPT the right Spacer to push the badges to the left
//                            Spacer()
//                        }
//                        .padding(.leading, 16) // Adds breathing room from the left edge
//                        .padding(.bottom, 16)  // Adds breathing room from the bottom edge
//                    }
//                }
//                .frame(width: 308, height: 188)
//                .clipShape(RoundedRectangle(cornerRadius: 18))
//                
//                Text(viewModel.receita.titulo ?? "Titulo")
//                
//                    .font(FontesApp.titulo)
//                    .foregroundStyle(.cordosTextos)
//                    .padding(.horizontal)
//                    .background(.cordoFundoTexto)
//                    .clipShape(RoundedRectangle(cornerRadius: 11))
//                
//                Spacer()
//            }
//            
//        }
//        
//    }
//}
//
//    #Preview {
//        // 1. Grab the safe, fake "in-memory" context
//            let context = PersistenceController.preview.container.viewContext
//            let previewRepo = ReceitasRepo(context: context)
//            
//            // 2. Create a "Dummy" Recipe just for the canvas
//            let receitaFake = Receita(context: context)
//            receitaFake.id = UUID()
//            receitaFake.titulo = "Bolo de Cenoura"
//            receitaFake.imagem = "Etiqueta vermelha"
//            receitaFake.tempoDePreparo = 10
//            receitaFake.porcoes = "4"
//            
//            // 3. Initialize the ViewModel with our fake data
//            let previewViewModel = DetalhesReceitaViewModel(receita: receitaFake, repo: previewRepo)
//            
//            // 4. Inject the initialized ViewModel into the View
//            return DetalhesReceitaView(viewModel: previewViewModel)
//    }
