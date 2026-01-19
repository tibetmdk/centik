import Cocoa

// MARK: - System Media Key Sender
// Bu helper, macOS’e "media key" (play/pause, next, previous) event’i yollar.
// Böylece hangi uygulama çalıyorsa (Apple Music / Spotify / Safari vs) onu kontrol eder.
//
// Not: Bu yöntem MPRemoteCommandCenter gibi "dinleme" API’leri değil,
// doğrudan sistem event’i gönderme yaklaşımıdır.

private enum MediaKey: Int32 {
    case playPause = 16   // NX_KEYTYPE_PLAY
    case next      = 17   // NX_KEYTYPE_NEXT
    case previous  = 18   // NX_KEYTYPE_PREVIOUS
}

private func postMediaKey(_ key: MediaKey) {

    func makeEvent(keyDown: Bool) -> CGEvent? {
        let keyCode = key.rawValue
        let flags: Int32 = keyDown ? 0xA : 0xB
        let data1 = (keyCode << 16) | (flags << 8)

        let event = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: 0,
            context: nil,
            subtype: 8,           // NX_SUBTYPE_AUX_CONTROL_BUTTONS
            data1: Int(data1),
            data2: -1
        )

        return event?.cgEvent
    }

    // Key Down
    if let down = makeEvent(keyDown: true) {
        down.post(tap: .cghidEventTap)
    }

    // Key Up
    if let up = makeEvent(keyDown: false) {
        up.post(tap: .cghidEventTap)
    }
}

// MARK: - Main View

final class MusicToolView: NSView {

    // MARK: - UI Elemanları

    private let albumImageView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "One Kiss /w Shea")
    private let progressBar = NSProgressIndicator()

    private let previousButton = NSButton(title: "⏮", target: nil, action: nil)
    private let playPauseButton = NSButton(title: "▶", target: nil, action: nil)
    private let nextButton = NSButton(title: "⏭", target: nil, action: nil)

    // F7/F8/F9 için menü shortcut item’ları (AppKit bu şekilde shortcut yönetiyor)
    private var shortcutItems: [NSMenuItem] = []

    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setupView()
        setupLayout()
        setupActions()
        setupKeyboardShortcuts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Ayarları

    private func setupView() {

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        // --- ALBUM IMAGE ---
        albumImageView.image = NSImage(named: "album_art")
        albumImageView.imageScaling = .scaleAxesIndependently
        albumImageView.wantsLayer = true
        albumImageView.layer?.cornerRadius = 8
        albumImageView.layer?.masksToBounds = true

        // --- TITLE LABEL ---
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail

        // --- PROGRESS BAR ---
        // Şimdilik örnek; gerçek progress için Now Playing bilgisini okumamız lazım.
        progressBar.isIndeterminate = false
        progressBar.minValue = 0
        progressBar.maxValue = 100
        progressBar.doubleValue = 35
        progressBar.style = .bar

        // --- BUTTON STYLES ---
        previousButton.bezelStyle = .texturedRounded
        playPauseButton.bezelStyle = .texturedRounded
        nextButton.bezelStyle = .texturedRounded
    }

    // MARK: - Layout

    private func setupLayout() {

        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(albumImageView)
        addSubview(titleLabel)
        addSubview(progressBar)
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)

        NSLayoutConstraint.activate([

            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            albumImageView.widthAnchor.constraint(equalToConstant: 44),
            albumImageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: albumImageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            progressBar.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 6),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            playPauseButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 4),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -14),

            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 14),
        ])
    }

    // MARK: - Actions (Butonlar)

    private func setupActions() {
        playPauseButton.target = self
        playPauseButton.action = #selector(playPause)

        previousButton.target = self
        previousButton.action = #selector(previousTrack)

        nextButton.target = self
        nextButton.action = #selector(nextTrack)
    }

    // MARK: - Keyboard Shortcuts (F7 / F8 / F9)

    private func setupKeyboardShortcuts() {

        // F7 → Previous
        let f7 = NSMenuItem(
            title: "Previous",
            action: #selector(previousTrack),
            keyEquivalent: "\u{F706}" // F7
        )

        // F8 → Play/Pause
        let f8 = NSMenuItem(
            title: "PlayPause",
            action: #selector(playPause),
            keyEquivalent: "\u{F707}" // F8
        )

        // F9 → Next
        let f9 = NSMenuItem(
            title: "Next",
            action: #selector(nextTrack),
            keyEquivalent: "\u{F708}" // F9
        )

        // Modifier yok (Cmd/Option yok)
        [f7, f8, f9].forEach {
            $0.keyEquivalentModifierMask = []
            $0.target = self
            shortcutItems.append($0)
        }
    }

    // MARK: - Gerçek Sistem Medya Kontrolü

    @objc private func playPause() {
        // Sistem media key: Play/Pause
        postMediaKey(.playPause)
    }

    @objc private func previousTrack() {
        // Sistem media key: Previous
        postMediaKey(.previous)
    }

    @objc private func nextTrack() {
        // Sistem media key: Next
        postMediaKey(.next)
    }
}
