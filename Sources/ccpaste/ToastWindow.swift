import AppKit

final class ToastWindow: NSPanel {

    private let iconView: NSImageView
    private let messageLabel: NSTextField
    private var fadeTimer: Timer?

    init() {
        iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown

        messageLabel = NSTextField(labelWithString: "")
        messageLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        messageLabel.textColor = .labelColor
        messageLabel.alignment = .center
        messageLabel.backgroundColor = .clear
        messageLabel.isBordered = false
        messageLabel.isEditable = false
        messageLabel.lineBreakMode = .byTruncatingTail

        let size = NSSize(width: 220, height: 44)
        let frame = NSRect(origin: .zero, size: size)

        super.init(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .statusBar
        isOpaque = false
        hasShadow = true
        backgroundColor = .clear
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // Blur background — this IS the contentView, no extra frame
        let blur = NSVisualEffectView(frame: frame)
        blur.material = .popover
        blur.state = .active
        blur.blendingMode = .behindWindow
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 10
        blur.layer?.masksToBounds = true
        contentView = blur

        // Stack: icon + label
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        iconView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(messageLabel)
        blur.addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            stack.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: blur.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: blur.trailingAnchor, constant: -16),
        ])
    }

    func show(_ message: String, isError: Bool = false) {
        fadeTimer?.invalidate()

        // Icon
        let symbolName = isError ? "xmark.circle.fill" : "checkmark.circle.fill"
        let tintColor: NSColor = isError ? .systemRed : .systemGreen
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            iconView.image = image.withSymbolConfiguration(config)
            iconView.contentTintColor = tintColor
        }

        messageLabel.stringValue = message

        // Resize to fit
        let labelWidth = messageLabel.intrinsicContentSize.width
        let windowWidth = max(labelWidth + 68, 160)
        let windowSize = NSSize(width: windowWidth, height: 44)

        // Position at bottom-center of screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - windowSize.width / 2
            let y = screenFrame.minY + 80
            setFrame(NSRect(origin: NSPoint(x: x, y: y), size: windowSize), display: true)
        }

        // Fade in
        alphaValue = 0.0
        orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1.0
        }

        fadeTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { [weak self] _ in
            self?.fadeOut()
        }
    }

    private func fadeOut() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            self?.orderOut(nil)
        })
    }
}
