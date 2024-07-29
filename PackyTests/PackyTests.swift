//
//  PackyTests.swift
//  PackyTests
//
//  Created by Mason Kim on 6/22/24.
//

import XCTest

final class PackyTests: XCTestCase {

    func test_tsid_기본_Int_타입에_대한_테스트() {
        struct TsidInt: Decodable {
            let tsidList: [Int]
        }

        struct TsidInt16: Decodable {
            let tsidList: [Int32]
        }

        struct TsidInt32: Decodable {
            let tsidList: [Int32]
        }

        struct TsidInt64: Decodable {
            let tsidList: [Int64]
        }

        // tsid_data 파일의 경로를 가져옵니다.
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "tsid_data", withExtension: "json") else {
            XCTFail("Missing file: tsid_data.json")
            return
        }

        // 파일에서 데이터를 읽어옵니다.
        guard let jsonData = try? Data(contentsOf: url) else {
            XCTFail("Unable to read data from tsid_data.json")
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Int 타입 테스트 (성공해야 함)
        XCTAssertNoThrow(try decoder.decode(TsidInt.self, from: jsonData))

        // Int16 타입 테스트 (실패해야 함)
        XCTAssertThrowsError(try decoder.decode(TsidInt16.self, from: jsonData))

        // Int32 타입 테스트 (실패해야 함)
        XCTAssertThrowsError(try decoder.decode(TsidInt32.self, from: jsonData))

        // Int64 타입 테스트 (성공해야 함)
        XCTAssertNoThrow(try decoder.decode(TsidInt64.self, from: jsonData))
    }

}
