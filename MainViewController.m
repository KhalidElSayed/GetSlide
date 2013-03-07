//
//  ViewController.m
//  GetSlide
//
//  Created by amir hayek on 3/7/13.
//  Copyright (c) 2013 amir hayek. All rights reserved.
//

#import "MainViewController.h"
#import "SlideCell.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kServiceUrl [NSURL URLWithString:@"http://ec2-23-20-10-231.compute-1.amazonaws.com:8080/getslide/presentation/1/latest.htm"]
#define kUpdateTimeIntervalInSeconds 1.0f 

#define kCellInset 10

@interface MainViewController ()
{
    NSMutableArray* _slidesArray;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _slidesArray = [[NSMutableArray alloc] init];

    
    //NSTimer* timer = [NSTimer timerWithTimeInterval:kUpdateTimeIntervalInSeconds target:self selector:@selector(fetchData) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self fetchData];
}

- (void)fetchData
{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kServiceUrl];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
        
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData 
                          options:kNilOptions
                          error:&error];
    
    NSString* imageUrlString = [json objectForKey:@"url"];
        
    UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
    
    [_slidesArray addObject:img];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_slidesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SlideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell.slideCellImageView setImage:_slidesArray[indexPath.row]];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize cellSize;
    cellSize.height = self.view.frame.size.height - kCellInset;
    cellSize.width = self.view.frame.size.width - kCellInset;
    
    return cellSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCellInset, kCellInset, kCellInset, kCellInset);
}
@end
