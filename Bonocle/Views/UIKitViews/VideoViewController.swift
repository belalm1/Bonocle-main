//
//  VideoViewController.swift
//  WebRTC
//
//  Created by Stasel on 21/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import UIKit
import WebRTC

class VideoViewController: UIViewController {

    @IBOutlet private weak var localVideoView: UIView?
    private let webRTCClient: WebRTCClient

    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient // 1
        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Creates a video view and binds it to the frame of the localVideoView UIView
        let localRenderer = RTCMTLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero) // 2
        
        // Creates another video view and binds it to the frame of the current view's UIView
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame) // 3
        
        // Specifies the content mode so that the video views scale but maintain aspect ratio
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        
        // Notifies webRTCClient to start feeding the local video to the localRenderer
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer) // 4
        
        // Notifies webRTCClient to render the remote video to the remoteRenderer
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer) // 5
        
        // Embeds the video renderers into their relevant UIViews
        if let localVideoView = self.localVideoView { // 6
            self.embedView(localRenderer, into: localVideoView)
        }
        self.embedView(remoteRenderer, into: self.view) // 7
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
    
    @IBAction private func backDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
