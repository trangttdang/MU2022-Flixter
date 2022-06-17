//
//  GridViewController.m
//  flixter
//
//  Created by Trang Dang on 6/16/22.
//

#import "GridViewController.h"
#import "MovieViewGridCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface GridViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *MoviesCollectionView;
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.MoviesCollectionView.dataSource = self;
    self.MoviesCollectionView.delegate = self;
    [self fetchMovies];
}

- (void)viewDidLayoutSubviews {
   [super viewDidLayoutSubviews];

    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);
               self.movies = dataDictionary[@"results"];
               [self.MoviesCollectionView reloadData];
           }
       }];
    [task resume];
}


//pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
////Get the new view controller using [segue destinationViewController].
////Pass the selected object to the new view controller.
//}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    MovieViewGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieViewGridCell" forIndexPath:indexPath];
                          
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *image = movie[@"poster_path"];
    NSString *directory = @"https://image.tmdb.org/t/p/w92/";
    NSString *path = [directory stringByAppendingString:image];
//    NSLog(@"%@", path);
    NSURL *url = [NSURL URLWithString:path];
    [cell.posterView setImageWithURL:url];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    int totalwidth = self.MoviesCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 4;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(dimensions, dimensions*1.2);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//Get the new view controller using [segue destinationViewController].
//Pass the selected object to the new view controller.
    NSDictionary *dataToPass = self.movies[self.MoviesCollectionView.indexPathsForSelectedItems[0].row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.moviesDetail = dataToPass;

}


@end
