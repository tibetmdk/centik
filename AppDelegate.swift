import Cocoa
// Cocoa = macOS AppKit dünyasının ana framework’ü
// NSWindow, NSScreen, NSApplication, NSVisualEffectView vb.

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Window
    var window: NSWindow?

    // MARK: - Boyutlar
    let collapsedHeight: CGFloat = 20          // Kapalıyken yükseklik
    let collapsedWidth: CGFloat  = 120        // Kapalıyken genişlik (çentikten küçük)

    let expandedHeight: CGFloat  = 150        // Açıkken yükseklik
    let expandedWidth: CGFloat   = 480        // Açıkken genişlik

    let topOffset: CGFloat = 2
    // Menü bar alanının İÇİNE girmek için küçük offset
    // 2–6 arası cihazına göre oynatabilirsin

    // MARK: - State
    var isExpanded: Bool = false              // Şu an açık mı kapalı mı
    var isAnimating: Bool = false             // Animasyon kilidi

    // MARK: - Referans frame (collapse hali)
    var baseFrame: NSRect!

    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {

        NSLog("🚀 Centik başlatıldı")

        // 🔹 ÇENTİKLİ EKRANI BUL
        let notchScreen = NSScreen.screens.first {
            // Çentikli ekranlarda safeAreaInsets.top > 0 olur
            $0.safeAreaInsets.top > 0
        } ?? NSScreen.main!

        // 🔹 EKRANIN TAMAMI (menü bar + notch DAHİL)
        let screenFrame = notchScreen.frame

        // 🔹 COLLAPSE HALİ REFERANS FRAME
        baseFrame = NSRect(
            x: (screenFrame.width - collapsedWidth) / 2,
            // Yatayda ortala

            y: screenFrame.maxY - collapsedHeight - topOffset,
            // 🔴 ÇENTİK / MENÜ BAR ALANININ İÇİNE GİR

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
        // Menü bar’dan BİR TIK ÜST → çentiğin arkasına girebilir

        window?.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        // MARK: - BLUR VIEW (GERÇEK macOS BLUR)
        let blurView = NSVisualEffectView(frame: baseFrame)

        blurView.material = .hudWindow
        // Koyu, Apple hissi yüksek blur

        blurView.blendingMode = .behindWindow
        // Arka planla gerçek blur

        blurView.state = .active

        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = 14
        blurView.layer?.masksToBounds = true

        // Hafif koyuluk (opsiyonel ama güzel)
        blurView.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(0.25).cgColor
        
        //MARK: - TOP CONTAINER
        
        let topContainer = NSView()
        topContainer.wantsLayer = true
        topContainer.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(1).cgColor

        topContainer.translatesAutoresizingMaskIntoConstraints = false
        // 🔴 Auto Layout’a teslim

        blurView.addSubview(topContainer)

        NSLayoutConstraint.activate([
            // ÜSTE YAPIŞ
            topContainer.topAnchor.constraint(equalTo: blurView.topAnchor),

            // SOL & SAĞI DOLDUR
            topContainer.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),

            // SABİT YÜKSEKLİK (örnek: collapse alanı)
            topContainer.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.18)
        ])
        
        // MARK: - 2 MID CONTAINER
        
        let midContainer = NSView()
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
        
        //MARK: - 2 BOTTOM CONTAINER
        
        let bottomContainer = NSView()
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
        // Pencere büyüyüp küçülürken view da uyum sağlasın

        trackingView.wantsLayer = true
        trackingView.layer?.backgroundColor = NSColor.clear.cgColor

        trackingView.onMouseEnter = { [weak self] in
            self?.expandIfNeeded()
        }

        trackingView.onMouseExit = { [weak self] in
            self?.collapseIfNeeded()
        }

        blurView.addSubview(trackingView)
        window?.contentView = blurView

        window?.makeKeyAndOrderFront(nil)
    }

    // MARK: - State Kontrollü Geçişler

    func expandIfNeeded() {
        guard !isExpanded, !isAnimating else { return }
        isExpanded = true
        animateExpand()
    }

    func collapseIfNeeded() {
        guard isExpanded, !isAnimating else { return }
        isExpanded = false
        animateCollapse()
    }

    // MARK: - Animasyonlar (TİTREME YOK)

    func animateExpand() {
        guard let window = window else { return }
        isAnimating = true

        var frame = baseFrame!
        // 🔴 HER ZAMAN REFERANS FRAME’DEN HESAPLA

        frame.origin.y -= (expandedHeight - collapsedHeight)
        // Aşağı doğru açıl → üst sabit

        frame.origin.x -= (expandedWidth - collapsedWidth) / 2
        // Merkezden genişle

        frame.size = CGSize(
            width: expandedWidth,
            height: expandedHeight
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction =
                CAMediaTimingFunction(name: .easeInEaseOut)

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
            context.timingFunction =
                CAMediaTimingFunction(name: .easeInEaseOut)

            window.animator().setFrame(self.baseFrame, display: true)
        } completionHandler: {
            self.isAnimating = false
        }
    }
    
    @objc func testButtonClicked() {
        print("Butona basıldı")
    }
}
