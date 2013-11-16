//
//  ViewController.m
//  ccPDA
//
//  Created by ccnyou on 13-11-8.
//  Copyright (c) 2013年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "ZipArchive.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#ifndef LOG_TO_FILE
#define NSLog(s, ...) [self log:[NSString stringWithFormat:(s), ##__VA_ARGS__]]
#endif


@interface ViewController () <UITextViewDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) FMDatabase* dbConn;
@property (nonatomic, strong) NSString* dbPath;
@property (nonatomic, strong) UIDocumentInteractionController* controller;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.textView.text = @"";
    [self log:@"viewDidLoad"];
    
    NSURL* appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    if (_dbConn == nil) {
        NSString* dbPath = [[appUrl path] stringByAppendingPathComponent:@"ccPDA.db"];
        _dbPath = dbPath;
        NSLog(@"%s line:%d db path = %@", __FUNCTION__, __LINE__, dbPath);
        _dbConn = [FMDatabase databaseWithPath:dbPath];
        if ([_dbConn open] == NO) {
            NSLog(@"%s line:%d %@", __FUNCTION__, __LINE__, @"数据库未能创建/打开");
            _dbConn = nil;
        }
    }
    
#ifdef LOG_TO_FILE
    NSString* logPath = [[appUrl path] stringByAppendingPathComponent:@"log.txt"];
    freopen([logPath UTF8String], "a+", stdout);
    freopen([logPath UTF8String], "a+", stderr);
#endif
    
    NSString* sql =
    @"CREATE TABLE IF NOT EXISTS Persons("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "name text,"
    "image blob"
    ");";
    
    if (![_dbConn executeUpdate:sql]) {
        NSLog(@"%s line:%d 创建表失败:%@", __FUNCTION__, __LINE__, [_dbConn lastErrorMessage]);
    }
    
    sql =
    @"CREATE TABLE IF NOT EXISTS Phones("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "person_id INTEGER,"
    "label text,"
    "number text"
    ");";
    if (![_dbConn executeUpdate:sql]) {
        NSLog(@"%s line:%d 创建表失败:%@", __FUNCTION__, __LINE__, [_dbConn lastErrorMessage]);
    }
    
    sql =
    @"CREATE TABLE IF NOT EXISTS Groups("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "name text,"
    "parent_id text"
    ");";
    if (![_dbConn executeUpdate:sql]) {
        NSLog(@"%s line:%d 创建表失败:%@", __FUNCTION__, __LINE__, [_dbConn lastErrorMessage]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)run:(id)sender
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
    [self readContact];
}

- (void)CreateZip
{
    NSString* zipPath = [self.dbPath stringByAppendingString:@".zip"];
    ZipArchive* za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipPath];
    [za addFileToZip:self.dbPath newname:@"database.db"];
    BOOL success = [za CloseZipFile2];
    NSLog(@"Zipped file with result %d",success);
}


- (IBAction)onOpen:(id)sender
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.zip", self.dbPath]];
    NSLog(@"%s line:%d url = %@", __FUNCTION__, __LINE__, url);

    UIDocumentInteractionController* controller = [UIDocumentInteractionController interactionControllerWithURL:url];
    controller.delegate = self;
    controller.UTI = @"com.pkware.zip-archive";
    [controller presentOpenInMenuFromRect:CGRectMake(760, 20, 100, 100) inView:self.view animated:YES];
    _controller = controller;
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application
{
    NSLog(@"%s line:%d app = %@", __FUNCTION__, __LINE__, application);
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

- (IBAction)onClear:(id)sender
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
    self.textView.text = @"";
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
    return YES;
}

- (void)log:(id)obj
{
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\r\n", obj];
}


- (void)readContact
{
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
    //定义通讯录名字为addressbook
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                             });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //将通讯录中的信息用数组方式读出
    CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    long count = ABAddressBookGetGroupCount(addressBook);
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    for (int i = 0; i < count; i++) {
        ABRecordRef group = CFArrayGetValueAtIndex(groups, i);
        NSString* groupName = (__bridge NSString *)ABRecordCopyCompositeName(group);
        
        NSLog(@"%s line:%d group = %@", __FUNCTION__, __LINE__, groupName);
        NSString* sql = [[NSString alloc] initWithFormat:@"insert or replace into Groups values(null, '%@', 0)", groupName];
        BOOL retCode = [self.dbConn executeUpdate:sql];
        if (retCode == NO) {
            NSLog(@"%s line:%d error, msg = %@", __FUNCTION__, __LINE__, [self.dbConn lastError]);
        }
    }
    
    //获取通讯录中联系人
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSLog(@"%s line:%d nPeople = %ld", __FUNCTION__, __LINE__, nPeople);
    for (int i = 0; i < nPeople && i < 5; i++)
    {
        
        IphoneContact * iphoneContact = [[IphoneContact alloc] init];
        
        ABRecordRef person = CFArrayGetValueAtIndex(contacts, i);//取出某一个人的信息
      
        
        //读取联系人姓名属性
        if (ABRecordCopyValue(person, kABPersonLastNameProperty)&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))== nil) {
            iphoneContact.contactName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSLog(@"%s line:%d contactName = %@", __FUNCTION__, __LINE__, iphoneContact.contactName);
        }else if (ABRecordCopyValue(person, kABPersonLastNameProperty) == nil&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))){
            iphoneContact.contactName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSLog(@"%s line:%d contactName = %@", __FUNCTION__, __LINE__, iphoneContact.contactName);
        }else if (ABRecordCopyValue(person, kABPersonLastNameProperty)&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))){
            
            NSString *first =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *last = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            iphoneContact.contactName = [NSString stringWithFormat:@"%@%@",last,first];
            NSLog(@"%s line:%d contactName = %@", __FUNCTION__, __LINE__, iphoneContact.contactName);
        }
        
        NSData *imageData = [[NSData alloc] init];
        //读取照片信息
        imageData = (__bridge NSData *)ABPersonCopyImageData(person);
        UIImage *myImage = [UIImage imageWithData:imageData];
        NSLog(@"%s line:%d image = %@", __FUNCTION__, __LINE__, myImage);
        
        NSString* sql = [[NSString alloc] initWithFormat:@"insert or replace into Persons values(null, '%@', ?)", iphoneContact.contactName];
        BOOL retCode = [self.dbConn executeUpdate:sql, imageData];
        if (retCode == NO) {
            NSLog(@"%s line:%d error, msg = %@", __FUNCTION__, __LINE__, [self.dbConn lastError]);
        }
        long long persionId = [self.dbConn lastInsertRowId];
 
        
        //读取电话信息，和emial类似，也分为工作电话，家庭电话，工作传真，家庭传真。。。。
        
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        count = ABMultiValueGetCount(phone);
        if ((phone != nil) && count > 0) {
            
            for (int m = 0; m < count; m++) {
                NSString* aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, m);
                
                CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(phone, m);
                CFStringRef readableLabel = ABAddressBookCopyLocalizedLabel(labelRef);
                
                NSString* aLabel = (__bridge NSString *)readableLabel;
                NSLog(@"%s line:%d Label = %@, Phone = %@", __FUNCTION__, __LINE__, aLabel, aPhone);
                
                sql = [[NSString alloc] initWithFormat:@"insert or replace into Phones values(null, %lld, '%@', '%@')", persionId, aLabel, aPhone];
                BOOL retCode = [self.dbConn executeUpdate:sql];
                if (retCode == NO) {
                    NSLog(@"%s line:%d error, msg = %@", __FUNCTION__, __LINE__, [self.dbConn lastError]);
                }
            }
        }
       
    }
}

- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text, str];
    NSRange range;
    range.location = [self.textView.text length] - 1;
    range.length = 0;
    [self.textView scrollRangeToVisible:range];
    
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    [pipeReadHandle readInBackgroundAndNotify];
}

@end
