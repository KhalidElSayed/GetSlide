//
//  ViewController.h
//  GetSlide
//
//  Created by amir hayek on 3/7/13.
//  Copyright (c) 2013 amir hayek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView *_collectionView;
    
}

- (void)fetchedData:(NSData *)responseData;
- (void)fetchData;

@end