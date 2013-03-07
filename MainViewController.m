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

#define kCellInset 20

@interface MainViewController ()
{
    NSMutableArray* _slidesArray;
    NSString* _lastImageUrlString;
    NSInteger _firstSlideId;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _slidesArray = [[NSMutableArray alloc] init];

    
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
    
    if (responseData != nil) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSString* imageUrlString = [json objectForKey:@"url"];
        NSString* slideIdString = [json objectForKey:@"currentSlide"];
        NSInteger slideId = [slideIdString intValue];
        if ([_slidesArray count] == 0)
        {
            _firstSlideId = slideId;
        }
        
        slideId = slideId - _firstSlideId;
        
        if (slideId < [_slidesArray count]) {
            //got back to existing slide
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:slideId inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }else{
            //got a new slide
           
            if ([imageUrlString compare:_lastImageUrlString] == NSOrderedSame) {
                NSLog(@"image didnt change");
                
            }else{
                _lastImageUrlString = imageUrlString;
                UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
                
                Boolean sameImage = YES;
                //if ([_slidesArray count] > 0) {
                //    sameImage = [self Compare:img secondImage:_slidesArray[0]];
                //}
                
                if (sameImage) {
                    [_slidesArray addObject:img];
                    [_collectionView reloadData];
                    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_slidesArray.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                    NSLog(@"image changed");
                }
            }

        }
    }else{
        NSLog(@"server not reached");
    }
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
    
    [cell.slideCellImageView setImage:_slidesArray[indexPath.row]];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize cellSize;
    cellSize.height = self.view.frame.size.height - 2 * kCellInset;
    cellSize.width = self.view.frame.size.width - 2 * kCellInset;
    
    return cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCellInset, kCellInset, kCellInset, kCellInset);
}

#pragma mark - image compare

-(NSMutableArray*)getImageBinary:(UIImage*)ImageToCompare
{
    int i = 0;
    
    int step =4;
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(ImageToCompare.CGImage);
    size_t pixelsHigh = CGImageGetHeight(ImageToCompare.CGImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    NSMutableArray *firstImagearray=[[NSMutableArray alloc]init];
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return nil;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    //bitmapData = malloc( bitmapByteCount );
    //  if (bitmapData == NULL)
    //  {
    //      fprintf (stderr, "Memory not allocated!");
    //      CGColorSpaceRelease( colorSpace );
    //      return NULL;
    //  }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (NULL,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits        per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Context not created!");
    }
    
    CGRect rect = {{0,0},{pixelsWide, pixelsHigh}};
    //
    //        // Draw the image to the bitmap context. Once we draw, the memory
    //        // allocated for the context for rendering will then contain the
    //        // raw image data in the specified color space.
    CGContextDrawImage(context, rect, ImageToCompare.CGImage);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    /////**********
    size_t _width = CGImageGetWidth(ImageToCompare.CGImage);
    size_t _height = CGImageGetHeight(ImageToCompare.CGImage);
    
    unsigned char* data = CGBitmapContextGetData (context);
    if (data != NULL) {
        int max = _width * _height * 4;
        
        for (i = 0; i < max; i+=step)
        {
            [firstImagearray addObject:[NSNumber numberWithInt:data[i + 0]]];
            [firstImagearray addObject:[NSNumber numberWithInt:data[i + 1]]];
            [firstImagearray addObject:[NSNumber numberWithInt:data[i + 2]]];
            [firstImagearray addObject:[NSNumber numberWithInt:data[i + 3]]];        }
    }
    
    if (context == NULL)
        // error creating context
        return nil;
    
    
    //if (data) { free(data); }
    if (context) {
        CGContextRelease(context);
        
    }
    return firstImagearray;
}
-(Boolean)Compare:(UIImage*)ImageToCompare secondImage:(UIImage*)secondImage
{
//    ImageToCompare=[ImageToCompare  scaleToSize:CGSizeMake(self.appdelegate.ScreenWidth,self.appdelegate.ScreenHeigth)];
//    secondImage=[secondImage scaleToSize:CGSizeMake(self.appdelegate.ScreenWidth, self.appdelegate.ScreenHeigth)];
    
    NSArray *first=[[NSArray alloc] initWithArray:(NSArray *)[self    getImageBinary:ImageToCompare]];
    NSArray *second=[[NSArray alloc] initWithArray:(NSArray *)[self getImageBinary:secondImage]];
    
    for (int x=0; x<first.count; x++)
    {
        if ([((NSNumber*)[first objectAtIndex:x]) intValue] ==[((NSNumber*)[second objectAtIndex:x]) intValue])
        {
            
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

@end
