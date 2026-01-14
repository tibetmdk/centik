import Cocoa
// Cocoa = macOS AppKit dünyasının ana framework’ü
// NSView, NSButton, NSTextField gibi UI elemanları burada

final class MusicToolView: NSView {
    // final = Bu class’tan miras alınamaz
    // MusicToolView = sadece bu işi yapacak, genişletilmeyecek bir UI parçası

    // MARK: - UI Elemanları

    private let titleLabel = NSTextField(labelWithString: "One Kiss /w Shea")
    // Şarkı adını göstermek için label
    // labelWithString → editable olmayan, sadece görüntü amaçlı text

    private let previousButton = NSButton(title: "⏮", target: nil, action: nil)
    // Önceki şarkı butonu (şimdilik sadece UI)

    private let playPauseButton = NSButton(title: "▶", target: nil, action: nil)
    // Play / Pause butonu

    private let nextButton = NSButton(title: "⏭", target: nil, action: nil)
    // Sonraki şarkı butonu

    private var isPlaying = false
    // Müzik şu anda çalıyor mu bilgisini tutar
    // false = duruyor, true = çalıyor

    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        // NSView’ın kendi init’ini çağırıyoruz

        setupView()
        // Görsel ayarlar (renk, font vs.)

        setupLayout()
        // Auto Layout constraint’leri

        setupActions()
        // Butonlara tıklama davranışı
    }

    required init?(coder: NSCoder) {
        // Storyboard / XIB kullanmadığımız için bunu kapatıyoruz
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Ayarları

    private func setupView() {
        wantsLayer = true
        // Bu view layer kullansın (arka plan, animasyon vs.)

        layer?.backgroundColor = NSColor.clear.cgColor
        // Arka planı şeffaf
        // Blur zaten parent view’dan geliyor

        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        // Şarkı adı için font ayarı

        titleLabel.textColor = .white
        // Yazı rengi beyaz

        titleLabel.lineBreakMode = .byTruncatingTail
        // Yazı uzun olursa "..." ile kessin

        previousButton.bezelStyle = .texturedRounded
        playPauseButton.bezelStyle = .texturedRounded
        nextButton.bezelStyle = .texturedRounded
        // macOS’e uygun yuvarlatılmış buton stili
    }

    // MARK: - Layout (Constraint’ler)

    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        // Auto Layout kullanacağımızı söylüyoruz
        // Frame bazlı yerleşimi kapatıyoruz

        addSubview(titleLabel)
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        // Elemanları MusicToolView’ın içine ekliyoruz

        NSLayoutConstraint.activate([
            // --- TITLE LABEL ---

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            // Title, MusicToolView’ın üstünden 10px aşağıda olsun

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            // Soldan 16px boşluk bırak

            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            // Sağdan 16px boşluk bırak

            // --- PLAY / PAUSE BUTTON ---

            playPauseButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            // Play/Pause, title’ın altına 12px boşlukla gelsin

            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            // Yatayda tam ortaya hizala

            // --- PREVIOUS BUTTON ---

            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            // Önceki buton, Play/Pause ile aynı hizada olsun

            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -12),
            // Play/Pause’un soluna 12px boşlukla koy

            // --- NEXT BUTTON ---

            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            // Sonraki buton da aynı hizada olsun

            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 12)
            // Play/Pause’un sağına 12px boşlukla koy
        ])
    }

    // MARK: - Actions (Buton Davranışları)

    private func setupActions() {
        playPauseButton.target = self
        // Butona basıldığında bu class hedef alınsın

        playPauseButton.action = #selector(togglePlayPause)
        // Butona basıldığında togglePlayPause fonksiyonu çağrılsın
    }

    @objc private func togglePlayPause() {
        isPlaying.toggle()
        // true ↔ false arasında geçiş yap

        playPauseButton.title = isPlaying ? "⏸" : "▶"
        // Çalıyorsa pause ikonu, değilse play ikonu göster
    }
}
