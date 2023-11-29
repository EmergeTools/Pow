#if os(iOS)
import SwiftUI
import CoreHaptics
import UniformTypeIdentifiers
import AVFoundation

public extension AnyChangeEffect {
    /// Triggers sound effect as feedback whenever a value changes.
    ///
    /// - Parameter soundEffect: The sound effect to trigger.
    static func feedback(_ soundEffect: SoundEffect) -> AnyChangeEffect {
        .simulation { change in
            SoundEffectModifier(audio: soundEffect, impulseCount: change)
        }
    }
}

public struct SoundEffect: Hashable, Sendable {
    /// The audio session used to play sound effects or `nil` to get the default audio behavior.
    ///
    /// Provide an `AVAudioSession` instance if your app is already using an audio session and you want the audio behavior of the sound effects to match other audio in your app.
    ///
    /// - Note: Sound effects have a different audio behavior when running in a simulator. If you don't set an audio session, Pow activates the shared audio session when needed.
    ///         If you only want to change the audio behavior for the simulator you can check the target environment before setting the session.
    /// ```
    /// #if targetEnvironment(simulator)
    /// SoundEffect.audioSession = AVAudioSession.sharedInstance()
    /// #endif
    /// ```
    static var audioSession: AVAudioSession?

    var urls: [URL]

    var url: URL? {
        return urls.first
    }

    var volume: Double = 1.0

    /// Creates a sound effect.
    ///
    /// If more than one name is given the sound effect will rotate between playing one of those sounds.
    ///
    /// So for example `SoundEffect("Pop1", "Pop2", "Pop3")` will play a different pop sound every time.
    ///
    /// - Parameters:
    ///   - names: One or more names of the sound resource to lookup.
    ///   - type: The type of the sound resource to lookup. Defaults to `.audio`.
    ///   - bundle: The bundle to search for the sound resource. Defaults to the main `Bundle`.
    public init(_ names: String..., type: UTType = .audio, bundle: Bundle = .main) {
        let types: [UTType]
        if type == .audio {
            types = [type, .aiff, .wav, UTType(filenameExtension: "caf")!, .mpeg4Audio, UTType(filenameExtension: "m4a")!]
        } else {
            types = [type]
        }

        self.urls = []

        for type in types {
            let fileExtensions = type.tags[.filenameExtension] ?? []
            for fileExtension in fileExtensions {
                for name in names {
                    if let url = bundle.url(forResource: name, withExtension: fileExtension) {
                        self.urls.append(url)
                    }
                }
                if urls.count > 0 {
                    return
                }
            }
        }

        print("No sound resource named \(names.map({ "'\($0)'" }).formatted(.list(type: .and))) with type '\(type)' found in bundle \(bundle)")
    }

    /// Create a sound effect from the specified URL.
    ///
    /// - Parameter url: The URL of the sound to play.
    public init(url: URL) {
        self.urls = [url]
    }

    /// Sets the volume of this sound.
    ///
    /// - Parameter value: A value between 0.0 (silent) and 1.0 (maximum volume).
    public func volume(_ value: Double) -> Self {
        var copy = self
        copy.volume = value
        return copy
    }
}

private struct SoundEffectModifier: ViewModifier, Simulative {
    var impulseCount: Int = 0

    // TODO: Remove from protocol
    var initialVelocity: CGFloat = 0

    var audio: SoundEffect

    init(audio: SoundEffect, impulseCount: Int) {
        self.audio = audio
        self.impulseCount = impulseCount
    }

    let engine: AnySoundEffectPlayer = .shared

    func body(content: Content) -> some View {
        content
            .onChange(of: impulseCount) { _ in
                Task(priority: .userInitiated) {
                    try await engine.register(audio)
                    try await engine.play(audio)
                    try await engine.unregister(audio)
                }
            }
            .onAppear {
                Task {
                    try await engine.register(audio)
                }
            }
            .onChange(of: audio) { [oldValue = audio] newValue in
                guard oldValue != newValue else { return }

                Task {
                    try await engine.unregister(oldValue)
                    try await engine.register(newValue)
                }
            }
            .onDisappear {
                Task {
                    try await engine.unregister(audio)
                }
            }
    }
}

private protocol SoundEffectPlayer {
    func register(_ audio: SoundEffect) async throws
    func unregister(_ audio: SoundEffect) async throws
    func play(_ audio: SoundEffect) async throws
}

private actor AnySoundEffectPlayer: SoundEffectPlayer {
    static var shared = AnySoundEffectPlayer()

    let player: any SoundEffectPlayer

    init() {
        #if targetEnvironment(simulator)
        self.player = AVSoundEffectPlayer()
        #else
        if CHHapticEngine.capabilitiesForHardware().supportsAudio {
            self.player = HapticEngineSoundEffectPlayer()
        } else {
            self.player = EmptySoundEffectPlayer()
        }
        #endif
    }

    func register(_ audio: SoundEffect) async throws {
        try await player.register(audio)
    }

    func unregister(_ audio: SoundEffect) async throws {
        try await player.unregister(audio)
    }

    func play(_ audio: SoundEffect) async throws {
        try await player.play(audio)
    }
}

private actor EmptySoundEffectPlayer: SoundEffectPlayer {
    func register(_ audio: SoundEffect) async throws {

    }

    func unregister(_ audio: SoundEffect) async throws {

    }

    func play(_ audio: SoundEffect) async throws {

    }
}

private actor HapticEngineSoundEffectPlayer: SoundEffectPlayer {
    private var engine: CHHapticEngine?

    private struct SoundEffectReference {
        let resourceID: CHHapticAudioResourceID

        var count: Int = 1
    }

    private var registeredSounds: [URL: SoundEffectReference] = [:]

    private var didSetUp = false

    init() {

    }

    private func setUp() throws {
        if didSetUp { return }
        defer { didSetUp = true }

        if let audioSession = SoundEffect.audioSession {
            engine = try? CHHapticEngine(audioSession: audioSession)
        } else {
            engine = try? CHHapticEngine()
        }

        guard let engine else { return }

        if #available(iOS 16.0, *) {
            engine.playsAudioOnly = true
        }

        engine.isAutoShutdownEnabled = false

        engine.resetHandler = {
            try? engine.start()
        }
    }

    private func tearDown() async throws {
        guard let engine else { return }

        do {
            #if DEBUG
            print("Stopping engine")
            #endif

            try await engine.stop()
        } catch {
            throw error
        }
    }

    func register(_ audio: SoundEffect) throws {
        try setUp()

        guard let engine else { return }

        for url in audio.urls {
            if var newRegisteredSound = registeredSounds[url] {
                newRegisteredSound.count += 1
                registeredSounds[url] = newRegisteredSound
            } else {
                #if DEBUG
                print("Registering \(audio)")
                #endif
                let resourceID = try engine.registerAudioResource(url)

                let reference = SoundEffectReference(resourceID: resourceID)
                registeredSounds[url] = reference
            }
        }
    }

    func unregister(_ audio: SoundEffect) async throws {
        guard let engine else { return }

        for url in audio.urls {
            registeredSounds[url]?.count -= 1

            if registeredSounds[url]?.count == 0 {
                #if DEBUG
                print("Unregistering \(audio)")
                #endif

                if let resourceID = registeredSounds[url]?.resourceID {
                    try engine.unregisterAudioResource(resourceID)
                }

                registeredSounds[url] = nil
            }
        }

        if registeredSounds.isEmpty {
            try await tearDown()
        }
    }

    func play(_ audio: SoundEffect) async throws {
        guard let engine else { return }

        try await engine.start()

        // TODO: Avoid playing the same sound twice if there are more variations.
        guard let url = audio.urls.randomElement() else { return }

        guard let resourceID = registeredSounds[url]?.resourceID else { return }

        try await withCheckedThrowingContinuation { continuation in
            let event = CHHapticEvent(
                audioResourceID: resourceID,
                parameters: [.init(parameterID: .audioVolume, value: Float(audio.volume))],
                relativeTime: CHHapticTimeImmediate
            )

            do {
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                let player = try engine.makeAdvancedPlayer(with: pattern)

                player.completionHandler = { x in
                    continuation.resume()
                }

                try player.start(atTime: CHHapticTimeImmediate)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}


private actor AVSoundEffectPlayer: SoundEffectPlayer {
    private struct SoundEffectReference {
        let id: UUID

        var count: Int
    }

    private var registeredSounds: [SoundEffect: SoundEffectReference] = [:]

    private var shouldDeactivateAudioSession = true

    private var didSetUp = false

    init() {

    }

    private func setUp() throws {
        if didSetUp { return }
        defer { didSetUp = true }
        guard SoundEffect.audioSession == nil else { return }

        let audioSession = AVAudioSession.sharedInstance()
        #if targetEnvironment(simulator)
        try audioSession.setCategory(.playback, mode: .default)
        #else
        try audioSession.setCategory(.ambient, mode: .default)
        #endif
        try audioSession.setActive(true)

        shouldDeactivateAudioSession = true
    }

    private func tearDown() throws {
        #if DEBUG
        print("Stopping engine")
        #endif

        guard shouldDeactivateAudioSession else { return }

        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setActive(false)
    }

    func register(_ audio: SoundEffect) {
        try? setUp()

        if var updatedSound = registeredSounds[audio] {
            updatedSound.count += 1
            registeredSounds[audio] = updatedSound
        } else {
            #if DEBUG
            print("Registering \(audio)")
            #endif
            let id = UUID()
            let sound = SoundEffectReference(id: id, count: 1)
            registeredSounds[audio] = sound
        }
    }

    func unregister(_ audio: SoundEffect) {
        guard var registeredSound = registeredSounds[audio] else { return }

        registeredSound.count -= 1

        if registeredSound.count == 0 {
            #if DEBUG
            print("Unregistering \(audio)")
            #endif

            registeredSounds[audio] = nil
        } else {
            registeredSounds[audio] = registeredSound
        }

        if registeredSounds.count == 0 {
            try? tearDown()
        }
    }

    func play(_ audio: SoundEffect) async throws {
        // TODO: Avoid playing the same sound twice if there are more variations.
        guard let url = audio.urls.randomElement() else {
            return
        }

        let player = AVAudioPlayerWithCompletionHandler(url: url, volume: audio.volume)

        try await withCheckedThrowingContinuation { continuation in
            player.play { result in
                continuation.resume(with: result)
            }
        }
    }
}

private class AVAudioPlayerWithCompletionHandler: NSObject, AVAudioPlayerDelegate {
    let url: URL

    let volume: Double

    var completion: (Result<Void, Error>) -> Void

    var player: AVAudioPlayer?

    init(url: URL, volume: Double) {
        self.url = url
        self.volume = volume
        self.completion = { _ in }
        self.player = nil
    }

    func play(completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.delegate = self
            player.volume = Float(volume)
            player.play()
            self.player = player
        } catch {
            completion(.failure(error))
            tearDown()
        }
    }

    func stop() {
        player?.stop()
        tearDown()
    }

    func tearDown() {
        player = nil
        completion = { _ in }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            completion(.success(()))
        } else {
            completion(.failure(AVError(.unknown)))
        }
        tearDown()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error {
            completion(.failure(error))
        } else {
            completion(.failure(AVError(.unknown)))
        }
        tearDown()
    }
}
#endif
