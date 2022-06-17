//
//  MovieViewController.m
//  flixter
//
//  Created by Trang Dang on 6/15/22.
//

#import "MovieViewController.h"
#import "myCustomCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MovieViewController() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;


@end

@implementation MovieViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Start the activity indicator
    [self.indicator startAnimating];
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:(UIControlEventValueChanged)];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               [self displayAlertMessage];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               for (id movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               // TODO: Store the movies in a property to use elsewhere
               // the property is put under interface
               // TODO: Reload your table view data
               [self.tableView reloadData];
           }
        [self.refreshControl endRefreshing];
        

        
       }];
    // Stop the activity indicator
    // Hides automatically if "Hides When Stopped" is enabled
    [self.indicator stopAnimating];
    [task resume];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    myCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell" forIndexPath:indexPath];
                          
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    
    NSString *image = movie[@"poster_path"];
    NSString *directory = @"https://image.tmdb.org/t/p/w92/";
    NSString *path = [directory stringByAppendingString:image];
    
    NSURL *url = [NSURL URLWithString:path];
    
    [cell.posterImage setImageWithURL:url];
    
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//Get the new view controller using [segue destinationViewController].
//Pass the selected object to the new view controller.
    NSDictionary *dataToPass = self.movies[self.tableView.indexPathForSelectedRow.row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.moviesDetail = dataToPass;

}

- (void) displayAlertMessage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Poor Connection" message:@"Check your internet connection and try again" preferredStyle:UIAlertControllerStyleAlert];

       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           NSLog(@"OK");
           [self.indicator startAnimating];
           [self fetchMovies];
       }];
       
       [alertController addAction:okAction];
        [self presentViewController:alertController animated: YES completion: nil];
}





@end
