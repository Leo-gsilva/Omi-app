//
//  TabBar.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 19/08/26.
//

import SwiftUI

struct TabBar: View {
    var textoBotao: String = "Pesquisar"
    let action: () -> Void
    
    var body: some View {
        GeometryReader{ geo in
            HStack{
                HStack{
                    Button(action: action) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.secondary)
                        Text(textoBotao)
                            .font(FontesApp.corpo)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .padding(.trailing, geo.size.width * 0.40)
                .frame(width: geo.size.width * 0.70, height: 45)
                .background(Color.cordaTabBar)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20))
                
                .padding(.trailing, -10)
                
                ZStack{
                    Circle()
                        .frame(width: geo.size.width * 0.20, height: 50)
                        .foregroundStyle(Color.cordaTabBar)
                    
                    Image(systemName: "plus")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 30, weight: .bold))
                        
                }
                
            }
            
        }
    }
}
#Preview {
    TabBar(
        
        action: {}
    )
    
}

