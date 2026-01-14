import Cocoa
// Cocoa = macOS AppKit dünyasının ana framework’ü
// NSWindow, NSScreen, NSApplication, NSVisualEffectView vb.

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Window
    var window: NSWindow?

    // MARK: - Boyutlar
    let collapsedHeight: CGFloat = 20          // Kapalıyken yükseklik
    let collapsedWidth: CGFloat  = 120         // Kapalıyken genişlik (çentikten küçük)

    let expandedHeight: CGFloat  = 150         // Açıkken yükseklik
    let expandedWidth: CGFloat   = 480         // Açıkken genişlik

    let topOffset: CGFloat = 2
    // Menü bar alanının İÇİNE girmek için küçük offset

    // MARK: - State
    var isExpanded: Bool = false               // Şu an açık mı kapalı mı
    var isAnimating: Bool = false              // Animasyon kilidi

    // MARK: - Referans frame (collapse hali)
    var baseFrame: NSRect!

    // MARK: - Containers (🔴 PROPERTY OLMAK ZORUNDA)
    // Bunlar applicationDidFinishLaunching dışından erişilecek (isHidden için)
    private let blurView = NSVisualEffectView()    // Root blur view
    private let topContainer = NSView()            // Collapse alanı
    private let midContainer = NSView()            // Tool alanı (expand’te görünür)
    private let bottomContainer = NSView()         // Alt alan (expand’te görünür)

    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {

        NSLog("🚀 Centik başlatıldı")

        // 🔹 ÇENTİKLİ EKRANI BUL
        let notchScreen = NSScreen.screens.first {
            $0.safeAreaInsets.top > 0
        } ?? NSScreen.main!

        // 🔹 EKRANIN TAMAMI (menü bar + notch DAHİL)
        let screenFrame = notchScreen.frame

        // 🔹 COLLAPSE HALİ REFERANS FRAME
        baseFrame = NSRect(
            x: (screenFrame.width - collapsedWidth) / 2,                  // Yatayda ortala
            y: screenFrame.maxY - collapsedHeight - topOffset,            // Menü bar içine gir
            width: collapsedWidth,
            height: collapsedHeight
        )

        // 🔹 WINDOW
        window = NSWindow(
            contentRect: baseFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.level = .statusBar + 2
        window?.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        // MARK: - BLUR VIEW (GERÇEK macOS BLUR)
        blurView.frame = baseFrame
        // Blur view’ı ilk frame ile başlatıyoruz (AutoLayout da yapacağız)

        blurView.material = .hudWindow
        blurView.blendingMode = .behindWindow
        blurView.state = .active

        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = 14
        blurView.layer?.masksToBounds = true
        // 🔴 Çok kritik: Collapse halde taşan içerikleri KESER

        blurView.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(0.25).cgColor

        window?.contentView = blurView

        // MARK: - TOP CONTAINER
        topContainer.wantsLayer = true
        topContainer.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(1).cgColor

        topContainer.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(topContainer)

        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: blurView.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            topContainer.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.18)
        ])

        // MARK: - MID CONTAINER
        midContainer.wantsLayer = true
        midContainer.layer?.backgroundColor =
            NSColor.red.withAlphaComponent(1).cgColor

        midContainer.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(midContainer)

        NSLayoutConstraint.activate([
            midContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            midContainer.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            midContainer.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            midContainer.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.64)
        ])

        // MID CONTAINER PART-1
        let mid1Container = NSView()
        mid1Container.wantsLayer = true
        mid1Container.layer?.backgroundColor =
            NSColor.blue.withAlphaComponent(1).cgColor

        mid1Container.translatesAutoresizingMaskIntoConstraints = false
        midContainer.addSubview(mid1Container)

        NSLayoutConstraint.activate([
            mid1Container.topAnchor.constraint(equalTo: midContainer.topAnchor, constant: 12),
            mid1Container.leadingAnchor.constraint(equalTo: midContainer.leadingAnchor),
            mid1Container.bottomAnchor.constraint(equalTo: midContainer.bottomAnchor, constant: -12),
            mid1Container.widthAnchor.constraint(equalTo: midContainer.widthAnchor, multiplier: 0.5)
        ])

        // MARK: - MUSIC TOOL EKLEME (mid1Container içine)
        let musicToolView = MusicToolView()
        musicToolView.translatesAutoresizingMaskIntoConstraints = false
        mid1Container.addSubview(musicToolView)

        NSLayoutConstraint.activate([
            musicToolView.topAnchor.constraint(equalTo: mid1Container.topAnchor),
            musicToolView.leadingAnchor.constraint(equalTo: mid1Container.leadingAnchor),
            musicToolView.trailingAnchor.constraint(equalTo: mid1Container.trailingAnchor),
            musicToolView.bottomAnchor.constraint(equalTo: mid1Container.bottomAnchor)
        ])

        // MARK: - BOTTOM CONTAINER
        bottomContainer.wantsLayer = true
        bottomContainer.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(1).cgColor

        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(bottomContainer)

        NSLayoutConstraint.activate([
            bottomContainer.topAnchor.constraint(equalTo: midContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            bottomContainer.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.18)
        ])

        // MARK: - TRACKING VIEW (Mouse Event’ler)
        let trackingView = TrackingView(frame: blurView.bounds)
        trackingView.autoresizingMask = [.width, .height]
        trackingView.wantsLayer = true
        trackingView.layer?.backgroundColor = NSColor.clear.cgColor

        trackingView.onMouseEnter = { [weak self] in
            self?.expandIfNeeded()
        }

        trackingView.onMouseExit = { [weak self] in
            self?.collapseIfNeeded()
        }

        blurView.addSubview(trackingView)

        // ✅ Uygulama ilk açıldığında collapse mod başlat
        isExpanded = false
        updateVisibility()
        // 🔴 Collapse’ta mid/bottom gizlenir (layout baskısı biter)

        window?.makeKeyAndOrderFront(nil)
    }

    // MARK: - Visibility (isHidden mantığı)
    private func updateVisibility() {
        // Collapse modda: tool alanlarını gizle
        topContainer.isHidden = !isExpanded
        midContainer.isHidden = !isExpanded
        bottomContainer.isHidden = !isExpanded
        // topContainer asla gizlenmez (collapse çizgisi orada)
    }

    // MARK: - State Kontrollü Geçişler
    func expandIfNeeded() {
        guard !isExpanded, !isAnimating else { return }
        isExpanded = true
        updateVisibility()
        // 🔴 Expand başlamadan önce görünür yapıyoruz (titreme azalır)
        animateExpand()
    }

    func collapseIfNeeded() {
        guard isExpanded, !isAnimating else { return }
        isExpanded = false
        // 🔴 Collapse animasyonu bitsin, sonra gizle → daha doğal görünür
        animateCollapse()
    }

    // MARK: - Animasyonlar (TİTREME YOK)
    func animateExpand() {
        guard let window = window else { return }
        isAnimating = true

        var frame = baseFrame!
        frame.origin.y -= (expandedHeight - collapsedHeight)
        frame.origin.x -= (expandedWidth - collapsedWidth) / 2
        frame.size = CGSize(width: expandedWidth, height: expandedHeight)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(frame, display: true)
        } completionHandler: {
            self.isAnimating = false
        }
    }

    func animateCollapse() {
        guard let window = window else { return }
        isAnimating = true

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(self.baseFrame, display: true)
        } completionHandler: {
            self.isAnimating = false
            self.updateVisibility()
            // ✅ Animasyon bitince gizle (collapse’ta jump olmaz)
        }
    }

    @objc func testButtonClicked() {
        print("Butona basıldı")
    }
}
