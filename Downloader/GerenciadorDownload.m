//
//  GerenciadorDownload.m
//  Downloader
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "GerenciadorDownload.h"

@interface GerenciadorDownload ()
{
    NSURLConnection *conexao;
    
    NSMutableData *dadosRecebidos;
    
    NSString *urlArquivo; //url remota
    NSString *pathArquivo; //url local
    
    int tempoDownloadAtual;
    
    float totalDadosRecebidosAtual;
    float totalDadosRecebidosPassado;
    
    NSTimer *timerVelocidade;
    
    //objeto capaz de abrir um arquivo e salvar dados parcialmente durante o download
    NSFileHandle *manipuladorArquivo;
}

@end

@implementation GerenciadorDownload

#pragma mark Metodos do Gerenciador Download

//construtor - todo um construtor devolve um id
-(id)initWithURL:(NSString*)path delegate:(id)delegate
{
    self = [super init];
    
    if (self != nil)
    {
        //customizacao da inicializacao
        _delegate = delegate;
        
        //guardando o local de origem da foto
        urlArquivo = path;
        
        totalDadosRecebidosPassado = 0;
    }
    
    return self;
}

-(void)iniciarDownload
{
    //criando uma url a partir do endereco passado no construtor init
    NSURL *url = [NSURL URLWithString:urlArquivo];
    
    //montar uma requisicao
    NSURLRequest *requisicao = [NSURLRequest requestWithURL:url];
    
    //abrir uma conexao com o servidor
    conexao = [NSURLConnection connectionWithRequest:requisicao delegate:self];
    
}

-(void)cancelarDownload
{
    [_delegate recebiVelocidadeAtutal:@"0 bytes/s"];
    [conexao cancel];
    [manipuladorArquivo closeFile];
    [timerVelocidade invalidate];
    totalDadosRecebidosAtual = 0;
    tempoDownloadAtual = 0;
}

-(NSString*)ajustarUnidade:(float)valor
{
    int ordem = 0; //ordem de grandeza = 0
    
    //divisoes sucessivas para descobrir a ordem de grandeza
    while (valor > 1023 && ordem < 3)
    {
        valor = valor/1024;
        ordem++;
    }
    
    switch (ordem)
    {
        case 0:
            //bytes
            return [NSString stringWithFormat:@"%.2f bytes", valor];
            
            break;
            
        case 1:
            //kBytes
            return [NSString stringWithFormat:@"%.2f KB", valor];
            break;
        
        case 2:
            //MBytes
            return [NSString stringWithFormat:@"%.2f MB", valor];
            break;
        
        case 3:
            //GBytes
            return [NSString stringWithFormat:@"%.2f GB", valor];
            break;
        
        default:
            //GBytes
            return [NSString stringWithFormat:@"%.2f GB", valor];
            break;
    }
}

-(void)atualizarVelocidade
{
    tempoDownloadAtual++;
    
    NSString *valorBytesFormatado = [self ajustarUnidade:(totalDadosRecebidosAtual - totalDadosRecebidosPassado)/tempoDownloadAtual];
    
    NSString *velocidadeSegundos = [NSString stringWithFormat:@"%@/s", valorBytesFormatado];
    
    totalDadosRecebidosPassado = totalDadosRecebidosAtual;
    
    [_delegate recebiVelocidadeAtutal:velocidadeSegundos];
}

#pragma mark NSURLConnection Delegate

//recebendo a primeira resposta
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //inicializando a variavel onde vou guardar todos os pacotes recebidos
    dadosRecebidos = [[NSMutableData alloc] init];
    
    totalDadosRecebidosAtual = 0;
    tempoDownloadAtual = 0;
    
    //verifico se tem algum arquivo a ser baixado
    if (response.expectedContentLength > 0)
    {
        //total de bytes a serem baixados
        //criei um nsnumber do tipo long long e fiz a conversao para float
        float totalBytes = [[NSNumber numberWithLongLong:response.expectedContentLength] floatValue];
        
        //passar para a viewcontroller o tamanho do arquivo
        [_delegate recebiTotalBytes:totalBytes];
        
        //passar para a viewcontroller o nome do arquivo
        [_delegate recebiNomeArquivo:response.suggestedFilename];
        
        //preparar o endereco local de onde o arquivo sera salvo
        pathArquivo = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", response.suggestedFilename];
        
        NSLog(@"Local do arquivo salvo: %@", pathArquivo);
        
        //inicializar o fileHandle
        //recebe os pacotes e atualiza o arquivo
        manipuladorArquivo = [NSFileHandle fileHandleForUpdatingAtPath:pathArquivo];
        
        //timer que recalucula a velocidade do time
        timerVelocidade = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(atualizarVelocidade) userInfo:nil repeats:YES];
    }
    else
    {
        NSLog(@"O arquivo possuí 0 bytes e não será baixado!");
    }

}

//recebendo os pacotes
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data != nil)
    {
        [dadosRecebidos appendData:data];
    }
    
    //descobrindo o tamanho do pacote recebvido
    float tamanhoPacoteRecebido = (float)data.length;
    
    //acumulando a quantidade de bytes recebido até o momento
    totalDadosRecebidosAtual = totalDadosRecebidosAtual + tamanhoPacoteRecebido;
    
    //passando para a view controller o total de bytes recebidos até o momento
    [_delegate estouRecebendoDados:totalDadosRecebidosAtual];
    
    if (tamanhoPacoteRecebido > 0)
    {
        //sendo maior do que zero temos novos dados para acumular no arquivo sendo salvo pelo file handle
        
        if (manipuladorArquivo.availableData.length > 0)
        {
            //se o avaliabledata for maior do que 0, ja tinhamos dados salvos no arquivo em disco, preciso encontrar o final desse arquivo antes de continuar anexando novos pacotes
            [manipuladorArquivo seekToEndOfFile];
        }
        //guarda os dados no arquivo
        [manipuladorArquivo writeData: data];
    }
}

//finaliza o download
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_delegate recebiArquivoCompleto:dadosRecebidos];
    
    totalDadosRecebidosAtual = 0;
    tempoDownloadAtual = 0;
    
    //para de escrever no arquivo e fecha o mesmo
    [manipuladorArquivo closeFile];
    
    [timerVelocidade invalidate];
}



@end
