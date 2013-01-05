//
//  ViewController.m
//  Downloader
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    GerenciadorDownload *gerenciador;
    
    float totalByteArquivo;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark iniciar download clicado

-(IBAction)iniciarDownloadClicado:(id)sender
{
    //nicia o download
    if (gerenciador == nil)
    {
       //NSString *enderecoImagem = @"http://www.downloadswallpapers.com/wallpapers/2012/maio/medio/techart-gt-porsche-wallpaper-6872.jpg";
        
        NSString *enderecoImagem = @"http://info.sortere.no/wp-content/filer/2009/07/earth-huge.png";
        
        gerenciador = [[GerenciadorDownload alloc] initWithURL:enderecoImagem delegate:self];
        
        _status.text = @"Baixando..";
        
        [_iniciarDownload setTitle:@"Cancelar download" forState:UIControlStateNormal];
        
        [gerenciador iniciarDownload];
    }
    //estava acontecendo um download e agora eu quero cancelar o download
    else
    {
        _status.text = @"Download cancelado";
        
        _barraProgresso.progress = 0;
        
        totalByteArquivo = 0;
        
        [_iniciarDownload setTitle:@"Iniciar download" forState:UIControlStateNormal];
        
        [gerenciador cancelarDownload];
        gerenciador = nil;
    }
}


#pragma mark Metodos do gerenciador de download

-(void)recebiTotalBytes:(float)totalBytes
{
    totalByteArquivo = totalBytes;
}

-(void)estouRecebendoDados:(float)quantidadeBytesRecebidos
{
    //atualizar a barra de progresso
    _barraProgresso.progress = quantidadeBytesRecebidos/totalByteArquivo;
    
    //ajustando as unidades float para uma string na ordem de grandeza correta
    NSString *bytesRecebidos = [gerenciador ajustarUnidade:quantidadeBytesRecebidos];
    NSString *totalBytes = [gerenciador ajustarUnidade:totalByteArquivo];
    
    
    _progresso.text = [NSString stringWithFormat:@"%@ / %@", bytesRecebidos, totalBytes];
}

-(void)recebiNomeArquivo:(NSString*)nome
{
    _nomeArquivo.text = nome;
}

-(void)dadosChegaramComErro:(NSString*)descricaoErro
{
    _status.text = descricaoErro;
}

-(void)recebiArquivoCompleto:(NSData*)dados
{
    _foto.image = [UIImage imageWithData:dados];
    
    _status.text = @"Download concluído";
    
    [_iniciarDownload setTitle:@"Iniciar download" forState:UIControlStateNormal];
    
    _velocidade.text = @"0 bytes/s";
    
    gerenciador = nil;
}

-(void)recebiVelocidadeAtutal:(NSString*)velocidade
{
   _velocidade.text = velocidade;
}

@end
