//
//  DetailsViewController.m
//  flixter
//
//  Created by Trang Dang on 6/16/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
//@property (weak, nonatomic) IBOutlet UIImageView *mainPoster;
@property (weak, nonatomic) IBOutlet UIImageView *subPoster;
@property (weak, nonatomic) IBOutlet UILabel *detailLable;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *ratingLable;
@property (weak, nonatomic) IBOutlet UIImageView *mainPoster;
@property (weak, nonatomic) IBOutlet UIImageView *BiggerPoster;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Assign values to properties in Movie Detail
    self.detailLable.text = self.moviesDetail[@"overview"];
    self.titleLable.text = [NSString stringWithFormat:@"%@", self.moviesDetail[@"title"]];
    NSString *rating = [NSString stringWithFormat:@"%@", self.moviesDetail[@"vote_average"]];
    self.ratingLable.text = [rating stringByAppendingString:@"/10"];
    
    //Process set image with url for main, sub and bigger poster
    NSString *image = self.moviesDetail[@"poster_path"];
    NSString *backdrop_image = self.moviesDetail[@"backdrop_path"];
    
    NSString *directory = @"https://image.tmdb.org/t/p/w200/"; //low-resolution image
    NSString *directory_large = @"https://image.tmdb.org/t/p/w500/"; //high-resolution image
    
    NSString *path = [directory_large stringByAppendingString:image]; //sub poster & bigger poster's path
    NSString *backdrop_pathSmall = [directory stringByAppendingString:backdrop_image]; //main poster's path (low-resolution image)
    NSString *backdrop_pathLarge = [directory_large stringByAppendingString:backdrop_image]; //main poster's path (high-resolution image)
    
    NSURL *url = [NSURL URLWithString:path]; //sub poster &bigger poster's url
    NSURL *backdrop_url = [NSURL URLWithString:backdrop_pathSmall]; //main poster's url (low-resolution image)
    NSURL *backdrop_urlLarge = [NSURL URLWithString:backdrop_pathLarge]; //main poster's url (high-resolution image)
    
    
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:backdrop_url];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:backdrop_urlLarge];
    
    [self.subPoster setImageWithURL:url];
    [self.BiggerPoster setImageWithURL:url];
    
    //User do not tap on sub poster to see bigger poster
    self.BiggerPoster.hidden = YES;
    
    //Tap Gesture Recognizer for viewing movie trailer and see larger poster
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    // Optionally set the number of required taps, e.g., 2 for a double click
    tapGestureRecognizer.numberOfTapsRequired = 1;
    //Enable user interaction
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    //For main poster, load the low resolution image first and then switch to the high resolution image when complete
    __weak DetailsViewController *weakSelf = self;
    
    [self.mainPoster setImageWithURLRequest:requestSmall
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
        
        // smallImageResponse will be nil if the smallImage is already available
        // in cache (might want to do something smarter in that case).
        weakSelf.mainPoster.alpha = 0.0;
        weakSelf.mainPoster.image = smallImage;
        
        [UIView animateWithDuration:0.7
                         animations:^{
            
            weakSelf.mainPoster.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            // The AFNetworking ImageView Category only allows one request to be sent at a time
            // per ImageView. This code must be in the completion block.
            [weakSelf.mainPoster setImageWithURLRequest:requestLarge
                                       placeholderImage:smallImage
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                weakSelf.mainPoster.image = largeImage;
            }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                // do something for the failure condition of the large image request
                // possibly setting the ImageView's image to a default image
            }];
        }];
    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // do something for the failure condition
        // possibly try to get the large image
    }];
}

//Action to see movie trailer or see larger poster
- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    CGPoint MainPosterLocation = [sender locationInView:self.mainPoster];
    CGPoint SubPosterLocation = [sender locationInView:self.subPoster];
    if(CGRectContainsPoint(self.mainPoster.frame, MainPosterLocation)){
        [self performSegueWithIdentifier:@"seeTrailer" sender:nil];
    } else if (CGRectContainsPoint(self.subPoster.frame, SubPosterLocation)){
        self.BiggerPoster.hidden = NO;
    } else {
        [self viewDidLoad];
    }
}

#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Get the new view controller using [segue destinationViewController].
    //Pass the selected object to the new view controller.
    NSString *dataToPass = self.moviesDetail[@"id"];
    TrailerViewController *detailVC = [segue destinationViewController];
    detailVC.movieID = dataToPass;
}

@end
