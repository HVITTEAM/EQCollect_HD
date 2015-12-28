//
//  CommonRemoteHelper.m
//  GPSNavDemo
//


#import "CommonRemoteHelper.h"
#import "MultipartFormObject.h"

@interface CommonRemoteHelper()

@end

@implementation CommonRemoteHelper

static NSOperationQueue * _queue;


+ (void)setCompletionBlockWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *dict, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURL *urlStr = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
        success(dict,responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
    
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
    }
    [_queue addOperation:operation];
}

//  = HTTP请求格式 =
//  ------------------------------
//  * 请求方法 (GET、POST等)       *
//  * 请求头   (HttpHeaderFields) *
//  * 请求正文 (数据)              *
//  ------------------------------
+(AFHTTPRequestOperation *)RemoteWithUrl:(NSString *)url  parameters:(id)parameters  type:(CommonRemoteType)type
             success:(void (^)(id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    
    AFHTTPRequestOperation *op;
    
    if (type == CommonRemoteTypePost){
       op = [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            success(responseObject);
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            failure(operation,error);
        }];
    }else if (type == CommonRemoteTypeGet){
        
      op = [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            success(responseObject);
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           failure(operation,error);
        }];
    }
    
    return op;
}


+(AFHTTPRequestOperation *)remoteImageWithUrl:(NSString *)url parameters:(id)parameters formObjects:(NSMutableArray *)formObjects success:(void (^)(id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    
    AFHTTPRequestOperation *op;
    
    op = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (MultipartFormObject *fileObject in formObjects) {
            [formData appendPartWithFileData:fileObject.fileData name:fileObject.name fileName:fileObject.fileName mimeType:fileObject.mimeType];
        }
        
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(operation,error);
    }];
    return op;
}

@end
