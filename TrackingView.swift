import Cocoa // NSView ve event’ler için

final class TrackingView: NSView { // Mouse event’lerini yakalayacak özel view

    var onMouseEnter: (() -> Void)? // Mouse girince çalışacak callback
    var onMouseExit: (() -> Void)?  // Mouse çıkınca çalışacak callback

    private var trackingArea: NSTrackingArea? // Tracking alanını saklarız

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        // 🔴 HOVER ALGILAMA ALANI AYARI
        let hoverPaddingBottom: CGFloat = 30
        // Mouse, pencerenin 30px ALTINDAYKEN bile algılansın
        // 20–40 arası çok ideal, zevkine göre ayarlarsın

        let expandedRect = bounds.insetBy(
            dx: 0,
            dy: -hoverPaddingBottom
        )
        // bounds'u AŞAĞI doğru genişletiyoruz

        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect
        ]

        trackingArea = NSTrackingArea(
            rect: expandedRect,
            options: options,
            owner: self,
            userInfo: nil
        )

        addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) { // Mouse view içine girince
        onMouseEnter?() // Callback varsa çalıştır
    }

    override func mouseExited(with event: NSEvent) { // Mouse view dışına çıkınca
        onMouseExit?() // Callback varsa çalıştır
    }
}//
//  TrackingView.swift
//  centik
//
//  Created by Tibet Mıdık on 12.01.2026.
//

