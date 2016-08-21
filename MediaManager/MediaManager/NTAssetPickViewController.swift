//
//  NTAssetPickViewController.swift
//  Communicator
//
//  Created by ChinaTeam on 16/7/22.
//  Copyright © 2016年 Neatlyco. All rights reserved.
//

import UIKit

class NTAssetPickViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var model:TZAlbumModel?
    var collectionView:UICollectionView?
    var models:NSMutableArray = NSMutableArray()
    
    //delegate 
    weak  var mydelegate:NTAssetViewControllerDelegate?
    
    var doneBtn:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = model?.name
        self.doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(NTAssetPickViewController.doneAction))
        self.navigationItem.rightBarButtonItem = doneBtn!
        self.createUI()
      
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
          self.loadData()
          self.updateDoneState()
    }
    
    func createUI(){
        let lintNumber:CGFloat = 4.0
        let spance:CGFloat = 2.0
        let window_width:CGFloat = UIScreen.mainScreen().bounds.size.width
        let count_spance:CGFloat = (lintNumber + 1) * spance
        let width =  (window_width - count_spance)/4.0
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(width, width)
        layout.minimumLineSpacing = spance
        layout.minimumInteritemSpacing = spance
        layout.sectionInset = UIEdgeInsetsMake(0, spance, 0, spance)
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.view.addSubview(self.collectionView!)
        self.collectionView?.registerClass(NTAssetPickViewCell.self, forCellWithReuseIdentifier: "NTAssetPickViewCell")
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.contentInset  = UIEdgeInsetsMake(5, 0, 5, 0)
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
    }
    //MARK： load data
    func loadData(){
        TZImageManager.sharemanager().getAssetsFromFetchResult(self.model?.result, allowPickingVideo: true, allowPickingImage: true) { [weak self](assetModellist) in
            self?.models = NSMutableArray(array: assetModellist)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //collection view delegate 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models.count
    }
    
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:NTAssetPickViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("NTAssetPickViewCell", forIndexPath: indexPath) as! NTAssetPickViewCell
        //get cell data
         cell.setData(  self.models.objectAtIndex(indexPath.row) as! TZAssetModel)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       let cell:NTAssetPickViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! NTAssetPickViewCell
        let model:TZAssetModel = self.models.objectAtIndex(indexPath.row) as! TZAssetModel
        if model.type == TZAssetModelMediaTypePhoto { //photo
            model.isSelected = !model.isSelected
            cell.selectBtn.selected = model.isSelected
            //update done state
            self.updateDoneState()
        }else{
            for  mymodel  in self.models {
                if mymodel.type == TZAssetModelMediaTypePhoto && mymodel.isSelected == true { //photo
                    return
                }
            }
            //not image select  go to play video
            let videoPlayerVC:NTVideoPlayerViewController = NTVideoPlayerViewController()
            videoPlayerVC.mydelegate = self.mydelegate
            videoPlayerVC.model = model
            self.navigationController?.pushViewController(videoPlayerVC, animated: true)
        }
        
        
    }

    
    func updateDoneState(){
        for  mymodel  in self.models {
            if mymodel.type == TZAssetModelMediaTypePhoto && mymodel.isSelected == true { //photo
                self.doneBtn!.enabled = true
                  return
            }
        }
         self.doneBtn!.enabled = false
    }
    
    var imageList:Array<UIImage> = []
    func doneAction(){
       var result:Array<NTImageAssetModel> = []
        for  index  in 0...self.models.count - 1 {
            let mymodel = self.models.objectAtIndex(index)
            if mymodel.type == TZAssetModelMediaTypePhoto && mymodel.isSelected == true {
                //get select asset
                let imageAssetModel = NTImageAssetModel()
                   imageAssetModel.assetModel  =  mymodel as? TZAssetModel
                
                //get originalImage
//                TZImageManager.sharemanager().getPhotoWithAsset(imageAssetModel.assetModel?.asset, completion: { [weak self](photo, dict, isdone) in
//                    // doneActionPickOriginalImage action
//                     self?.mydelegate?.doneActionPickOriginalImage!(photo)
//                 })
             
  
                //  get coverImage
                let cell:NTAssetPickViewCell = collectionView!.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! NTAssetPickViewCell
                  imageAssetModel.coverImage =  cell.nt_imageView.image
                
                  result.append(imageAssetModel)
            }
        }
       //result  delegate action
        self.mydelegate?.doneActionPickImageList!(result)
        //dismissViewControllerAnimated
        if (self.navigationController != nil) {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
       
    }
    
}





class NTAssetPickViewCell: UICollectionViewCell {
    
    var model:TZAssetModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nt_imageView:UIImageView = UIImageView()
    //video view
    let videoBgView:UIView =  UIView()
    let videoIcon:UIImageView = UIImageView()
    let videoLabel:UILabel = UILabel()
    //photo select btn
    let selectBtn:UIButton = UIButton()
    
    func createUI(){
        self.contentView.addSubview(self.nt_imageView)
        self.nt_imageView.contentMode = .ScaleAspectFill
         self.nt_imageView.clipsToBounds  = true
        //add video view
        self.contentView.addSubview(self.videoBgView)
        let gradientView:UIView = UIView()
       
        self.videoBgView.addSubview(gradientView)
        self.videoBgView.addSubview(self.videoIcon)
        self.videoBgView.addSubview(self.videoLabel)
        self.nt_imageView.translatesAutoresizingMaskIntoConstraints = false
        self.videoBgView.translatesAutoresizingMaskIntoConstraints = false
        self.videoIcon.translatesAutoresizingMaskIntoConstraints = false
        self.videoLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.alpha = 0.5
        gradientView.backgroundColor = UIColor.blackColor()
        self.videoIcon.image = UIImage(named: "VideoSendIcon")
        self.videoBgView.backgroundColor = UIColor.clearColor()
        self.videoLabel.font = UIFont.systemFontOfSize(10)
        self.videoLabel.textColor = UIColor.whiteColor()
        
        //add Constraint
//        let lintNumber:CGFloat = 4.0
//        let spance:CGFloat = 2.0
//        let window_width:CGFloat = UIScreen.mainScreen().bounds.size.width
//        let count_spance:CGFloat = (lintNumber + 1) * spance
//        let width =  (window_width - count_spance)/4.0
          //  self.nt_imageView
        self.contentView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
//        self.nt_imageView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: width))
//        self.nt_imageView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: width))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.nt_imageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))

        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.videoBgView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.videoBgView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.videoBgView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        
        self.videoBgView.addConstraint(NSLayoutConstraint(item:  self.videoBgView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20))
        
        //set video icon
        self.videoBgView.addConstraint(NSLayoutConstraint(item: self.videoIcon, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:   self.videoBgView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 10))
        self.videoBgView.addConstraint(NSLayoutConstraint(item: self.videoIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem:   self.videoBgView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        self.videoIcon.addConstraint(NSLayoutConstraint(item:  self.videoIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 15))
        self.videoIcon.addConstraint(NSLayoutConstraint(item:  self.videoIcon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 15))
        //time label
         self.videoBgView.addConstraint(NSLayoutConstraint(item: self.videoLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem:   self.videoBgView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -10))
        self.videoBgView.addConstraint(NSLayoutConstraint(item: self.videoLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem:    self.videoBgView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        
        //gradientView Constraint
         self.videoBgView.addConstraint(NSLayoutConstraint(item: gradientView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:  self.videoBgView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        self.videoBgView.addConstraint(NSLayoutConstraint(item: gradientView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem:  self.videoBgView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        self.videoBgView.addConstraint(NSLayoutConstraint(item: gradientView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:  self.videoBgView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
         self.videoBgView.addConstraint(NSLayoutConstraint(item: gradientView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:  self.videoBgView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        //add select btn 
        self.contentView.addSubview(self.selectBtn)
        self.selectBtn.setImage(UIImage(named: "photo_original_def"), forState: UIControlState.Normal)
        self.selectBtn.setImage(UIImage(named: "ICON-circle-check-blue"), forState: UIControlState.Selected)
        
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint(item: self.selectBtn, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -5))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.selectBtn, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:  self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -5))
        self.selectBtn.addConstraint(NSLayoutConstraint(item:  self.selectBtn, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 15))
        self.selectBtn.addConstraint(NSLayoutConstraint(item:  self.selectBtn, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 15))
    }
    
    func setData(modelData:TZAssetModel){
         self.model = modelData
        //get image
         TZImageManager.sharemanager().getPhotoWithAsset(self.model!.asset, photoWidth: self.contentView.bounds.width) {[weak self] (image, infoDict, isDegraded) in
            self?.nt_imageView.image = image
         
        }
        //other info
        self.initVideoView()
    }
    
    func initVideoView(){
        //photo
        if self.model?.type == TZAssetModelMediaTypePhoto {
            
           self.videoBgView.hidden = true
           self.selectBtn.hidden = false
           self.selectBtn.selected = (self.model?.isSelected)!
        }else{
            
           self.videoBgView.hidden = false
           self.selectBtn.hidden = true
           self.videoLabel.text = self.model?.timeLength
            
        }
    }
    

    
    //MARK: create createGradientLayerView
    func createGradientLayerView(gradientStartX:CGFloat,gradientEndX:CGFloat,gradientStartY:CGFloat,gradientEndY:CGFloat,gradientStartColor:UIColor,gradientEndColor:UIColor)->UIView{
        let gradientView:UIView = UIView()
        //assumed full view frame for now??
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
        let startx = gradientStartX
        let starty = gradientStartY
        gradientLayer.startPoint = CGPointMake(startx, starty)
        let endx = gradientEndX
        let endy = gradientEndY
        gradientLayer.endPoint = CGPointMake(endx, endy)
        let startcol = gradientStartColor
        let endcol = gradientEndColor
        gradientLayer.colors = [startcol.CGColor, endcol.CGColor]
        gradientLayer.masksToBounds = true
        gradientView.layer.addSublayer(gradientLayer)
        return gradientView

    }
}
