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
            try! rustCall { ffi_logins_42e6_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_logins_42e6_rustbuffer_free(self, $0) }
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
        _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0, from: range) }
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

    static func lift(_ buf: RustBuffer) throws -> Self {
        let reader = Reader(data: Data(rustBuffer: buf))
        let value = try Self.read(from: reader)
        if reader.hasRemaining() {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    func lower() -> RustBuffer {
        let writer = Writer()
        write(into: writer)
        return RustBuffer(bytes: writer.bytes)
    }
}

// Implement our protocols for the built-in types that we use.

extension Optional: ViaFfiUsingByteBuffer, ViaFfi, Serializable where Wrapped: Serializable {
    fileprivate static func read(from buf: Reader) throws -> Self {
        switch try buf.readInt() as Int8 {
        case 0: return nil
        case 1: return try Wrapped.read(from: buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }

    fileprivate func write(into buf: Writer) {
        guard let value = self else {
            buf.writeInt(Int8(0))
            return
        }
        buf.writeInt(Int8(1))
        value.write(into: buf)
    }
}

extension Array: ViaFfiUsingByteBuffer, ViaFfi, Serializable where Element: Serializable {
    fileprivate static func read(from buf: Reader) throws -> Self {
        let len: Int32 = try buf.readInt()
        var seq = [Element]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            seq.append(try Element.read(from: buf))
        }
        return seq
    }

    fileprivate func write(into buf: Writer) {
        let len = Int32(count)
        buf.writeInt(len)
        for item in self {
            item.write(into: buf)
        }
    }
}

extension Int64: Primitive, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> Int64 {
        return try lift(buf.readInt())
    }

    fileprivate func write(into buf: Writer) {
        buf.writeInt(lower())
    }
}

extension Bool: ViaFfi {
    fileprivate typealias FfiType = Int8

    fileprivate static func read(from buf: Reader) throws -> Bool {
        return try lift(buf.readInt())
    }

    fileprivate func write(into buf: Writer) {
        buf.writeInt(lower())
    }

    fileprivate static func lift(_ v: Int8) throws -> Bool {
        return v != 0
    }

    fileprivate func lower() -> Int8 {
        return self ? 1 : 0
    }
}

extension String: ViaFfi {
    fileprivate typealias FfiType = RustBuffer

    fileprivate static func lift(_ v: FfiType) throws -> Self {
        defer {
            try! rustCall { ffi_logins_42e6_rustbuffer_free(v, $0) }
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
                let bytes = ForeignBytes(bufferPointer: buf)
                return try! rustCall { ffi_logins_42e6_rustbuffer_from_bytes(bytes, $0) }
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

// Public interface members begin here.

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

public enum LoginsStorageError {
    // Simple error enums only carry a message
    case UnexpectedLoginsStorageError(message: String)

    // Simple error enums only carry a message
    case SyncAuthInvalid(message: String)

    // Simple error enums only carry a message
    case MismatchedLock(message: String)

    // Simple error enums only carry a message
    case NoSuchRecord(message: String)

    // Simple error enums only carry a message
    case InvalidRecord(message: String)

    // Simple error enums only carry a message
    case CryptoError(message: String)

    // Simple error enums only carry a message
    case InvalidKey(message: String)

    // Simple error enums only carry a message
    case RequestFailed(message: String)

    // Simple error enums only carry a message
    case Interrupted(message: String)
}

extension LoginsStorageError: ViaFfiUsingByteBuffer, ViaFfi {
    fileprivate static func read(from buf: Reader) throws -> LoginsStorageError {
        let variant: Int32 = try buf.readInt()
        switch variant {
        case 1: return .UnexpectedLoginsStorageError(
                message: try String.read(from: buf)
            )

        case 2: return .SyncAuthInvalid(
                message: try String.read(from: buf)
            )

        case 3: return .MismatchedLock(
                message: try String.read(from: buf)
            )

        case 4: return .NoSuchRecord(
                message: try String.read(from: buf)
            )

        case 5: return .InvalidRecord(
                message: try String.read(from: buf)
            )

        case 6: return .CryptoError(
                message: try String.read(from: buf)
            )

        case 7: return .InvalidKey(
                message: try String.read(from: buf)
            )

        case 8: return .RequestFailed(
                message: try String.read(from: buf)
            )

        case 9: return .Interrupted(
                message: try String.read(from: buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    fileprivate func write(into buf: Writer) {
        switch self {
        case let .UnexpectedLoginsStorageError(message):
            buf.writeInt(Int32(1))
            message.write(into: buf)
        case let .SyncAuthInvalid(message):
            buf.writeInt(Int32(2))
            message.write(into: buf)
        case let .MismatchedLock(message):
            buf.writeInt(Int32(3))
            message.write(into: buf)
        case let .NoSuchRecord(message):
            buf.writeInt(Int32(4))
            message.write(into: buf)
        case let .InvalidRecord(message):
            buf.writeInt(Int32(5))
            message.write(into: buf)
        case let .CryptoError(message):
            buf.writeInt(Int32(6))
            message.write(into: buf)
        case let .InvalidKey(message):
            buf.writeInt(Int32(7))
            message.write(into: buf)
        case let .RequestFailed(message):
            buf.writeInt(Int32(8))
            message.write(into: buf)
        case let .Interrupted(message):
            buf.writeInt(Int32(9))
            message.write(into: buf)
        }
    }
}

extension LoginsStorageError: Equatable, Hashable {}

extension LoginsStorageError: Error {}

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

public struct LoginFields {
    public var origin: String
    public var httpRealm: String?
    public var formActionOrigin: String?
    public var usernameField: String
    public var passwordField: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(origin: String, httpRealm: String?, formActionOrigin: String?, usernameField: String, passwordField: String) {
        self.origin = origin
        self.httpRealm = httpRealm
        self.formActionOrigin = formActionOrigin
        self.usernameField = usernameField
        self.passwordField = passwordField
    }
}

extension LoginFields: Equatable, Hashable {
    public static func == (lhs: LoginFields, rhs: LoginFields) -> Bool {
        if lhs.origin != rhs.origin {
            return false
        }
        if lhs.httpRealm != rhs.httpRealm {
            return false
        }
        if lhs.formActionOrigin != rhs.formActionOrigin {
            return false
        }
        if lhs.usernameField != rhs.usernameField {
            return false
        }
        if lhs.passwordField != rhs.passwordField {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(httpRealm)
        hasher.combine(formActionOrigin)
        hasher.combine(usernameField)
        hasher.combine(passwordField)
    }
}

private extension LoginFields {
    static func read(from buf: Reader) throws -> LoginFields {
        return try LoginFields(
            origin: String.read(from: buf),
            httpRealm: String?.read(from: buf),
            formActionOrigin: String?.read(from: buf),
            usernameField: String.read(from: buf),
            passwordField: String.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        origin.write(into: buf)
        httpRealm.write(into: buf)
        formActionOrigin.write(into: buf)
        usernameField.write(into: buf)
        passwordField.write(into: buf)
    }
}

extension LoginFields: ViaFfiUsingByteBuffer, ViaFfi {}

public struct SecureLoginFields {
    public var password: String
    public var username: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(password: String, username: String) {
        self.password = password
        self.username = username
    }
}

extension SecureLoginFields: Equatable, Hashable {
    public static func == (lhs: SecureLoginFields, rhs: SecureLoginFields) -> Bool {
        if lhs.password != rhs.password {
            return false
        }
        if lhs.username != rhs.username {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(password)
        hasher.combine(username)
    }
}

private extension SecureLoginFields {
    static func read(from buf: Reader) throws -> SecureLoginFields {
        return try SecureLoginFields(
            password: String.read(from: buf),
            username: String.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        password.write(into: buf)
        username.write(into: buf)
    }
}

extension SecureLoginFields: ViaFfiUsingByteBuffer, ViaFfi {}

public struct RecordFields {
    public var id: String
    public var timesUsed: Int64
    public var timeCreated: Int64
    public var timeLastUsed: Int64
    public var timePasswordChanged: Int64

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(id: String, timesUsed: Int64, timeCreated: Int64, timeLastUsed: Int64, timePasswordChanged: Int64) {
        self.id = id
        self.timesUsed = timesUsed
        self.timeCreated = timeCreated
        self.timeLastUsed = timeLastUsed
        self.timePasswordChanged = timePasswordChanged
    }
}

extension RecordFields: Equatable, Hashable {
    public static func == (lhs: RecordFields, rhs: RecordFields) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.timesUsed != rhs.timesUsed {
            return false
        }
        if lhs.timeCreated != rhs.timeCreated {
            return false
        }
        if lhs.timeLastUsed != rhs.timeLastUsed {
            return false
        }
        if lhs.timePasswordChanged != rhs.timePasswordChanged {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timesUsed)
        hasher.combine(timeCreated)
        hasher.combine(timeLastUsed)
        hasher.combine(timePasswordChanged)
    }
}

private extension RecordFields {
    static func read(from buf: Reader) throws -> RecordFields {
        return try RecordFields(
            id: String.read(from: buf),
            timesUsed: Int64.read(from: buf),
            timeCreated: Int64.read(from: buf),
            timeLastUsed: Int64.read(from: buf),
            timePasswordChanged: Int64.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        id.write(into: buf)
        timesUsed.write(into: buf)
        timeCreated.write(into: buf)
        timeLastUsed.write(into: buf)
        timePasswordChanged.write(into: buf)
    }
}

extension RecordFields: ViaFfiUsingByteBuffer, ViaFfi {}

public struct LoginEntry {
    public var fields: LoginFields
    public var secFields: SecureLoginFields

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(fields: LoginFields, secFields: SecureLoginFields) {
        self.fields = fields
        self.secFields = secFields
    }
}

extension LoginEntry: Equatable, Hashable {
    public static func == (lhs: LoginEntry, rhs: LoginEntry) -> Bool {
        if lhs.fields != rhs.fields {
            return false
        }
        if lhs.secFields != rhs.secFields {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fields)
        hasher.combine(secFields)
    }
}

private extension LoginEntry {
    static func read(from buf: Reader) throws -> LoginEntry {
        return try LoginEntry(
            fields: LoginFields.read(from: buf),
            secFields: SecureLoginFields.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        fields.write(into: buf)
        secFields.write(into: buf)
    }
}

extension LoginEntry: ViaFfiUsingByteBuffer, ViaFfi {}

public struct Login {
    public var record: RecordFields
    public var fields: LoginFields
    public var secFields: SecureLoginFields

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(record: RecordFields, fields: LoginFields, secFields: SecureLoginFields) {
        self.record = record
        self.fields = fields
        self.secFields = secFields
    }
}

extension Login: Equatable, Hashable {
    public static func == (lhs: Login, rhs: Login) -> Bool {
        if lhs.record != rhs.record {
            return false
        }
        if lhs.fields != rhs.fields {
            return false
        }
        if lhs.secFields != rhs.secFields {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(record)
        hasher.combine(fields)
        hasher.combine(secFields)
    }
}

private extension Login {
    static func read(from buf: Reader) throws -> Login {
        return try Login(
            record: RecordFields.read(from: buf),
            fields: LoginFields.read(from: buf),
            secFields: SecureLoginFields.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        record.write(into: buf)
        fields.write(into: buf)
        secFields.write(into: buf)
    }
}

extension Login: ViaFfiUsingByteBuffer, ViaFfi {}

public struct EncryptedLogin {
    public var record: RecordFields
    public var fields: LoginFields
    public var secFields: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(record: RecordFields, fields: LoginFields, secFields: String) {
        self.record = record
        self.fields = fields
        self.secFields = secFields
    }
}

extension EncryptedLogin: Equatable, Hashable {
    public static func == (lhs: EncryptedLogin, rhs: EncryptedLogin) -> Bool {
        if lhs.record != rhs.record {
            return false
        }
        if lhs.fields != rhs.fields {
            return false
        }
        if lhs.secFields != rhs.secFields {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(record)
        hasher.combine(fields)
        hasher.combine(secFields)
    }
}

private extension EncryptedLogin {
    static func read(from buf: Reader) throws -> EncryptedLogin {
        return try EncryptedLogin(
            record: RecordFields.read(from: buf),
            fields: LoginFields.read(from: buf),
            secFields: String.read(from: buf)
        )
    }

    func write(into buf: Writer) {
        record.write(into: buf)
        fields.write(into: buf)
        secFields.write(into: buf)
    }
}

extension EncryptedLogin: ViaFfiUsingByteBuffer, ViaFfi {}

public func createKey() throws -> String {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_create_key($0)
        }
    return try String.lift(_retval)
}

public func decryptLogin(login: EncryptedLogin, encryptionKey: String) throws -> Login {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_decrypt_login(login.lower(), encryptionKey.lower(), $0)
        }
    return try Login.lift(_retval)
}

public func encryptLogin(login: Login, encryptionKey: String) throws -> EncryptedLogin {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_encrypt_login(login.lower(), encryptionKey.lower(), $0)
        }
    return try EncryptedLogin.lift(_retval)
}

public func decryptFields(secFields: String, encryptionKey: String) throws -> SecureLoginFields {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_decrypt_fields(secFields.lower(), encryptionKey.lower(), $0)
        }
    return try SecureLoginFields.lift(_retval)
}

public func encryptFields(secFields: SecureLoginFields, encryptionKey: String) throws -> String {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_encrypt_fields(secFields.lower(), encryptionKey.lower(), $0)
        }
    return try String.lift(_retval)
}

public func createCanary(text: String, encryptionKey: String) throws -> String {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_create_canary(text.lower(), encryptionKey.lower(), $0)
        }
    return try String.lift(_retval)
}

public func checkCanary(canary: String, text: String, encryptionKey: String) throws -> Bool {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_check_canary(canary.lower(), text.lower(), encryptionKey.lower(), $0)
        }
    return try Bool.lift(_retval)
}

public func migrateLogins(path: String, newEncryptionKey: String, sqlcipherPath: String, sqlcipherKey: String, salt: String?) throws -> String {
    let _retval = try

        rustCallWithError(LoginsStorageError.self) {
            logins_42e6_migrate_logins(path.lower(), newEncryptionKey.lower(), sqlcipherPath.lower(), sqlcipherKey.lower(), salt.lower(), $0)
        }
    return try String.lift(_retval)
}

public protocol LoginStoreProtocol {
    func add(login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin
    func update(id: String, login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin
    func addOrUpdate(login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin
    func delete(id: String) throws -> Bool
    func wipe() throws
    func wipeLocal() throws
    func reset() throws
    func touch(id: String) throws
    func list() throws -> [EncryptedLogin]
    func getByBaseDomain(baseDomain: String) throws -> [EncryptedLogin]
    func findLoginToUpdate(look: LoginEntry, encryptionKey: String) throws -> Login?
    func get(id: String) throws -> EncryptedLogin?
    func importMultiple(login: [Login], encryptionKey: String) throws -> String
    func registerWithSyncManager()
    func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localEncryptionKey: String) throws -> String
}

public class LoginStore: LoginStoreProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `ViaFfi` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    public convenience init(path: String) throws {
        self.init(unsafeFromRawPointer: try

            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_new(path.lower(), $0)
            })
    }

    deinit {
        try! rustCall { ffi_logins_42e6_LoginStore_object_free(pointer, $0) }
    }

    public func add(login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_add(self.pointer, login.lower(), encryptionKey.lower(), $0)
            }
        return try EncryptedLogin.lift(_retval)
    }

    public func update(id: String, login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_update(self.pointer, id.lower(), login.lower(), encryptionKey.lower(), $0)
            }
        return try EncryptedLogin.lift(_retval)
    }

    public func addOrUpdate(login: LoginEntry, encryptionKey: String) throws -> EncryptedLogin {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_add_or_update(self.pointer, login.lower(), encryptionKey.lower(), $0)
            }
        return try EncryptedLogin.lift(_retval)
    }

    public func delete(id: String) throws -> Bool {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_delete(self.pointer, id.lower(), $0)
            }
        return try Bool.lift(_retval)
    }

    public func wipe() throws {
        try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_wipe(self.pointer, $0)
            }
    }

    public func wipeLocal() throws {
        try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_wipe_local(self.pointer, $0)
            }
    }

    public func reset() throws {
        try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_reset(self.pointer, $0)
            }
    }

    public func touch(id: String) throws {
        try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_touch(self.pointer, id.lower(), $0)
            }
    }

    public func list() throws -> [EncryptedLogin] {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_list(self.pointer, $0)
            }
        return try [EncryptedLogin].lift(_retval)
    }

    public func getByBaseDomain(baseDomain: String) throws -> [EncryptedLogin] {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_get_by_base_domain(self.pointer, baseDomain.lower(), $0)
            }
        return try [EncryptedLogin].lift(_retval)
    }

    public func findLoginToUpdate(look: LoginEntry, encryptionKey: String) throws -> Login? {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_find_login_to_update(self.pointer, look.lower(), encryptionKey.lower(), $0)
            }
        return try Login?.lift(_retval)
    }

    public func get(id: String) throws -> EncryptedLogin? {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_get(self.pointer, id.lower(), $0)
            }
        return try EncryptedLogin?.lift(_retval)
    }

    public func importMultiple(login: [Login], encryptionKey: String) throws -> String {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_import_multiple(self.pointer, login.lower(), encryptionKey.lower(), $0)
            }
        return try String.lift(_retval)
    }

    public func registerWithSyncManager() {
        try!
            rustCall {
                logins_42e6_LoginStore_register_with_sync_manager(self.pointer, $0)
            }
    }

    public func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localEncryptionKey: String) throws -> String {
        let _retval = try
            rustCallWithError(LoginsStorageError.self) {
                logins_42e6_LoginStore_sync(self.pointer, keyId.lower(), accessToken.lower(), syncKey.lower(), tokenserverUrl.lower(), localEncryptionKey.lower(), $0)
            }
        return try String.lift(_retval)
    }
}

private extension LoginStore {
    typealias FfiType = UnsafeMutableRawPointer

    static func read(from buf: Reader) throws -> Self {
        let v: UInt64 = try buf.readInt()
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    func write(into buf: Writer) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        buf.writeInt(UInt64(bitPattern: Int64(Int(bitPattern: lower()))))
    }

    static func lift(_ pointer: UnsafeMutableRawPointer) throws -> Self {
        return Self(unsafeFromRawPointer: pointer)
    }

    func lower() -> UnsafeMutableRawPointer {
        return pointer
    }
}

// Ideally this would be `fileprivate`, but Swift says:
// """
// 'private' modifier cannot be used with extensions that declare protocol conformances
// """
extension LoginStore: ViaFfi, Serializable {}
