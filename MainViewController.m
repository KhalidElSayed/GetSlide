//
//  ViewController.m
//  GetSlide
//
//  Created by amir hayek on 3/7/13.
//  Copyright (c) 2013 amir hayek. All rights reserved.
//

#import "MainViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kServiceUrl [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]
#define kUpdateTimeIntervalInSeconds 1.0f 

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:kUpdateTimeIntervalInSeconds target:self selector:@selector(fetchData) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
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
    
    NSArray* jsonData = [json objectForKey:@"head"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

@end
