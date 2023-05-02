//
//  Row.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import SwiftUI
import URLImage

///The basic building block our MoviesApp app which makes a row for us
struct Row: View {
    @Environment(\.colorScheme) var colorScheme
    private(set) var movie:MovieCoreDataModel
    var isLoadingView = false
    
    internal let inspection = Inspection<Self>()
    
    init(movie:MovieCoreDataModel, isLoadingView:Bool = false) {
        self.movie = movie
        self.isLoadingView = isLoadingView
    }
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                movieBackDropImg
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                    .frame(width: 80, height: 120)
                    .modifier(ClipShapeSafe(shape: RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0)))) //default clipShape crashes iOS 13, hence custom workaround with version check
                    .padding(.top, 22)
                   .padding([.leading,.trailing])
            }
            VStack(alignment:.leading) {
                Spacer()
                Text(movie.originalTitle ?? AppStrings.Stuffed.defaultMovieAuthor)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Text(movie.releaseDate ?? AppStrings.Stuffed.defaultMovie)
                    .lineLimit(1)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Spacer()
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
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
                        .frame(width:80, height:120)
                }
            }
        } else {
            Image(systemName: AppStrings.Stuffed.defaultMovieImgSysName) //set default person image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 120)
            
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(movie: MovieCoreDataModel.init(context: PersistenceManager.shared.container.viewContext))
        }
    }
}
struct Row_Dark_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(movie: MovieCoreDataModel.init(context: PersistenceManager.shared.container.viewContext))
        }
        .preferredColorScheme(.dark)
    }
}

//TODO: Complete AnimatingCellHeight implementation and move the correct file  ie ViewModifiers
///Animation Modifier to expand the cell animatingly
struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        withAnimation {
            content.frame(height: height)
        }
    }
}
