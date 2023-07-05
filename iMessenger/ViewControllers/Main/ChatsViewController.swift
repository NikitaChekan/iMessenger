//
//  ChatsViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.05.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import SPAlert

class ChatsViewController: MessagesViewController {
    
    // MARK: Properties
    private let user: MUser
    private let chat: MChat
    
    private var messages: [MMessage] = []
    private var messageListener: ListenerRegistration?
    
    // MARK: Init
    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUserName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .label
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )

        configureMessageInputBar()
        configureMessagesCollectionView()
        
        addListeners()
    }
    
    // MARK: Actions
    @objc func keyboardWillAppear(notification: NSNotification) {
        messagesCollectionView.contentInset.bottom += 10
        messagesCollectionView.scrollToLastItem()
    }
    
    @objc private func cameraButtonPressed(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Chose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: Methods
    private func addListeners() {
        messageListener = ListenerService.shared.messagesObserve(chat: chat) { [weak self] result in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    StorageService.shared.downloadImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let image):
                            message.image = image
                            self.insertNewMessage(message: message)
                        case .failure(let error):
                            let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                            alertView.duration = 4
                            alertView.present()

                        }
                    }
                } else {
                    self?.insertNewMessage(message: message)
                }
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
    }
    
    private func insertNewMessage(message: MMessage, isImage: Bool = false) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        
        messagesCollectionView.reloadData()
        
        if message.isViewed {
            self.messagesCollectionView.scrollToLastItem(animated: false)
        } else  {
            self.messagesCollectionView.scrollToLastItem(animated: true)
            FirestoreService.shared.updateViewedMessage(for: message.messageId, friendId: self.chat.friendId)
        }

    }
    
    private func sendImage(image: UIImage) {
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { result in
            switch result {
            case .success(let url):
                var message = MMessage(user: self.user, image: image, isViewed: false)
                message.downloadURL = url
                
                FirestoreService.shared.sendMessage(chat: self.chat, message: message, isImage: true) { result in
                    switch result {
                    case .success:
                        self.messagesCollectionView.scrollToLastItem()
                        FirestoreService.shared.updateViewedMessage(for: message.messageId, friendId: self.chat.friendId)
                    case .failure(_):
                        let alertView = SPAlertView(title: "Error!", message: "Image not delivered!", preset: .error)
                        alertView.duration = 4
                        alertView.present()
                    }
                }
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
    }
}

// MARK: - Configure message collection view
extension ChatsViewController {
    
    private func configureMessagesCollectionView() {
        // Configure messages collections view
        messagesCollectionView.backgroundColor = UIColor(named: "backgroundAppColor")
        messagesCollectionView.showsVerticalScrollIndicator = false
        
        setupLayoutMessageCollectionView()
        
        // Adding delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setupLayoutMessageCollectionView() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
}


// MARK: ConfigureMessageInputBar
extension ChatsViewController {
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "backgroundAppColor")
        messageInputBar.inputTextView.backgroundColor = UIColor(named: "textFieldLight")
        messageInputBar.inputTextView.placeholder = "Message"
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        
        messageInputBar.layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCameraIcon()
        
    }
    
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
//        messageInputBar.sendButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 6, trailing: 30)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -38
    }
    
    private func configureCameraIcon() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = UIColor(named: "messageColor")
        
        let cameraImage =  UIImage(systemName: "camera")!
        cameraItem.image = cameraImage
        
        cameraItem.addTarget(self, action: #selector(cameraButtonPressed), for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
}

// MARK: MessagesDataSource
extension ChatsViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        return MSender(senderId: user.id, displayName: user.userName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let beforeIndex = indexPath.index(before: indexPath.item)
        
        if beforeIndex >= 0 {
            let beforeMessage = messages[beforeIndex]
            
            if !beforeMessage.sentDate.hasSame(.day, as: message.sentDate) {
                return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ])
            }
        }
        
        return nil
    }
}

// MARK: MessagesLayoutDelegate
extension ChatsViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        let beforeIndex = indexPath.index(before: indexPath.item)
        
        if beforeIndex >= 0 {
            let beforeMessage = messages[beforeIndex]
            
            if !beforeMessage.sentDate.hasSame(.day, as: message.sentDate) {
                return 30
            }
        }
        
        return 0
    }
    
//    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
//        5
//    }
//
//    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
//        20
//    }
    
//    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
//        5
//    }
    
}

// MARK: MessagesDisplayDelegate
extension ChatsViewController: MessagesDisplayDelegate {
    
    // Text messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(named: "messageColor2")! : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
      }
    
    // All messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(named: "messageColor")!
    }
    
    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    //    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
    //        return .zero
    //    }
    
    // Location messages
    
}

// MARK: InputBarAccessoryViewDelegate
extension ChatsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MMessage(user: user, content: text, isViewed: false)
//        insertNewMessage(message: message) /// Удалили эту строчку 45 урок 15 мин
        
        FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
            switch result {
            case .success:
                self.messagesCollectionView.scrollToLastItem()
                FirestoreService.shared.updateViewedMessage(for: message.messageId, friendId: self.chat.friendId)
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
        
        inputBar.inputTextView.text = ""
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension ChatsViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        sendImage(image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UINavigationControllerDelegate
extension ChatsViewController: UINavigationControllerDelegate { }
