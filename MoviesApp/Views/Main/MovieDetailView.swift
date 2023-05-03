//
//  MovieDetailView.swift
//  MoviesApp
//
//  Created by Saad Umar on 5/1/23.
//

import SwiftUI
import URLImage

struct MovieDetailView: View {
    let movie: MovieCoreDataModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                HStack {
                    movieBackDropImg
                        .frame(width: 200, height: 280)
                        .modifier(ClipShapeSafe(shape: RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0)))) //default clipShape crashes iOS 13, hence custom workaround with version check
                        .padding(.top, 8)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                }
                Spacer()
                VStack(alignment:.leading) {
                    Text(movie.originalTitle ?? AppStrings.Stuffed.defaultMovieAuthor)
                        .font(Font.title)
                        .fontWeight(.bold)
                    Text(movie.releaseDate ?? AppStrings.Stuffed.defaultMovie)
                        .lineLimit(1)
                        .padding([.top,.bottom],3)
                    Text(movie.overview ?? AppStrings.Stuffed.defaultMovie)
                }
                Spacer()
            }
            .padding([.leading,.trailing],10)
            .contentShape(Rectangle())
        }
    }
    
    var randomColor: Color {
        Color(red:.random(in: 0...1),green: .random(in: 0...1), blue: .random(in: 0...1))
    }
    
    @ViewBuilder
    var movieBackDropImg: some View {
        if let urlString = movie.backdropPath, !urlString.isEmpty {
            if let url = URL(string: urlString) {
                URLImage(url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 280)
                }
            }
        } else {
            Image(systemName: AppStrings.Stuffed.defaultMovieImgSysName) //set default person image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 280)
            
        }
    }
}


struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        MovieDetailView(movie: MovieCoreDataModel.init(context: MockPersistenceManager.shared.container.viewContext))
    }
}
struct MovieDetailView_Dark_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        MovieDetailView(movie: MovieCoreDataModel.init(context: MockPersistenceManager.shared.container.viewContext))
            .preferredColorScheme(.dark)
    }
}
