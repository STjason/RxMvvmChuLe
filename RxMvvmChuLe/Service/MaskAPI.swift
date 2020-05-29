//
// Created by chieh hsun on 2020-05-29.
// Copyright (c) 2020 chieh hsun. All rights reserved.
//

import Moya

public enum MaskAPI {
    case fetchMask
}

extension MaskAPI: TargetType {

    public var baseURL: URL {
        URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/")!
    }

    public var path: String {
        switch self {
        case .fetchMask:
            return "json/points.json"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchMask:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case .fetchMask:
            return .requestPlain
        }
    }

    public var headers: [String : String]? {
        nil
    }

    public var sampleData: Data {
        "".data(using: String.Encoding.utf8)!
    }
}
