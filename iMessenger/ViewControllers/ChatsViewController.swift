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
//        navigationItem.backBarButtonItem?.title = "Back"
        
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
                            self.showAlert(with: "Ошибка!", and: error.localizedDescription)

                        }
                    }
                } else {
                    self?.insertNewMessage(message: message)
                }
            case .failure(let error):
                self?.showAlert(with: "Ошибка!", and: error.localizedDescription)
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
    
    private func sendImage(image: UIImage) {
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { result in
            switch result {
            case .success(let url):
                var message = MMessage(user: self.user, image: image, isViewed: false)
                message.downloadURL = url
                
                FirestoreService.shared.sendMessage(chat: self.chat, message: message) { result in
                    switch result {
                    case .success:
                        self.messagesCollectionView.scrollToLastItem()
                        FirestoreService.shared.updateViewedMessage(for: message.messageId, friendId: self.chat.friendId)
                    case .failure(_):
                        self.showAlert(with: "Ошибка!", and: "Изображение не доставлено")
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - Configure message collection view
extension ChatsViewController {
    
    private func configureMessagesCollectionView() {
        // Configure messages collections view
        messagesCollectionView.backgroundColor = UIColor(named: "mainWhiteColor")
        messagesCollectionView.showsVerticalScrollIndicator = false
        
        setupLayoutMessageCollectionView()
        
        // Adding delegates
        messageInputBar.delegate = self
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
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "mainWhiteColor")
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
        if indexPath.item % 5 == 0 {
                return NSAttributedString(
                    string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                    attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ])
        } else {
            return nil
        }
    }
    
}

// MARK: MessagesLayoutDelegate
extension ChatsViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if (indexPath.item) % 5 == 0 {
            return 30
        } else {
            return 0
        }
    }
}

// MARK: MessagesDisplayDelegate
extension ChatsViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(named: "messageColor")!
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(named: "messageColor2")! : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
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
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
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
