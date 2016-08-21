//
//  NTAssetViewController.swift
//  Communicator
//
//  Created by ChinaTeam on 16/7/22.
//  Copyright © 2016年 Neatlyco. All rights reserved.
//

import UIKit

@objc protocol NTAssetViewControllerDelegate{
    //get pick result image or video
    optional func doneActionPickImageList(images:Array<NTImageAssetModel>)
//    optional func doneActionPickOriginalImage(originalImage:UIImage)
}


class NTAssetViewController: UITableViewController {

    var  timer:NSTimer?
    
    var albumArr:NSMutableArray =  NSMutableArray()
    
    var cancelBtn:UIBarButtonItem?
    
    //delegate
    weak var mydelegate:NTAssetViewControllerDelegate?
    
    override func viewDidLoad() {
       super.viewDidLoad()
      
       self.title = "Albums"
       self.tableView.separatorStyle = .None
       self.tableView.rowHeight = UITableViewAutomaticDimension
       self.tableView.estimatedRowHeight = 70
        
        self.cancelBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(NTAssetViewController.cancelAction))
        self.navigationItem.rightBarButtonItem = cancelBtn!
    }
    
    func cancelAction(){
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(NTAssetViewController.loadImage), userInfo: nil, repeats: true)
    
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
         self.timer?.invalidate()
         self.timer = nil
    }
    
   
    
    func loadImage(){
        let isauto = TZImageManager.sharemanager().authorizationStatusAuthorized()
        if isauto {
            //load data
            self.loadData()
        }
    }
    
    
  
    func loadData(){
        //load image list
        TZImageManager.sharemanager().getAllAlbums(true, allowPickingImage: true) { [weak self](albumModels) in
            self?.albumArr = NSMutableArray(array: albumModels)
            self?.tableView!.reloadData()
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//tableview delegate
    
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return   self.albumArr.count
    }
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlbumTableViewCell? = tableView.dequeueReusableCellWithIdentifier("myalbumCell") as? AlbumTableViewCell
        if cell == nil {
            cell = AlbumTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "myalbumCell")
        }
        //set data
        let model:TZAlbumModel = self.albumArr.objectAtIndex(indexPath.row) as! TZAlbumModel
        cell?.setData(model)
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        let assetPick:NTAssetPickViewController =  NTAssetPickViewController()
            //set data
        assetPick.model = self.albumArr.objectAtIndex(indexPath.row) as? TZAlbumModel
        assetPick.mydelegate = self.mydelegate
        self.navigationController?.pushViewController(assetPick, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}


class AlbumTableViewCell: UITableViewCell {
    
  
    let nt_imageView = UIImageView()
    let nt_titleLabel = UILabel()
    let nt_subTitleLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.accessoryType =  .DisclosureIndicator
//      self.selectionStyle = .None
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func createUI(){
        self.contentView.addSubview(nt_imageView)
        self.contentView.addSubview(nt_titleLabel)
        self.contentView.addSubview(nt_subTitleLabel)
        nt_imageView.contentMode = .ScaleAspectFill
        nt_imageView.clipsToBounds = true
        nt_imageView.translatesAutoresizingMaskIntoConstraints = false
        nt_titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nt_subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nt_subTitleLabel.font = UIFont.systemFontOfSize(10)
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:   self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 15))
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:   self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10))
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_imageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:   self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -10))
        self.nt_imageView.addConstraint(NSLayoutConstraint(item: nt_imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem:   nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 70))
        self.nt_imageView.addConstraint(NSLayoutConstraint(item: nt_imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem:   nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 70))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_titleLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:   nt_imageView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 15))
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:   self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 25))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_subTitleLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem:   nt_imageView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 15))
        self.contentView.addConstraint(NSLayoutConstraint(item: nt_subTitleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:   self.nt_titleLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10))
    }
    
    
    func setData( model:TZAlbumModel){
        self.nt_titleLabel.text = model.name
        self.nt_subTitleLabel.text = "\(model.count)"
        TZImageManager.sharemanager().getPostImageWithAlbumModel(model) { (image) in
            self.nt_imageView.image = image
        }
    }
    

}



