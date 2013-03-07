//
//  ViewController.h
//  GetSlide
//
//  Created by amir hayek on 3/7/13.
//  Copyright (c) 2013 amir hayek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
{
    __weak IBOutlet UICollectionView *_collectionView;
    
    IBOutlet UIActivityIndicatorView *_activityIndicator;
    IBOutlet UIButton *_goToCurrentButton;
    IBOutlet UIImageView *doneImage;
}

- (void)fetchedData:(NSData *)responseData;
- (void)fetchData;

- (IBAction)goToCurrentClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;

@end
