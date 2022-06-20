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

@interface MovieViewController() <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchMovie;
@property (strong, nonatomic) NSArray *filteredMovie;

@end

@implementation MovieViewController

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchMovie.showsCancelButton = YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchMovie.showsCancelButton = NO;
    self.searchMovie.text = @"";
    [self.searchMovie resignFirstResponder];
    self.filteredMovie = self.movies;
    [self.tableView reloadData];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.searchMovie becomeFirstResponder];
    // Do any additional setup after loading the view.
    
    // Start the activity indicator
    [self.indicator startAnimating];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchMovie.delegate = self;
    


    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:(UIControlEventValueChanged)];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchMovies {
    self.filteredMovie = self.movies;
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
               self.filteredMovie = dataDictionary[@"results"];
               for (id movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               // TODO: Store the movies in a property to use elsewhere
               // the property is put under interface
               // TODO: Reload your table view data
               [self.tableView reloadData];
           }
        [self.refreshControl endRefreshing];
        [self.indicator stopAnimating];
        

        
       }];
    // Stop the activity indicator
    // Hides automatically if "Hides When Stopped" is enabled
    
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
                          
    NSDictionary *movie = self.filteredMovie[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    
    NSString *image = movie[@"poster_path"];
    NSString *directory = @"https://image.tmdb.org/t/p/w200/";
    NSString *path = [directory stringByAppendingString:image];
    
    NSURL *url = [NSURL URLWithString:path];
    
//    [cell.posterImage setImageWithURL:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak myCustomCell *weakSelf = cell;
    [weakSelf.posterImage setImageWithURLRequest:request placeholderImage:nil
                                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
                                        // imageResponse will be nil if the image is cached
                                        if (imageResponse) {
                                            NSLog(@"Image was NOT cached, fade in image");
                                            weakSelf.posterImage.alpha = 0.0;
                                            weakSelf.posterImage.image = image;
                                            
                                            //Animate UIImageView back to alpha 1 over 0.3sec
                                            [UIView animateWithDuration:1 animations:^{
                                                weakSelf.posterImage.alpha = 1.0;
                                            }];
                                        }
                                        else {
                                            NSLog(@"Image was cached so just update the image");
                                            weakSelf.posterImage.image = image;
                                        }
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
                                    }];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = UIColor.tintColor;
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovie.count;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//Get the new view controller using [segue destinationViewController].
//Pass the selected object to the new view controller.
    NSDictionary *dataToPass = self.filteredMovie[self.tableView.indexPathForSelectedRow.row];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length!= 0){
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            NSString *movieTitle = evaluatedObject[@"title"];
            return [movieTitle containsString:searchText];
        }];
        self.filteredMovie = [self.movies filteredArrayUsingPredicate:predicate];
        NSLog(@"%@",self.filteredMovie);
    }
    else{
        self.filteredMovie = self.movies;
    }
    [self.tableView reloadData];
}






@end
