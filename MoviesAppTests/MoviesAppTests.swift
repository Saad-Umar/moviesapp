//
//  MoviesAppTests.swift
//  MoviesAppTests
//
//  Created by Saad Umar on 4/30/23.
//

import XCTest
@testable import MoviesApp
import SwiftUI
import ViewInspector
import Network

final class MoviesAppTests: XCTestCase {
    
    //MARK: Baseline
    ///To establish ViewInspector is working fine
    func testViewInspectorBaseline() throws {
        let expected = "Movies"
        let sut = Text(expected)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, expected)
    }
    
    //MARK: View tests
    ///Testing row with empty/default fields
    func testRowDefaultText() throws {
        
        let movie = MovieCoreDataModel.init(context: MockPersistenceManager().container.viewContext)
        movie.originalTitle = AppStrings.Stuffed.defaultMovieAuthor
        
        let view = Row(movie: movie)
        
        let inspectedMovieImage = try view
            .inspect()
            .hStack()
            .hStack(0)
            .image(0)
            .actualImage()
        let expectedMovieImage = Image(systemName: AppStrings.Stuffed.defaultMovieImgSysName)
            .resizable()
        XCTAssertEqual(expectedMovieImage, inspectedMovieImage)
        let inspectedMovieAuthor = try view
            .inspect()
            .find(text:AppStrings.Stuffed.defaultMovieAuthor)
            .string()
        XCTAssertEqual(AppStrings.Stuffed.defaultMovieAuthor, inspectedMovieAuthor)
        
    }
    
    ///Testing that if there is no data yet, shimmer is visible
    @MainActor func testIsShimmeringWorkingIfNoData() throws {
        let viewModel = MoviesViewModel()
        let view = MoviesListView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        let sut = try view.inspect().find(MoviesAppInnerView.self).actualView()
        if (sut.viewModel.movies.isEmpty) {
            XCTAssertTrue(try sut.loadingView.inspect().list().find(Row.self).actualView().isLoadingView)
        }
        
    }
    
    ///Testing the shimmer is no more visible if there is data, asserting isLoadingView false
    @MainActor func testIsShimmeringIsHiddenIfData() throws {
        let viewModel = MoviesViewModel()
        let view = MoviesListView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        let sut = try view.inspect().find(MoviesAppInnerView.self).actualView()

        if (!sut.viewModel.movies.isEmpty) {
            XCTAssertFalse(try sut.loadingView.inspect().list().find(Row.self).actualView().isLoadingView)
        }
        
    }

    //MARK: Network tests
    ///To test default animation happens when network fails due to bad/no  internet
    func testNetworkFailureViewReaction() throws {
        let networkMonitor = NetworkMonitor()
        let viewModel = MoviesViewModel()
        let view = MoviesListView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        //will not be able to find offline animation (GIFView) if it is not up for some reason
        if !networkMonitor.isConnected {
            _ = try view.inspect().find(LottieView.self).actualView()
        } else {
            _ = try view.inspect().find(MoviesAppInnerView.self).actualView()
        }
    }
    
    //MARK: View Model Tests
    ///Testing after loading of movies works, asserting that there are one or more items to display
    func testLoadingMovies() async throws {
        let viewModel = MoviesViewModel(persistenceManager: MockPersistenceManager.preview)
        let expectation = expectation(description: "Getting movies from network call")
        
        await viewModel.fetchAllMovies()
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        Task { @MainActor in
            XCTAssertFalse(viewModel.movies.isEmpty)
        }
    }
    
}
