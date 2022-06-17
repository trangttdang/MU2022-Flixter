//
//  DetailsViewController.m
//  flixter
//
//  Created by Trang Dang on 6/16/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainPoster;
@property (weak, nonatomic) IBOutlet UIImageView *subPoster;
@property (weak, nonatomic) IBOutlet UILabel *detailLable;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *ratingLable;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailLable.text = self.moviesDetail[@"overview"];
    self.titleLable.text = [NSString stringWithFormat:@"%@", self.moviesDetail[@"title"]];
    
    self.ratingLable.text = [NSString stringWithFormat:@"%@", self.moviesDetail[@"vote_average"]];
    
    NSString *image = self.moviesDetail[@"poster_path"];
    NSString *directory = @"https://image.tmdb.org/t/p/w92/";
    NSString *path = [directory stringByAppendingString:image];
    
    NSURL *url = [NSURL URLWithString:path];
    
    
    NSString *backdrop_image = self.moviesDetail[@"backdrop_path"];
    NSString *backdrop_path = [directory stringByAppendingString:backdrop_image];
    NSURL *backdrop_url = [NSURL URLWithString:backdrop_path];
    [self.mainPoster setImageWithURL:backdrop_url];
    [self.subPoster setImageWithURL:url];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
