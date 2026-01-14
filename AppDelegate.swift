import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Window
    var window: NSWindow?

    // MARK: - Boyutlar
    let collapsedHeight: CGFloat = 20
    let collapsedWidth: CGFloat  = 120

    let expandedHeight: CGFloat  = 150
    let expandedWidth: CGFloat   = 480

    let topOffset: CGFloat = 2

    // MARK: - State
    var isExpanded = false
    var isAnimating = false

    // MARK: - Referans frame (collapse)
    var baseFrame: NSRect!

    // MARK: - ROOT (HER ZAMAN VAR)
    let blurView = NSVisualEffectView()

    // MARK: - LAZY CONTAINER PROPERTY’LERİ
    var topContainer: NSView?
    var midContainer: NSView?
    var bottomContainer: NSView?
    var mid1Container: NSView?

    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {

        let notchScreen = NSScreen.screens.first {
            $0.safeAreaInsets.top > 0
        } ?? NSScreen.main!

        let screenFrame = notchScreen.frame

        baseFrame = NSRect(
            x: screenFrame.midX - collapsedWidth / 2,
            y: screenFrame.maxY - collapsedHeight - topOffset,
            width: collapsedWidth,
            height: collapsedHeight
        )

        window = NSWindow(
            contentRect: baseFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.level = .statusBar + 2
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        blurView.frame = baseFrame
        blurView.material = .hudWindow
        blurView.blendingMode = .behindWindow
        blurView.state = .active

        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = 14
        blurView.layer?.masksToBounds = true
        blurView.layer?.backgroundColor =
            NSColor.black.withAlphaComponent(0.25).cgColor

        window?.contentView = blurView

        // MARK: - TRACKING
        let trackingView = TrackingView(frame: blurView.bounds)
        trackingView.autoresizingMask = [.width, .height]

        trackingView.onMouseEnter = { [weak self] in
            self?.expandIfNeeded()
        }

        trackingView.onMouseExit = { [weak self] in
            self?.collapseIfNeeded()
        }

        blurView.addSubview(trackingView)
        window?.makeKeyAndOrderFront(nil)
    }

    // MARK: - STATE
    func expandIfNeeded() {
        guard !isExpanded, !isAnimating else { return }
        isExpanded = true
        loadContainers()
        animateExpand()
    }

    func collapseIfNeeded() {
        guard isExpanded, !isAnimating else { return }
        isExpanded = false
        animateCollapse()
    }

    // MARK: - LOAD (SENİN KODUN, AYNI)
    func loadContainers() {
        if topContainer != nil { return }

        // TOP
        let top = NSView()
        top.wantsLayer = true
        top.layer?.backgroundColor = NSColor.black.cgColor
        top.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(top)

        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: blurView.topAnchor),
            top.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            top.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            top.heightAnchor.constraint(equalToConstant: collapsedHeight)
        ])

        // MID
        let mid = NSView()
        mid.wantsLayer = true
        mid.layer?.backgroundColor = NSColor.red.cgColor
        mid.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(mid)

        NSLayoutConstraint.activate([
            mid.topAnchor.constraint(equalTo: top.bottomAnchor),
            mid.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            mid.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            mid.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -collapsedHeight)
        ])

        // MID1
        let mid1 = NSView()
        mid1.wantsLayer = true
        mid1.layer?.backgroundColor = NSColor.blue.cgColor
        mid1.translatesAutoresizingMaskIntoConstraints = false
        mid.addSubview(mid1)

        NSLayoutConstraint.activate([
            mid1.topAnchor.constraint(equalTo: mid.topAnchor, constant: 12),
            mid1.leadingAnchor.constraint(equalTo: mid.leadingAnchor),
            mid1.bottomAnchor.constraint(equalTo: mid.bottomAnchor, constant: -12),
            mid1.widthAnchor.constraint(equalTo: mid.widthAnchor, multiplier: 0.5)
        ])

        // MUSIC TOOL
        let musicToolView = MusicToolView()
        musicToolView.translatesAutoresizingMaskIntoConstraints = false
        mid1.addSubview(musicToolView)

        NSLayoutConstraint.activate([
            musicToolView.topAnchor.constraint(equalTo: mid1.topAnchor),
            musicToolView.leadingAnchor.constraint(equalTo: mid1.leadingAnchor),
            musicToolView.trailingAnchor.constraint(equalTo: mid1.trailingAnchor),
            musicToolView.bottomAnchor.constraint(equalTo: mid1.bottomAnchor)
        ])

        // BOTTOM
        let bottom = NSView()
        bottom.wantsLayer = true
        bottom.layer?.backgroundColor = NSColor.black.cgColor
        bottom.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(bottom)

        NSLayoutConstraint.activate([
            bottom.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            bottom.heightAnchor.constraint(equalToConstant: collapsedHeight)
        ])

        // PROPERTY BAĞLA
        topContainer = top
        midContainer = mid
        mid1Container = mid1
        bottomContainer = bottom
    }

    // MARK: - UNLOAD (COLLAPSE’TA TAMAMEN SÖK)
    func unloadContainers() {
        topContainer?.removeFromSuperview()
        midContainer?.removeFromSuperview()
        bottomContainer?.removeFromSuperview()

        topContainer = nil
        midContainer = nil
        mid1Container = nil
        bottomContainer = nil
    }

    // MARK: - ANIMATIONS
    func animateExpand() {
        guard let window = window else { return }
        isAnimating = true

        var frame = baseFrame!
        frame.origin.y -= (expandedHeight - collapsedHeight)
        frame.origin.x -= (expandedWidth - collapsedWidth) / 2
        frame.size = CGSize(width: expandedWidth, height: expandedHeight)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(frame, display: true)
        } completionHandler: {
            self.isAnimating = false
        }
    }

    func animateCollapse() {
        guard let window = window else { return }
        isAnimating = true

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(self.baseFrame, display: true)
        } completionHandler: {
            self.isAnimating = false
            self.unloadContainers()
        }
    }
}
