//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Temiloluwa on 24/05/2023.
//

import SwiftUI
import WalletUI

struct OnboardingView: View {

    var body: some View {

        NavigationView {

            VStack{

                Spacer()

                VStack(spacing: 25){

                    Image("BitcoinLogo")
                        .frame(width: 100, height: 100, alignment: .center)

                    Text("Bitcoin wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)

                    Text("A simple bitcoin wallet for your enjoyment.")
                        .textStyle(BitcoinBody1())
                        .opacity(0.4)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 15){

                    Button(action: {}, label: {

                        Text("Create a new wallet")
                            .foregroundColor(.white)
                            .textStyle(BitcoinBody1())
                    }).buttonStyle(BitcoinFilled())

                    Button(action: { }, label: {

                        Text("Restore existing wallet")
                            .foregroundColor(.orange)
                            .textStyle(BitcoinBody1())
                    }).buttonStyle(BitcoinPlain())

                }.padding(.top, 30)
                Spacer()

                VStack {

                    Text("Your wallet, your coins \n 100% open-source & open-design")
                        .textStyle(BitcoinBody4())
                    .multilineTextAlignment(.center)

                }
                .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))

            }
        }
    }
}
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
                .preferredColorScheme(.dark)
            OnboardingView()
                .preferredColorScheme(.light)
        }
    }
}

