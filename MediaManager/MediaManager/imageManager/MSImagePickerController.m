//
//  MSImagePickerController.m
//  Communicator
//
//  Created by ChinaTeam on 16/6/29.
//  Copyright © 2016 Neatlyco. All rights reserved.
//


#import "MSImagePickerController.h"
#import <objc/runtime.h>

static char attachSelfKey;
@interface MSImagePickerController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
}


@property (nonatomic, readwrite, retain) NSMutableArray *allImages;


@property (nonatomic, readonly, retain) Class PUCollectionView;


@property (nonatomic, readonly, retain) Class PUPhotoView;


@property (retain, nonatomic) UIBarButtonItem *doneButton;


@property (retain, nonatomic) UIBarButtonItem *lastDoneButton;


@property (retain, nonatomic) NSIndexPath     *curIndexPath;


@property (retain, nonatomic) NSMutableArray  *indexPaths;


@property (retain, nonatomic) id              lastDelegate;


@property (nonatomic, readwrite, weak) UICollectionView *collectionView;

@end

@implementation MSImagePickerController

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    self.delegate = self;
    self.maxImageCount = 0;
    self.doneButtonTitle = @"Done";

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self doMagicOperation:@"PUPhotosGridViewController"];
    });
}

- (void) doMagicOperation:(NSString*) className {
    Class targetClass = [NSClassFromString(className) class];
    
    Method m1 = class_getInstanceMethod([self class], @selector(override_collectionView:cellForItemAtIndexPath:));
    
    class_addMethod(targetClass, @selector(override_collectionView:cellForItemAtIndexPath:), method_getImplementation(m1), method_getTypeEncoding(m1));
    
    Method m2 = class_getInstanceMethod(targetClass, @selector(override_collectionView:cellForItemAtIndexPath:));
    Method m3 = class_getInstanceMethod(targetClass, @selector(collectionView:cellForItemAtIndexPath:));
    
    method_exchangeImplementations(m2, m3);
}

- (Class)PUPhotoView {
    return NSClassFromString(@"PUPhotoView");
}

- (Class)PUCollectionView {
    return NSClassFromString(@"PUCollectionView");
}

- (NSMutableArray*)indexPaths {
    if (_indexPaths == nil) {
        _indexPaths = [NSMutableArray new];
    }
    
    return _indexPaths;
}

- (NSArray*)images {
    return _allImages;
}



- (UIBarButtonItem*)doneButton {
    if (_doneButton == nil) {
        
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonTitle
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(done:)];
    }
    
    return _doneButton;
}

- (void)done:(id)sender {
    if ([self.msDelegate respondsToSelector:@selector(imagePickerControllerdidFinish:)]) {
        [self.msDelegate imagePickerControllerdidFinish:self];
    }
}

-(UIView *)getPUCollectionView:(UIView *)v {
    for (UIView *i in v.subviews) {
        if ([i isKindOfClass:self.PUCollectionView]) {
            return i;
        }
    }
    
    return nil;
}

- (UIButton *)getIndicatorButton:(UIView *) v {
    for (id b in v.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            return (UIButton *)b;
        }
    }
    
    return nil;
}


- (void)addIndicatorButton:(UIView *)v {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 15;
    
    [button setImage:[UIImage imageNamed:@"ICON-circle-check-blue"]
            forState:UIControlStateNormal];
    [v addSubview:button];
    
    [button setTranslatesAutoresizingMaskIntoConstraints:false];
    
    NSArray* cs1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(15)]-1-|"
                                                           options:0 metrics:nil
                                                             views:NSDictionaryOfVariableBindings(button)];
    
    NSArray* cs2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(15)]-1-|"
                                                           options:0 metrics:nil
                                                             views:NSDictionaryOfVariableBindings(button)];
    
    [v addConstraints:cs1];
    [v addConstraints:cs2];
    
    [button setSelected:true];
    button.hidden = false;
    
    [v updateConstraintsIfNeeded];
    
    [self updateRightDoneBtnState];
}

   -(void)updateRightDoneBtnState{
       
       if (self.indexPaths.count > 0 ) {
            self.doneButton.enabled = true;
       }else{
           self.doneButton.enabled = false;
       }
   
   }



- (void) removeIndicatorButton:(UIView*)v {
    for (UIView* b in v.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            [b removeFromSuperview];
            [self updateRightDoneBtnState];
            return;
        }
    }
   
}

- (void) addCurrentImage:(UIImage*) image {
    NSInteger index = [self isCurIndexInIndexPaths];
    
    if (index == NSNotFound) {
        [self.allImages addObject:image];
        [self.indexPaths addObject:self.curIndexPath];
        
        UIView* cell = [self.collectionView cellForItemAtIndexPath:self.curIndexPath];
        [self addIndicatorButton:cell];
    }
}

- (void) removeCurrentImage {
    NSInteger index = [self isCurIndexInIndexPaths];
    
    if (index != NSNotFound) {
        [self.allImages removeObjectAtIndex:index];
        [self.indexPaths removeObjectAtIndex:index];
        
        UIView* cell = [self.collectionView cellForItemAtIndexPath:self.curIndexPath];
        [self removeIndicatorButton:cell];
    }
}

- (NSMutableArray*) allImages {
    if (_allImages == nil) {
        _allImages = [NSMutableArray new];
    }

    return _allImages;
}

- (void) clearStatus {
    self.curIndexPath = nil;
    self.lastDelegate = nil;
    self.collectionView = nil;
    [self.allImages removeAllObjects];
    [self.indexPaths removeAllObjects];
}



- (NSInteger) isCurIndexInIndexPaths {
    for (int i = 0; i < self.indexPaths.count; i++) {
        if (((NSIndexPath*)self.indexPaths[i]).row == self.curIndexPath.row &&
            ((NSIndexPath*)self.indexPaths[i]).section == self.curIndexPath.section) {
            return i;
        }
    }
    
    return NSNotFound;
}

#pragma mark - UICollectionViewDataSource method
- (UICollectionViewCell *)override_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    MSImagePickerController* picker = (MSImagePickerController*)objc_getAssociatedObject(self, &attachSelfKey);
    
  
    UICollectionViewCell* cell = [self performSelector:@selector(override_collectionView:cellForItemAtIndexPath:)
                                            withObject:collectionView
                                            withObject:indexPath];
    
    if (picker != nil) {
        picker.curIndexPath = indexPath;
        if ([picker isCurIndexInIndexPaths] != NSNotFound) {
            UIButton* indicatorButton = [picker getIndicatorButton:cell];
            
            if (indicatorButton == nil) {
                [picker addIndicatorButton:cell];
            }
        } else {
            [picker removeIndicatorButton:cell];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    self.curIndexPath = indexPath;
    self.collectionView = collectionView;

    UIView *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIButton *indicatorButton = [self getIndicatorButton:cell];
    
  
    if (indicatorButton == nil) {
        if ([self.images count] >= self.maxImageCount && self.maxImageCount != 0) {
            if ([self.msDelegate respondsToSelector:@selector(imagePickerControllerOverMaxCount:)]) {
                [self.msDelegate imagePickerControllerOverMaxCount:self];
            }

            return NO;
        }
    }
    
   
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%s", sel_getName(_cmd)]);
    if ([self.lastDelegate respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.lastDelegate performSelector:sel withObject:collectionView withObject:indexPath];
#pragma clang diagnostic pop
    }

    return YES;
}



#pragma mark - UINavigationControllerDelegate method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController.navigationController.viewControllers.count == 2 ){
        viewController.navigationItem.rightBarButtonItem = self.doneButton;
        [self.indexPaths removeAllObjects];
        self.doneButton.enabled = false;
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated; {
    UIView *collection = [self getPUCollectionView:viewController.view];
    
 
    self.interactivePopGestureRecognizer.enabled = NO;
    
 
    if (!collection) {
        return;
    }
    
    [self clearStatus];
    

    self.lastDelegate = [collection valueForKey:@"delegate"];
    [collection setValue:self forKey:@"delegate"];
    

    objc_setAssociatedObject(self.lastDelegate, &attachSelfKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    self.lastDoneButton = viewController.navigationItem.rightBarButtonItem;
   
}

#pragma mark - UIImagePikcerControllerDelegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo; {
    NSInteger idx = [self isCurIndexInIndexPaths];
    
    if (idx == NSNotFound) {
        if ([self.msDelegate respondsToSelector:@selector(imagePickerController:shouldSelectImage:)]) {
            if ([self.msDelegate imagePickerController:self shouldSelectImage:image]) {
                [self addCurrentImage:image];
            } else {
                return;
            }
        } else {
            [self addCurrentImage:image];
        }
    } else {
        [self removeCurrentImage];
    }
    
    if (self.images.count == 1) {
        picker.topViewController.navigationItem.rightBarButtonItem = self.doneButton;
    } else if (self.images.count == 0) {
        picker.topViewController.navigationItem.rightBarButtonItem = self.lastDoneButton;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    if ([self.msDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.msDelegate imagePickerControllerDidCancel:self];
    }
}

#pragma mark - dealloc
- (void)dealloc
{
    self.lastDelegate = nil;
}

@end
