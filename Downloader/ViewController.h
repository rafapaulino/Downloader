//
//  ViewController.h
//  Downloader
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GerenciadorDownload.h"

@interface ViewController : UIViewController <GerenciadorDownloadDelegate>

@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UILabel *velocidade;
@property (nonatomic, weak) IBOutlet UILabel *progresso;
@property (nonatomic, weak) IBOutlet UILabel *nomeArquivo;

@property (nonatomic, weak) IBOutlet UIButton *iniciarDownload;

@property (nonatomic, weak) IBOutlet UIProgressView *barraProgresso;

@property (nonatomic, weak) IBOutlet UIImageView *foto;


-(IBAction)iniciarDownloadClicado:(id)sender;


@end
