//
//  MSImagePickerController.h
//  Communicator
//
//  Created by ChinaTeam on 16/6/29.
//  Copyright © 2016 Neatlyco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSImagePickerControllerDelegate;


@interface MSImagePickerController : UIImagePickerController


@property (nonatomic, readonly, copy) NSArray *images;


@property (nonatomic, readwrite, weak) id<MSImagePickerControllerDelegate> msDelegate;


@property (nonatomic, readwrite, assign) NSInteger maxImageCount;


@property (nonatomic, readwrite, assign) NSString* doneButtonTitle;

@end


@protocol MSImagePickerControllerDelegate<NSObject>

@optional
- (BOOL)imagePickerController:(MSImagePickerController *)picker shouldSelectImage:(UIImage*)image;

- (void)imagePickerControllerdidFinish   :(MSImagePickerController *)picker;
- (void)imagePickerControllerDidCancel   :(MSImagePickerController *)picker;
- (void)imagePickerControllerOverMaxCount:(MSImagePickerController *)picker;

@end
