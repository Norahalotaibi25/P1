//
//  ContentView.swift
//  P1
//
//  Created by Norah Abdulkairm on 27/04/1447 AH.
//

import SwiftUI

public struct OnboardingView: View {
    @State private var goal = ""
    @State private var SelectedDuration: String = "Week"
    
    

    public var body: some View {
        
            
            VStack(spacing: 32) {
                
//                VStack(alignment: .leading, spacing: 32) {
                    
                    
                    
                    
                    
                    
                    
                    VStack(alignment: .leading,spacing: 40){
                        
                        
                        HStack{
                            getImage()
                        }.frame(maxWidth: .infinity)
                        
                        //v
                        VStack(alignment:.leading,spacing: 4){
                            Text("Hello World")
                                .font(.system(size: 34, weight: .bold, design: .default))
                            
                            Text("This app will help you learn everyday!")
                                .font(Font.system(size: 17, weight: .regular, design: .default))
                            
                        }//v
                        
                        
                    }
                    
                    VStack (alignment: .leading , spacing: 4){
                        Text("I want to learn ")
                            .font(Font.system(size:22, weight: .regular, design: .default))
                        TextField("swift", text: .constant(""))
                            .frame(width:393, height: 48)
                        
//                    }
                    
                        Text("I want to learn it in a")
                                                .font(.system(size: 22, weight: .regular, design: .default))
                                            
                    
                    
                    
                        HStack(spacing: 16){
                                            ForEach(["Week","Month","Year"], id: \.self){duration in Button(duration){
                                                SelectedDuration = duration
                                            }
                                            .frame(width: 97, height: 48)
                                            .background(SelectedDuration == duration ? Color.orange : Color.gray.opacity(0.1))
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                            .glassEffect(.clear.interactive())
                                            }
                                    }

                }//v
                Spacer()
                Button ("Start learning"){}
                                    .frame(width: 182, height: 48)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .glassEffect(.clear.interactive())
                }
            
            

            }//v
        }//body
    
   
        
    

#Preview {
    OnboardingView()
}

// Provide a concrete View to satisfy `some View`
private func getImage() -> some View {
    
    
    Image(systemName: "flame.fill")
        .font(.system(size: 43))
        .foregroundColor(Color(red: 255/255, green: 146/255, blue: 48/255))
        .frame(width: 109, height: 109)
        .background(Color.brownd)
        .clipShape(Circle())
    //    Circle()
    //        .strokeBoarder(
    //            LinearGradient(
    //    gradient: Gradient(colors: [
    //        Color.white.opacity(0.6)
    //        Color.orange.opacity(0.3)
    //        Color.black.opacity(0.2)
    //        ])
    //    ])
    //    )
        .background(
            Circle()
                .fill(Color.brown) // لون الخلفية للدائرة
            // **إضافة الحدود المضيئة هنا:**
                .overlay(
                    Circle() // نستخدم دائرة إضافية للحدود
                        .stroke(Color.orange, lineWidth: 0.2)
                        /*.opacity(0.01)*/) // لون وسمك الحدود (يمكنك تغييرهما)
            // **اللمعة/التوهج على الحدود نفسها:**
                .shadow(color: Color.white.opacity(0.5), radius: 0.05) // توهج أبيض ساطع وواسع
                .shadow(color: Color.yellow.opacity(0.9), radius: 0.01)
                .glassEffect(.clear.interactive())
        )}


