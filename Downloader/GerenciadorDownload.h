//
//  GerenciadorDownload.h
//  Downloader
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//delegate para comunicacao entre esta classe e a viewcontroller
@protocol GerenciadorDownloadDelegate <NSObject>

@required
-(void)recebiTotalBytes:(float)totalBytes;
-(void)estouRecebendoDados:(float)quantidadeBytesRecebidos;
-(void)recebiNomeArquivo:(NSString*)nome;

-(void)dadosChegaramComErro:(NSString*)descricaoErro;
-(void)recebiArquivoCompleto:(NSData*)dados;

-(void)recebiVelocidadeAtutal:(NSString*)velocidade;


@end

@interface GerenciadorDownload : NSObject <NSURLConnectionDataDelegate>

-(void)iniciarDownload;
-(void)cancelarDownload;
-(NSString*)ajustarUnidade:(float)valor;

//construtor - todo um construtor devolve um id
-(id)initWithURL:(NSString*)path delegate:(id)delegate;

//criando a property do delegate
@property (nonatomic, weak) id<GerenciadorDownloadDelegate> delegate;

@end
