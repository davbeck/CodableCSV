import Foundation

extension ShadowDecoder {
    /// Source of all CSV rows.
    internal final class Source {
        /// The instance reading the CSV data.
        private let reader: CSVReader
        /// The records that have already been parsed and are ready to be fetched (`next`) or have been already fetched (`last`).
        private var records: (used: Record, next: Record)
        
        /// Designated initializer starting a CSV parsing process.
        ///
        /// Every time a new `fetchRecord` function is called a new line is parsed.
        /// - parameter data: The data blob containing the CSV information.
        /// - parameter encoding: String encoding used to transform the data blob into text.
        /// - parameter configuration: Generic CSV configuration to parse the data blob.
        /// - throws: `DecodingError` exclusively (with `CSVReader.Error` as *underlying error*).
        init(data: Data, encoding: String.Encoding, configuration: CSV.Configuration) throws {
            do {
                self.reader = try CSVReader(data: data, encoding: encoding, configuration: configuration)
            } catch let error {
                let context = DecodingError.Context(codingPath: [], debugDescription: "CSV reader/parser couldn't be initialized.", underlyingError: error)
                throw DecodingError.dataCorrupted(context)
            }
            
            self.records.used = .start
            self.records.next = Record(parsing: self.reader)
        }
        
        /// The header record with the field names.
        var header: [String]? {
            return self.reader.headers
        }
        
        // A Boolean value indicating whether there are no more elements left to be decoded in the container.
        var isAtEnd: Bool {
            guard case .end(_) = self.records.next else { return false }
            return true
        }
        
        /// The total number of records within the whole CSV file.
        ///
        /// Since CSV parsing is sequencial, until all records have been read, this property will return `nil`.
        var recordsCount: Int? {
            guard case .end(let index) = self.records.next else {
                return nil
            }
            return index
        }
        
        /// The index of the next record to be decoded.
        ///
        /// Incremented after every successful decode call.
        var nextRecordIndex: Int {
            return self.records.next.index
        }
        
        /// A new record fetched from the CSV binary.
        ///
        /// This function has the following responses:
        /// - It returns `[String]` if a successful parsing operation occurred.
        /// - It returns `nil` if there is no more CSV because the end of the file has been reached.
        /// - It throws a `DecodingError` if the CSV record was malformed.
        /// - parameter codingPath: CodingPath used if an error is encountered when parsing.
        /// - returns: An array of strings or `nil` if there isn't any more data to be fetched.
        /// - throws: `DecodingError` exclusively (with `CSVReader.Error` as *underlying error*).
        func fetchRecord(codingPath: @autoclosure ()->[CodingKey]) throws -> [String]? {
            self.records.used = self.records.next
            
            switch self.records.used {
            case .row(let result, _):
                self.records.next = Record(parsing: self.reader)
                return result
            case .end(_):
                return nil
            case .parsingError(let error, let index):
                let context = DecodingError.Context(codingPath: codingPath(), debugDescription: "The CSV parser encountered an error for row at index: \(index).", underlyingError: error)
                throw DecodingError.dataCorrupted(context)
            case .start:
                fatalError("A subsequent error can never be in the starting place.")
            }
        }
        
        /// Takes a peak on the next record.
        ///
        /// It performs the same operations as doing a *fetch*, but it doesn't actually move the data pointers. It basically lets you take a look in the *future*.
        /// - returns: The record to be given next with the `fetchRecord()` function.
        /// - throws: `DecodingError` exclusively (with `CSVReader.Error` as *underlying error*).
        func peakNextRecord(codingPath: @autoclosure ()->[CodingKey]) throws -> [String]? {
            switch self.records.next {
            case .row(let result, _):
                return result
            case .end(_):
                return nil
            case .parsingError(let error, let index):
                let context = DecodingError.Context(codingPath: codingPath(), debugDescription: "The CSV parser encountered an error for row at index: \(index).", underlyingError: error)
                throw DecodingError.dataCorrupted(context)
            case .start:
                fatalError("A subsequent error can never be in the starting place.")
            }
        }
        
        /// Parses the CSV file till right before the targeted index.
        ///
        /// Errors can be thrown when:
        /// - The targeted index has already been parsed.
        /// - The end of file has been reached without the index having been met.
        /// - returns: Boolean indicating whether the operation was successful (`true`) or the end of the file has been reached (`false`).
        /// - throws: `DecodingError`s exclusively.
        func moveBeforeRecord(index: Int, codingKey: CodingKey, codingPath: @autoclosure ()->[CodingKey]) throws -> Bool {
            guard index != self.nextRecordIndex else { return true }
            
            guard index > self.nextRecordIndex else {
                throw DecodingError.alreadyParsed(key: codingKey, codingPath: codingPath())
            }
            
            while let _ = try self.fetchRecord(codingPath: codingPath) {
                if self.nextRecordIndex == index { return true }
            }
            
            return false
        }
    }
}

extension ShadowDecoder.Source {
    /// Representation of a CSV record/row.
    fileprivate enum Record {
        /// There isn't any record already used/parsed.
        case start
        /// The record is represented by the given array of fields/strings and the index.
        case row([String], index: Int)
        /// There isn't any more record to be parsed; a.k.a. the end of the CSV file.
        case end(index: Int)
        /// An error occurred parsing the CSV data blob.
        case parsingError(CSVReader.Error, index: Int)
        
        /// Creates a new record by parsing the CSV input.
        /// - parameter reader: The data decoder/reader/parser.
        init(parsing reader: CSVReader) {
            let index = reader.rowIndex
            
            do {
                guard let next = try reader.parseRow() else {
                    self = .end(index: index)
                    return
                }
                self = .row(next, index: index)
            } catch let error as CSVReader.Error {
                self = .parsingError(error, index: index)
            } catch let error {
                fatalError("CSVReader should only throw CSVReader.Error types. Unbelievably, the following error was received:\n\(error)")
            }
        }
        
        var index: Int {
            switch self {
            case .row(_, let index): return index
            case .end(let index): return index
            case .parsingError(_, let index): return index
            case .start: return 0
            }
        }
    }
}