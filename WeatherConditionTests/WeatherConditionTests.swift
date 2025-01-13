//
//  WeatherConditionTests.swift
//  WeatherConditionTests
//
//  Created by Robert Mutai on 10/01/2025.
//

import XCTest
@testable import WeatherCondition

final class WeatherConditionTests: XCTestCase {

    func testGetWeather() async {
        let viewModel = WeatherViewModel(apiService: MockAPIService())
       
        await viewModel.getWeather(latitude: -1.3033, longitude: 36.8264)
       
        XCTAssertEqual(viewModel.city, "Nairobi South")
        XCTAssertEqual(viewModel.conditions, "BROKEN CLOUDS")
        XCTAssertEqual(viewModel.currentTemperature, "27.05º")
        XCTAssertEqual(viewModel.maximumTemperature, "27.05º")
        XCTAssertEqual(viewModel.minimumTemperature, "27.05º")
        XCTAssertEqual(viewModel.weatherTheme, .cloudy)
        XCTAssertEqual(viewModel.forcastDetail.count, 5)
        XCTAssertEqual(viewModel.forcastDetail[0].day, "Tuesday")
        XCTAssertEqual(viewModel.forcastDetail[0].temperature, "20.62º")
        XCTAssertEqual(viewModel.forcastDetail[0].theme, .cloudy)
       
    }

}
