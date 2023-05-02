//
//  ContentView.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import SwiftUI
import Shimmer
import CoreData

struct MoviesListView: View {
    @ObservedObject var viewModel: MoviesViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    
    internal let inspection = Inspection<Self>()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                if networkMonitor.isConnected {
                    MoviesAppInnerView(viewModel:viewModel)
                        .navigationBarTitle(Text("Movies"))
                        .modifier(Refreshable { //Our custom ViewModifier which does the iOS version check innately
                            viewModel.retryFetchMovies()
                        })
                } else {
                    ZStack {
                        backgroundForOfflineView
                        requestFailedRetryView
                    }
                }
            }
            .modifier(iOSVersionCheckModifier)
            .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
        }
    }
    
    @State var tap = false

    @ViewBuilder
    var requestFailedRetryView: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                LottieView(lottieFile: "request_failed_retry", autoLoop: .loop)
                ZStack {
                    Text("Retry")
                    .foregroundColor(.green)
                    .frame(width: geometry.size.width - 70, height: 40)
                    .overlay(//Better than cornerRadius, greater control
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.green, lineWidth: 1.25)
                            
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.retryFetchMovies()
                        tap.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            tap = false
                        }
                    }
                    .scaleEffect(tap ? 1.2 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6))
                }
               
            }
        }
    }
    
    @ViewBuilder
    var backgroundForOfflineView: some View {
        if #available(iOS 14.0, *) {
            Color.white.ignoresSafeArea()
        } else {
            Color.white
        }
    }
    
  ///We can uncomment and use the following modifier to display a popup suggesting user to
    ///use iOS 14 and above because of the known frame issue in iOS 13
    var iOSVersionCheckModifier: some ViewModifier {
        if #available(iOS 14, *) {
            return EmptyModifier()
        } else {
            return EmphasizeiOSUpgradeModifier()
        }
    }
}

struct MoviesAppInnerView: View {
    @ObservedObject var viewModel: MoviesViewModel
    
    var body: some View {
        if !viewModel.movies.isEmpty {
            List(viewModel.movies, id:\.id) { item in
                NavigationLink(destination: MovieDetailView(movie: item)) {
                    Row(movie: item, isLoadingView: viewModel.movies.isEmpty)
                }
            }
        } else {
            loadingView
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        List(emptyRows, id: \.id) { item in
            Row(movie: item, isLoadingView: viewModel.movies.isEmpty)
        }
    }
    
    var emptyRows: [MovieCoreDataModel] {
        var movies : [MovieCoreDataModel] = []
        for _ in 0..<10 {
            let movie = MovieCoreDataModel.init(with: UUID())
            movies.append(movie)
        }
        return movies
    }
}


struct MoviesAppView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListView(viewModel: MoviesViewModel(persistenceManager: .preview))
            .environmentObject(NetworkMonitor())
    }
}

struct MoviesAppView_Dark_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListView(viewModel: MoviesViewModel(persistenceManager: .preview))
            .preferredColorScheme(.dark)
            .environmentObject(NetworkMonitor())
    }
}
