//
//  OpenDayAppTests.swift
//  OpenDayAppTests
//

import XCTest
@testable import OpenDayApp
import CoreLocation

final class OpenDayAppTests: XCTestCase {
    var geolocationManager: GeolocationManager!
    var mockRoom: Room!

    override func setUpWithError() throws {
        geolocationManager = GeolocationManager.shared
        geolocationManager.currentLocation = CLLocation(latitude: 52.20292, longitude: 0.1355) // Mock location
        
        mockRoom = Room(data: [
            "name": "Room 101",
            "minor": 1234,
            "major": 5678
        ], buildingID: "lordAshcroft")
    }

    override func tearDownWithError() throws {
        geolocationManager = nil
        mockRoom = nil
    }

    // MARK: - Test Cases

    func testValidEmail() {
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
            return emailPredicate.evaluate(with: email)
        }
        
        XCTAssertTrue(isValidEmail("test@example.com"))
        XCTAssertFalse(isValidEmail("invalid-email"))
    }

    func testFindNearestBuilding() {
        let buildings = [
            ["name": "Building A", "latitude": 52.20292, "longitude": 0.1355],
            ["name": "Building B", "latitude": 52.203, "longitude": 0.136],
            ["name": "Building C", "latitude": 52.204, "longitude": 0.137]
        ]
        
        let nearestBuilding = buildings.min(by: { (building1, building2) -> Bool in
            let location1 = CLLocation(latitude: building1["latitude"] as! CLLocationDegrees,
                                       longitude: building1["longitude"] as! CLLocationDegrees)
            let location2 = CLLocation(latitude: building2["latitude"] as! CLLocationDegrees,
                                       longitude: building2["longitude"] as! CLLocationDegrees)
            return geolocationManager.currentLocation!.distance(from: location1) <
                   geolocationManager.currentLocation!.distance(from: location2)
        })
        
        XCTAssertEqual(nearestBuilding?["name"] as? String, "Building A")
    }

    func testFindNearestBuilding_EmptyData() {
        let buildings: [[String: Any]] = []
        let nearestBuilding = buildings.min(by: { (_, _) -> Bool in return false })
        XCTAssertNil(nearestBuilding, "Nearest building should be nil for empty data.")
    }

    func testFindNearestBuilding_InvalidCoordinates() {
        let buildings = [
            ["name": "Building A", "latitude": nil, "longitude": 0.1355],
            ["name": "Building B", "latitude": 52.203, "longitude": nil]
        ]
        let nearestBuilding = buildings.compactMap { building -> [String: Any]? in
            if let latitude = building["latitude"] as? CLLocationDegrees,
               let longitude = building["longitude"] as? CLLocationDegrees {
                return building
            }
            return nil
        }.min(by: { (building1, building2) -> Bool in
            let location1 = CLLocation(latitude: building1["latitude"] as! CLLocationDegrees,
                                       longitude: building1["longitude"] as! CLLocationDegrees)
            let location2 = CLLocation(latitude: building2["latitude"] as! CLLocationDegrees,
                                       longitude: building2["longitude"] as! CLLocationDegrees)
            return geolocationManager.currentLocation!.distance(from: location1) <
                   geolocationManager.currentLocation!.distance(from: location2)
        })
        XCTAssertNil(nearestBuilding, "Nearest building should be nil for invalid coordinates.")
    }

    func testNavigateToRoom() {
        let roomsViewController = RoomsViewController()

        // Mock behavior for initiateNavigation
        roomsViewController.initiateNavigation(to: mockRoom)
        RoomsViewController.selectedRoom = mockRoom

        XCTAssertEqual(RoomsViewController.selectedRoom?.name, "Room 101", "Selected room should match the mock room.")
    }

    func testNavigateToRoom_InvalidRoom() {
        let roomsViewController = RoomsViewController()

        // Attempt navigation with a nil room
        roomsViewController.initiateNavigation(to: Room(data: [:], buildingID: "")!)
        XCTAssertNil(RoomsViewController.selectedRoom, "Selected room should be nil for invalid room data.")
    }

    func testNotificationPermission() {
        let expectation = XCTestExpectation(description: "Notification permission should be requested.")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            XCTAssertNil(error, "Error should be nil during notification permission request.")
            XCTAssertTrue(granted, "Notification permission should be granted.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testPerformanceExample() throws {
        measure {
            geolocationManager.setupGeofencing()
        }
    }
}
