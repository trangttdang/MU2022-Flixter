//
//  TrailerViewController.m
//  flixter
//
//  Created by Trang Dang on 6/19/22.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webkitView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchTrailer];
    NSLog(@"%@", self.movieID);
    NSLog(@"%@", [NSString stringWithFormat:@"%@", self.movieID]);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//Get the API: https://api.themoviedb.org/3/movie/{movie_id}/videos?api_key=<<api_key>>&language=en-US
- (void)fetchTrailer {
    self.movieID = [NSString stringWithFormat:@"%@", self.movieID];
    NSString *link = @"https://api.themoviedb.org/3/movie/";
    NSString *api = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *queryLink = [link stringByAppendingString:[self.movieID stringByAppendingString:api]];
    NSURL *url = [NSURL URLWithString:queryLink];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
            NSDictionary *videos = dataDictionary[@"results"];
            NSString *youtubeID;
            //Get Youtube Trailer ID
            for (id video in videos) {
                if([[NSString stringWithFormat:@"%@", video[@"type"]] isEqualToString:@"Trailer"]){
                    youtubeID = [NSString stringWithFormat:@"%@", video[@"key"]];
                    NSLog(@"%@", youtubeID);
                    break;
                }
                
            }
            
            //Get Youtube link
            NSString *youtubePath = @"https://www.youtube.com/watch?v=";
            NSString *youtubeUrl = [youtubePath stringByAppendingString:youtubeID];
            NSLog(@"%@", youtubeUrl);
            
            // Convert the url String to a NSURL object.
            NSURL *url = [NSURL URLWithString:youtubeUrl];
            
            // Place the URL in a URL Request.
            NSURLRequest *requestYoutube = [NSURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:10.0];
            // Load Request into WebView.
            [self.webkitView loadRequest:requestYoutube];
        }
        
    }];
    [task resume];
}

@end
