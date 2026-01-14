import Cocoa
// Cocoa = macOS AppKit dünyasının ana framework’ü

final class MusicToolView: NSView {

    // MARK: - UI Elemanları

    private let albumImageView = NSImageView()
    // Albüm kapağını gösterecek image view

    private let titleLabel = NSTextField(labelWithString: "One Kiss /w Shea")
    // Şarkı adı label’ı (editable değil)

    private let progressBar = NSProgressIndicator()
    // Müzik ilerleme çubuğu

    private let previousButton = NSButton(title: "⏮", target: nil, action: nil)
    private let playPauseButton = NSButton(title: "▶", target: nil, action: nil)
    private let nextButton = NSButton(title: "⏭", target: nil, action: nil)

    private var isPlaying = false
    // Şu an müzik çalıyor mu?

    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setupView()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Ayarları

    private func setupView() {

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        // Arka planı şeffaf (blur parent’tan geliyor)

        // --- ALBUM IMAGE ---

        albumImageView.image = NSImage(named: "album_art")
        // Assets.xcassets içindeki albüm görseli

        albumImageView.imageScaling = .scaleAxesIndependently
        // Görsel alanı doldursun, oranı bozmasın

        albumImageView.wantsLayer = true
        albumImageView.layer?.cornerRadius = 8
        albumImageView.layer?.masksToBounds = true
        // Yuvarlatılmış köşeler

        // --- TITLE LABEL ---

        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail

        // --- PROGRESS BAR ---

        progressBar.isIndeterminate = false
        // Determinate → yüzde bazlı çalışır

        progressBar.minValue = 0
        progressBar.maxValue = 100
        progressBar.doubleValue = 35
        // Şimdilik örnek bir değer (%35)

        progressBar.controlTint = .defaultControlTint
        progressBar.style = .bar
        // Düz, sade progress bar

        // --- BUTTON STYLES ---

        previousButton.bezelStyle = .texturedRounded
        playPauseButton.bezelStyle = .texturedRounded
        nextButton.bezelStyle = .texturedRounded
    }

    // MARK: - Layout (Auto Layout)

    private func setupLayout() {

        // Auto Layout kullanacağımız için frame tabanlı yerleşimi kapatıyoruz
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        // Subview’ları ekle
        addSubview(albumImageView)
        addSubview(titleLabel)
        addSubview(progressBar)
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)

        NSLayoutConstraint.activate([

            // MARK: - ALBUM IMAGE (EN ÜST SOL)

            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            albumImageView.widthAnchor.constraint(equalToConstant: 44),
            albumImageView.heightAnchor.constraint(equalToConstant: 44),

            // MARK: - TITLE (ALBÜM FOTOĞRAFININ SAĞI)

            titleLabel.leadingAnchor.constraint(
                equalTo: albumImageView.trailingAnchor,
                constant: 10
            ),

            titleLabel.centerYAnchor.constraint(equalTo: albumImageView.centerYAnchor),

            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            ),

            // MARK: - PROGRESS BAR (ALBÜM + TITLE ALTINDA)

            progressBar.topAnchor.constraint(
                equalTo: albumImageView.bottomAnchor,
                constant: 6
            ),

            progressBar.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),

            progressBar.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            ),

            // MARK: - BUTTONS (EN ALTTA ORTALI)

            playPauseButton.topAnchor.constraint(
                equalTo: progressBar.bottomAnchor,
                constant: 4
            ),

            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            previousButton.centerYAnchor.constraint(
                equalTo: playPauseButton.centerYAnchor
            ),

            previousButton.trailingAnchor.constraint(
                equalTo: playPauseButton.leadingAnchor,
                constant: -14
            ),

            nextButton.centerYAnchor.constraint(
                equalTo: playPauseButton.centerYAnchor
            ),

            nextButton.leadingAnchor.constraint(
                equalTo: playPauseButton.trailingAnchor,
                constant: 14
            ),
            
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        playPauseButton.target = self
        playPauseButton.action = #selector(togglePlayPause)
    }

    @objc private func togglePlayPause() {
        isPlaying.toggle()
        playPauseButton.title = isPlaying ? "⏸" : "▶"
    }
}
