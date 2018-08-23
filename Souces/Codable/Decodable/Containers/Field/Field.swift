import Foundation

/// A decoding container holding a single field of a CSV record/row.
internal protocol FieldDecodingContainer: DecodingContainer {
    ///
    init(superDecoder decoder: ShadowDecoder, value: String, codingKey: CodingKey)
}

//extension ShadowDecoder {
//    /// Container holding a field value (within a CSV row).
//    internal final class Field: FieldDecodingContainer {
//        let codingKey: CSV.Key
//        private(set) var decoder: ShadowDecoder!
//        /// The field actual value.
//        private let value: String
//
//        init(superDecoder decoder: ShadowDecoder, value: String, codingKey: CodingKey) {
//            self.codingKey = codingKey
//            self.value = value
//            self.decoder = decoder.subDecoder(adding: self)
//        }
//    }
//}
//
//extension ShadowDecoder.Field: SingleValueDecodingContainer {
//    func decodeNil() -> Bool {
//        return self.value.decodeToNil()
//    }
//
//    func decode(_ type: Bool.Type) throws -> Bool {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: String.Type) throws -> String {
//        return self.value
//    }
//
//    func decode(_ type: Double.Type) throws -> Double {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//    
//    func decode(_ type: Float.Type) throws -> Float {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: Int.Type) throws -> Int {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: Int8.Type) throws -> Int8 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: Int16.Type) throws -> Int16 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: Int32.Type) throws -> Int32 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: Int64.Type) throws -> Int64 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: UInt.Type) throws -> UInt {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: UInt8.Type) throws -> UInt8 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: UInt16.Type) throws -> UInt16 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: UInt32.Type) throws -> UInt32 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode(_ type: UInt64.Type) throws -> UInt64 {
//        return try self.value.decode(to: type, codingPath: self.codingPath)
//    }
//
//    func decode<T:Decodable>(_ type: T.Type) throws -> T {
//        return try T(from: self.decoder)
//    }
//}