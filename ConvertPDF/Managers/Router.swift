//
//  Router.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 18.10.2025.
//

import SwiftUI

struct RouterEnvironmentKey: EnvironmentKey {
    static let defaultValue: Router = Router(nil)
}

extension EnvironmentValues {
    public var router: Router {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}

public class Router {
    
    public static var logEnabled = true
    
    public private(set) weak var viewController: UIViewController?
    
    public func onSwipeBack(_ onSwipeBack: (() -> Bool)?) {
        (viewController as? DiscardableHostingContoller)?.canSwipeBack = onSwipeBack
    }
    
    public init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


extension Router {
    
    static private var isPushInProgress: Bool = false
    
    public func push_r<T: View>(_ view: T, animated: Bool = true, allowsSwipeBack: Bool = true, completion: (() -> Void)? = nil) {
        guard Self.isPushInProgress == false else { return }
        Self.isPushInProgress = true

        let controller = RouterHostingController(rootView: view, allowsSwipeBack: allowsSwipeBack)
        viewController?.navigationController?.pushViewController(controller, animated: animated)
        
        guard animated, let coordinator = viewController?.navigationController?.transitionCoordinator else {
            Self.isPushInProgress = false
            OperationQueue.main.addOperation { completion?() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            Self.isPushInProgress = false
            completion?()
        }
    }
    
    public func pop(count: Int = 1, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard count > 0, let navigationController = viewController?.navigationController else { return }
        let viewControllers = navigationController.viewControllers
        
        if viewControllers.count > count {
            let destination = viewControllers[viewControllers.count - count - 1]
            navigationController.popToViewController(destination, animated: animated)
        } else {
            navigationController.popToRootViewController(animated: animated)
        }
        
        guard animated, let coordinator = navigationController.transitionCoordinator else {
            OperationQueue.main.addOperation { completion?() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }
    
    public func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.navigationController?.popToRootViewController(animated: animated)
        
        guard animated, let coordinator = viewController?.navigationController?.transitionCoordinator else {
            OperationQueue.main.addOperation { completion?() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }
}


extension Router {
    
    public func present_r<T>(_ view: T, style: UIModalPresentationStyle = .automatic, animated: Bool = true, completion: (() -> Void)? = nil) where T : View {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        viewController?.presentSafely(controller, animated: animated, completion: completion)
    }
    
    public func present_r<T: View>(_ view: T, style: UIModalPresentationStyle, transition: CATransition, completion: (() -> Void)? = nil) {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        viewController?.view.window?.layer.add(transition, forKey: kCATransition)
        viewController?.presentSafely(controller, animated: false, completion: completion)
    }
    
    public func present_r<T: View>(_ view: T, style: UIModalPresentationStyle, transition: UIModalTransitionStyle, completion: (() -> Void)? = nil) {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        controller.modalTransitionStyle = transition
        viewController?.presentSafely(controller, animated: true, completion: completion)
    }
    
    public func dismiss_r(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.dismiss(animated: animated, completion: completion)
    }
    
    public func dismiss_r(transition: UIModalTransitionStyle, completion: (() -> Void)? = nil) {
        viewController?.modalTransitionStyle = transition
        viewController?.dismiss(animated: true, completion: completion)
    }
    
    public func dismiss_r(transition: CATransition, completion: (() -> Void)? = nil) {
        viewController?.view.window?.layer.add(transition, forKey: kCATransition)
        viewController?.dismiss(animated: false, completion: completion)
    }
}

private extension UIViewController {
    func topMost() -> UIViewController {
        var top = self
        while let presented = top.presentedViewController { top = presented }
        return top
    }

    func presentSafely(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        let timeout: TimeInterval = 0.35
        let checkInterval: TimeInterval = 0.05
        let deadline = Date().addingTimeInterval(timeout)

        func attemptPresentation() {
            if presentedViewController == nil {
                present(controller, animated: animated, completion: completion)
            } else if Date() < deadline {
                DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval) {
                    attemptPresentation()
                }
            } else {
                present(controller, animated: animated, completion: completion)
            }
        }
        
        attemptPresentation()
    }
}

extension Router {
    
    public func activity(items: [String]) {
        presentActivityViewController(with: items)
    }
    
    public func activity(items: [URL]) {
        presentActivityViewController(with: items)
    }
    
    private func presentActivityViewController(with activityItems: [Any]) {
        guard !activityItems.isEmpty else { return }
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        if let view = viewController?.view,
           let pop = controller.popoverPresentationController {
            if #available(iOS 16.0, *) {
                pop.sourceItem = view
            } else {
                pop.sourceView = view
            }
            pop.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 1,
                height: 1
            )
            pop.permittedArrowDirections = []
        }

        viewController?.presentSafely(controller, animated: true)
    }
}

import StoreKit
extension Router {
    
    public func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    public func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            self.openURL(string: url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    public func openURL(string: String) {
        if let url = URL(string: string.trimmingCharacters(in: .whitespacesAndNewlines)) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    public func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 16.0, *) {
                Task {
                    await AppStore.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

private class DiscardableHostingContoller: UIHostingController<AnyView> {
    fileprivate var canSwipeBack: (() -> Bool)?
}

private final class RouterHostingController<T: View>: DiscardableHostingContoller {
    
    class InteractivePopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        let canGoBack: () -> Bool
        init(canGoBack: @escaping () -> Bool) {
            self.canGoBack = canGoBack
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return canGoBack()
        }
    }
    
    private var originalPopGestureDelegate: UIGestureRecognizerDelegate?
    private var delegate: InteractivePopGestureRecognizerDelegate?
    private var allowsSwipeBack: Bool
    
    init(rootView: T, allowsSwipeBack: Bool = true) {
        self.allowsSwipeBack = allowsSwipeBack
        super.init(rootView: AnyView(EmptyView()))
        self.rootView = AnyView(rootView.environment(\.router, Router(self)))
    }
    required init?(coder: NSCoder) { nil }
    
    deinit {
        if Router.logEnabled {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modalPresentationStyle == .overFullScreen || modalPresentationStyle == .overCurrentContext {
            view.backgroundColor = .clear
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate = InteractivePopGestureRecognizerDelegate(canGoBack: { [weak self] in
            (self?.navigationController?.viewControllers.count ?? 0) > 1 && (self?.canSwipeBack?() ?? self?.allowsSwipeBack ?? true)
        })
        originalPopGestureDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = delegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = originalPopGestureDelegate
        originalPopGestureDelegate = nil
        delegate = nil
    }
}

import MessageUI
extension Router {
    
    public func sendMail(text: String, recipients: [String], subject: String, completion: ((MFMailComposeResult) -> Void)? = nil) {
        guard MailMessageHelper.shared.canSendMail else {
            alert(
                "Mail Not Configured",
                message: "Please set up a Mail account in order to send emails."
            ) {
                Button("OK", role: .cancel) {}
            }
            completion?(.failed)
            return
        }
        let mail = MailMessageHelper.Mail(body: text, isHTML: false, subject: subject, recipients: recipients, attachment: nil)
        MailMessageHelper.shared.sendMail(mail, viewController: viewController, completion: completion)
    }
    
    public func sendMail(html: String, recipients: [String], subject: String, completion: ((MFMailComposeResult) -> Void)? = nil) {
        let mail = MailMessageHelper.Mail(body: html, isHTML: true, subject: subject, recipients: recipients, attachment: nil)
        MailMessageHelper.shared.sendMail(mail, viewController: viewController, completion: completion)
    }
    
    public func sendMessage(text: String, recipients: [String], subject: String, completion: ((MessageComposeResult) -> Void)? = nil) {
        let message = MailMessageHelper.Message(body: text, recipients: recipients, fileURL: nil)
        MailMessageHelper.shared.sendMessage(message, viewController: viewController, completion: completion)
    }
}

final class MailMessageHelper: NSObject, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    struct Mail {
        struct Attachment {
            let data: Data
            let mimeType: String
            let filename: String
        }
        
        let body: String
        let isHTML: Bool
        var subject: String? = nil
        var recipients: [String] = []
        var attachment: Attachment? = nil
    }
    
    struct Message {
        let body: String
        var recipients: [String] = []
        var fileURL: URL? = nil
    }
    
    static let shared = MailMessageHelper()
    override private init() {}
    
    private var sendMailCompletion: ((MFMailComposeResult) -> Void)?
    private var sendMessageCompletion: ((MessageComposeResult) -> Void)?
    
    var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    var canSendMessage: Bool {
        MFMessageComposeViewController.canSendText()
    }
    
    func sendMessage(_ message: Message, viewController: UIViewController?, completion: ((MessageComposeResult) -> Void)? = nil) {
        sendMessageCompletion = nil
        guard let viewController, canSendMessage else { completion?(.failed); return }
        
        sendMessageCompletion = completion
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.popoverPresentationController?.sourceView = viewController.view
        messageController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 1, height: 1)
        
        messageController.body = message.body
        messageController.recipients = message.recipients
        if let fileURL = message.fileURL {
            messageController.addAttachmentURL(fileURL, withAlternateFilename: fileURL.lastPathComponent)
        }
        viewController.presentSafely(messageController, animated: true)
    }
    
    func sendMail(_ mail: Mail, viewController: UIViewController?, completion: ((MFMailComposeResult) -> Void)? = nil) {
        sendMailCompletion = nil
        guard let viewController, canSendMail else { completion?(.failed); return }
        
        sendMailCompletion = completion
        
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.popoverPresentationController?.sourceView = viewController.view
        mailController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 1, height: 1)
        
        mailController.setToRecipients(mail.recipients)
        mailController.setMessageBody("<p>\(mail.body)</p>", isHTML: true)
        if let subject = mail.subject {
            mailController.setSubject(subject)
        }
        if let attachment = mail.attachment {
            mailController.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.filename)
        }
        viewController.presentSafely(mailController, animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) { [weak self] in
            self?.sendMessageCompletion?(result)
            self?.sendMessageCompletion = nil
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            self?.sendMailCompletion?(result)
            self?.sendMailCompletion = nil
        }
    }
    
}

extension Router {
    public func alert<A>(_ title: String?, message: String? = nil, style: UIAlertController.Style = .alert, @ViewBuilder actions: @escaping () -> A) where A: View {
        let alertView = AlertView(title: title, message: message, actions: actions, style: style)
        self.present_r(alertView, style: .overFullScreen, animated: false)
    }
}


private struct AlertView<A: View>: View {
    @Environment(\.router) private var router
    @State private var isPresented: Bool = true
    
    let title: String?
    let message: String?
    let actions: () -> A
    let style: UIAlertController.Style
    
    var body: some View {
        switch style {
        case .actionSheet:
            Color.clear.frame(width: 1, height: 1).confirmationDialog(title ?? "", isPresented: $isPresented, titleVisibility: title == nil ? .hidden : .visible, actions: actions) {
                if let message {
                    Text(message)
                }
            }
        default:
            Color.clear.alert(title ?? "", isPresented: $isPresented, actions: actions) {
                if let message {
                    Text(message)
                }
            }
        }
        Spacer().onChangeOf(isPresented) { _ in
            router.dismiss_r(animated: false)
        }
    }
}

public struct RouterView<T: View>: View {
    
    private let navigationBarHidden: Bool
    private let content: (Router) -> T
    
    public init(_ content: T) {
        self.init({ content })
    }
    
    public init(@ViewBuilder _ content: @escaping () -> T) {
        self.init({ _ in content()})
    }
    
    public init(navigationBarHidden: Bool = true, @ViewBuilder _ content: @escaping (_ router: Router) -> T) {
        self.navigationBarHidden = navigationBarHidden
        self.content = content
    }
    
    public var body: some View {
        NavigationControllerView(navigationBarHidden: navigationBarHidden, content: content)
            .edgesIgnoringSafeArea(.all)
    }
}

struct NavigationControllerView<Content: View>: UIViewControllerRepresentable {
    
    private let content: (Router) -> Content
    private let navigationBarHidden: Bool
    
    init(navigationBarHidden: Bool, content: @escaping (Router) -> Content) {
        self.content = content
        self.navigationBarHidden = navigationBarHidden
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let rootController = RouterHostingController(rootView: AnyView(EmptyView()))
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.setNavigationBarHidden(navigationBarHidden, animated: false)
        let router = Router(rootController)
        rootController.view.backgroundColor = .clear
        rootController.rootView = AnyView(content(router).environment(\.router, router))
        return navigationController
    }
    
    func updateUIViewController(_ uiView: UIViewController, context: Context) {
        if let navController = uiView as? UINavigationController, let rootController = navController.viewControllers.first as? UIHostingController<AnyView> {
            let router = Router(rootController)
            rootController.rootView = AnyView(content(router).environment(\.router, router))
        }
    }
}

extension CATransition {
    public static func easeIn(duration: CFTimeInterval = 0.25, type: TransitionType = .fade) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
}


public struct TransitionType {
    fileprivate var type: CATransitionType
    fileprivate var subtype: CATransitionSubtype?
    public static let fade = TransitionType(type: .fade, subtype: nil)
}
