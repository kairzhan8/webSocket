//
//  ViewController.swift
//  WebSocket
//
//  Created by Kairzhan on 09.03.2022.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        
        view.addSubview(closeButton)
        closeButton.frame = .init(x: 0, y: 0, width: 200, height: 50)
        closeButton.center = view.center
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue())
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
    }

    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.send()
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...200))"), completionHandler: { error in
                if let error = error {
                    print("Sending error: \(error)")
                }
            })
        }
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let data):
                switch data {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
                    print("Got string: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receiving error: \(error)")
            }
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }
}

