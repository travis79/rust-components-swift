// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(MozillaRustComponents)
    import MozillaRustComponents
#endif

private extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_crashtest_5d0e_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_crashtest_5d0e_rustbuffer_free(self, $0) }
    }
}

private extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a libray of its own.

private extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// A helper class to read values out of a byte buffer.
private class Reader {
    let data: Data
    var offset: Data.Index

    init(data: Data) {
        self.data = data
        offset = 0
    }

    // Reads an integer at the current offset, in big-endian order, and advances
    // the offset on success. Throws if reading the integer would move the
    // offset past the end of the buffer.
    func readInt<T: FixedWidthInteger>() throws -> T {
        let range = offset ..< offset + MemoryLayout<T>.size
        guard data.count >= range.upperBound else {
            throw UniffiInternalError.bufferOverflow
        }
        if T.self == UInt8.self {
            let value = data[offset]
            offset += 1
            return value as! T
        }
        var value: T = 0
        let _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0, from: range) }
        offset = range.upperBound
        return value.bigEndian
    }

    // Reads an arbitrary number of bytes, to be used to read
    // raw bytes, this is useful when lifting strings
    func readBytes(count: Int) throws -> [UInt8] {
        let range = offset ..< (offset + count)
        guard data.count >= range.upperBound else {
            throw UniffiInternalError.bufferOverflow
        }
        var value = [UInt8](repeating: 0, count: count)
        value.withUnsafeMutableBufferPointer { buffer in
            data.copyBytes(to: buffer, from: range)
        }
        offset = range.upperBound
        return value
    }

    // Reads a float at the current offset.
    @inlinable
    func readFloat() throws -> Float {
        return Float(bitPattern: try readInt())
    }

    // Reads a float at the current offset.
    @inlinable
    func readDouble() throws -> Double {
        return Double(bitPattern: try readInt())
    }

    // Indicates if the offset has reached the end of the buffer.
    @inlinable
    func hasRemaining() -> Bool {
        return offset < data.count
    }
}

// A helper class to write values into a byte buffer.
private class Writer {
    var bytes: [UInt8]
    var offset: Array<UInt8>.Index

    init() {
        bytes = []
        offset = 0
    }

    func writeBytes<S>(_ byteArr: S) where S: Sequence, S.Element == UInt8 {
        bytes.append(contentsOf: byteArr)
    }

    // Writes an integer in big-endian order.
    //
    // Warning: make sure what you are trying to write
    // is in the correct type!
    func writeInt<T: FixedWidthInteger>(_ value: T) {
        var value = value.bigEndian
        withUnsafeBytes(of: &value) { bytes.append(contentsOf: $0) }
    }

    @inlinable
    func writeFloat(_ value: Float) {
        writeInt(value.bitPattern)
    }

    @inlinable
    func writeDouble(_ value: Double) {
        writeInt(value.bitPattern)
    }
}

// Types conforming to `Serializable` can be read and written in a bytebuffer.
private protocol Serializable {
    func write(into: Writer)
    static func read(from: Reader) throws -> Self
}

// Types confirming to `ViaFfi` can be transferred back-and-for over the FFI.
// This is analogous to the Rust trait of the same name.
private protocol ViaFfi: Serializable {
    associatedtype FfiType
    static func lift(_ v: FfiType) throws -> Self
    func lower() -> FfiType
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
private protocol Primitive {}

private extension Primitive {
    typealias FfiType = Self

    static func lift(_ v: Self) throws -> Self {
        return v
    }

    func lower() -> Self {
        return self
    }
}

// Types conforming to `ViaFfiUsingByteBuffer` lift and lower into a bytebuffer.
// Use this for complex types where it's hard to write a custom lift/lower.
private protocol ViaFfiUsingByteBuffer: Serializable {}

private extension ViaFfiUsingByteBuffer {
    typealias FfiType = RustBuffer

    static func lift(_ buf: FfiType) throws -> Self {
        let reader = Reader(data: Data(rustBuffer: buf))
        let value = try Self.read(from: reader)
        if reader.hasRemaining() {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    func lower() -> FfiType {
        let writer = Writer()
        write(into: writer)
        return RustBuffer(bytes: writer.bytes)
    }
}

// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
private enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

private let CALL_SUCCESS: Int8 = 0
private let CALL_ERROR: Int8 = 1
private let CALL_PANIC: Int8 = 2

private extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: {
        $0.deallocate()
        return UniffiInternalError.unexpectedRustCallError
    })
}

private func rustCallWithError<T, E: ViaFfiUsingByteBuffer & Error>(_: E.Type, _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: { try E.lift($0) })
}

private func makeRustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T, errorHandler: (RustBuffer) throws -> Error) throws -> T {
    var callStatus = RustCallStatus()
    let returnedVal = callback(&callStatus)
    switch callStatus.code {
    case CALL_SUCCESS:
        return returnedVal

    case CALL_ERROR:
        throw try errorHandler(callStatus.errorBuf)

    case CALL_PANIC:
        // When the rust code sees a panic, it tries to construct a RustBuffer
        // with the message.  But if that code panics, then it just sends back
        // an empty buffer.
        if callStatus.errorBuf.len > 0 {
            throw UniffiInternalError.rustPanic(try String.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

// Protocols for converters we'll implement in templates

private protocol FfiConverter {
    associatedtype SwiftType
    associatedtype FfiType

    static func lift(_ ffiValue: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType

    static func read(from: Reader) throws -> SwiftType
    static func write(_ value: SwiftType, into: Writer)
}

private protocol FfiConverterUsingByteBuffer: FfiConverter where FfiType == RustBuffer {
    // Empty, because we want to declare some helper methods in the extension below.
}

extension FfiConverterUsingByteBuffer {
    static func lower(_ value: SwiftType) -> FfiType {
        let writer = Writer()
        Self.write(value, into: writer)
        return RustBuffer(bytes: writer.bytes)
    }

    static func lift(_ buf: FfiType) throws -> SwiftType {
        let reader = Reader(data: Data(rustBuffer: buf))
        let value = try Self.read(from: reader)
        if reader.hasRemaining() {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }
}

// Helpers for structural types. Note that because of canonical_names, it /should/ be impossible
// to make another `FfiConverterSequence` etc just using the UDL.
private enum FfiConverterSequence {
    static func write<T>(_ value: [T], into buf: Writer, writeItem: (T, Writer) -> Void) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for item in value {
            writeItem(item, buf)
        }
    }

    static func read<T>(from buf: Reader, readItem: (Reader) throws -> T) throws -> [T] {
        let len: Int32 = try buf.readInt()
        var seq = [T]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try readItem(buf))
        }
        return seq
    }
}

private enum FfiConverterOptional {
    static func write<T>(_ value: T?, into buf: Writer, writeItem: (T, Writer) -> Void) {
        guard let value = value else {
            buf.writeInt(Int8(0))
            return
        }
        buf.writeInt(Int8(1))
        writeItem(value, buf)
    }

    static func read<T>(from buf: Reader, readItem: (Reader) throws -> T) throws -> T? {
        switch try buf.readInt() as Int8 {
        case 0: return nil
        case 1: return try readItem(buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

private enum FfiConverterDictionary {
    static func write<T>(_ value: [String: T], into buf: Writer, writeItem: (String, T, Writer) -> Void) {
        let len = Int32(value.count)
        buf.writeInt(len)
        for (key, value) in value {
            writeItem(key, value, buf)
        }
    }

    static func read<T>(from buf: Reader, readItem: (Reader) throws -> (String, T)) throws -> [String: T] {
        let len: Int32 = try buf.readInt()
        var dict = [String: T]()
        dict.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            let (key, value) = try readItem(buf)
            dict[key] = value
        }
        return dict
    }
}

// Public interface members begin here.

public func triggerRustAbort() {
    try!

        rustCall {
            crashtest_5d0e_trigger_rust_abort($0)
        }
}

public func triggerRustPanic() {
    try!

        rustCall {
            crashtest_5d0e_trigger_rust_panic($0)
        }
}

public func triggerRustError() throws {
    try

        rustCallWithError(CrashTestError.self) {
            crashtest_5d0e_trigger_rust_error($0)
        }
}

public enum CrashTestError {
    // Simple error enums only carry a message
    case ErrorFromTheRustCode(message: String)
}

extension CrashTestError: ViaFfiUsingByteBuffer, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> CrashTestError {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .ErrorFromTheRustCode(
                message: try String.read(from: buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    fileprivate func write(into buf: Writer) {
        switch self {
        case let .ErrorFromTheRustCode(message):
            buf.writeInt(Int32(1))
            message.write(into: buf)
        }
    }
}

extension CrashTestError: Equatable, Hashable {}

extension CrashTestError: Error {}
extension String: ViaFfi {
    fileprivate typealias FfiType = RustBuffer

    fileprivate static func lift(_ v: FfiType) throws -> Self {
        defer {
            v.deallocate()
        }
        if v.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: v.data!, count: Int(v.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    fileprivate func lower() -> FfiType {
        return utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    fileprivate static func read(from buf: Reader) throws -> Self {
        let len: Int32 = try buf.readInt()
        return String(bytes: try buf.readBytes(count: Int(len)), encoding: String.Encoding.utf8)!
    }

    fileprivate func write(into buf: Writer) {
        let len = Int32(utf8.count)
        buf.writeInt(len)
        buf.writeBytes(utf8)
    }
}

// Helper code for CrashTestError error is found in ErrorTemplate.swift

/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum CrashtestLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {
        // No initialization code needed
    }
}
