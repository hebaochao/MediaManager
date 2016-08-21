//
//  NTVideoPlayerViewController.swift
//  Communicator
//
//  Created by ChinaTeam on 16/7/22.
//  Copyright © 2016年 Neatlyco. All rights reserved.
//

import UIKit
import MediaPlayer

class NTVideoPlayerViewController: UIViewController {
    
    
    //TZAssetModel
    var  model:TZAssetModel?
    //player
    var  player:AVPlayer?
    var  playButton:UIButton?
    var  cover:UIImage?
    var  progress:UIProgressView?
    //delegate
    weak  var mydelegate:NTAssetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.title = "Video preview"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(NTVideoPlayerViewController.selectDoneAction))
        //load movie  init subview
        self.initMoviePlayer()
    }
    
    
    func initMoviePlayer(){
        //get cover imgae
        TZImageManager.sharemanager().getPhotoWithAsset(self.model!.asset) { [weak self](image, infoDict, isDegraded) in
            self?.cover = image
        }
        // load video
        TZImageManager.sharemanager().getVideoWithAsset(self.model!.asset) { [weak self](playerItem, infoDict) in
              dispatch_async(dispatch_get_main_queue(), { 
                self?.player = AVPlayer(playerItem: playerItem)
                let playerLayer:AVPlayerLayer = AVPlayerLayer(player: self?.player )
                 playerLayer.frame = (self?.view.bounds)!
                 self?.view.layer.addSublayer(playerLayer)
                 //init Progress
                  self?.addProgressObserver()
                //add play btn
                  self?.addPlayButton()
                  NSNotificationCenter.defaultCenter().addObserver(self!, selector: #selector(NTVideoPlayerViewController.pausePlayerAndShowNaviBar), name: AVPlayerItemDidPlayToEndTimeNotification, object: self?.player!.currentItem)
                
              })
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NTVideoPlayerViewController.playBtnAction)))

    }
    
    
    func addProgressObserver(){
        let playerItem:AVPlayerItem = self.player!.currentItem!
        self.progress = UIProgressView()
       
        self.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (time) in
            
           let current:Float64  = CMTimeGetSeconds(time)
            let total:Float64  = CMTimeGetSeconds(playerItem.duration)
            if current != 0 {
              
                self.progress!.setProgress(  Float(current/total), animated: true)
            }
            
        })
    }
    
    func addPlayButton(){
        self.playButton = UIButton(type: .Custom)
        self.view.addSubview(self.playButton!)
        self.playButton!.setImage(UIImage(named: "MMVideoPreviewPlay"), forState: UIControlState.Normal)
        self.playButton!.setImage(UIImage(named: "MMVideoPreviewPlayHL"), forState: UIControlState.Highlighted)
        self.playButton!.addTarget(self, action: #selector(NTVideoPlayerViewController.playBtnAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.playButton!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.playButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.playButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        self.playButton!.addConstraint(NSLayoutConstraint(item:  self.playButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 50.0))
        self.playButton!.addConstraint(NSLayoutConstraint(item:  self.playButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant:  50.0))
        
        
    }
    //MARK: play video action
    func playBtnAction(){
        let currentTime:CMTime  = self.player!.currentItem!.currentTime()
        let durationTime:CMTime = self.player!.currentItem!.duration
        if self.player!.rate == 0.0  {
            
            if currentTime.value == durationTime.value{
              self.player!.currentItem?.seekToTime(CMTimeMake(0, 1))
            }
            self.player?.play()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
          
            self.playButton?.setImage(nil, forState: UIControlState.Normal)
           
          
        } else {
            self.pausePlayerAndShowNaviBar()
       
        }
        
    }
    
    //MARK: pausePlayerAndShowNaviBar
    func pausePlayerAndShowNaviBar(){
        
        self.player?.pause()
    
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.playButton!.setImage(UIImage(named: "MMVideoPreviewPlay"), forState: UIControlState.Normal)
        
    }
    
    
    
    //MARK: selectDoneAction
    func selectDoneAction(){
        //set data
        let imageAssetModel:NTImageAssetModel = NTImageAssetModel()
        imageAssetModel.assetModel = self.model
        imageAssetModel.coverImage = cover
        //delegate action
         mydelegate?.doneActionPickImageList!([imageAssetModel])
        //dismissViewControllerAnimated
        if (self.navigationController != nil) {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
  
   

}
