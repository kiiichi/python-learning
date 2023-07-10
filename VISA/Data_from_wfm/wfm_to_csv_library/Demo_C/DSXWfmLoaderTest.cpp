// DSXWfmLoaderTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\..\Dll\RigolDS4000WfmLoader\RigolDSXWfmLoader.h"

int main(int argc, char* argv[])
{
    HANDLE_WFM hWfm = NULL;
    HANDLE_CH hCH = NULL;
    int chBM;
    int chId;

    do
    {
        if ( argc >= 4 )
        {
            // 1. wfm open
            hWfm = wfmOpen( argv[1] );
        }
        else
        {
            printf( "test wfmfile chid binfile\n" );
            printf( "wfmfile: *.wfm\n" );
            printf( "chid: 1/2/3/4" );
            printf( "binfile: *.bin" );
            return 0;
        }

        if ( INVALID_HANDLE == hWfm )
        {
            printf("wfmOpen Fail\n");
            break;
        }
        
        //! 2. get ch bit mask
        chBM = wfmGetBm( hWfm );
        printf( "chBM: %x\n", chBM );
        
        chId = atoi( argv[2] ) - 1;

        //! 3. ch open
        hCH = chOpen( hWfm, chId );
        if ( hCH == INVALID_HANDLE )
        {
            printf( "chOpen Fail\n" );
            break;
        }
        
        //! 4. get ch info
        printf( "chGetLength %d\n", chGetLength( hCH ) );
        printf( "chGetDotSize %d\n", chGetDotSize( hCH ) );

        printf( "chGetYUnit %d\n", chGetYUnit( hCH ) );
        printf( "chGetYOr %d\n", chGetYOr( hCH ) );
        printf( "chGetYRef %d\n", chGetYRef( hCH ) );
        printf( "chGetYInc %g\n", chGetYInc( hCH ) );
        
        printf( "chGetXUnit %d\n", chGetXUnit( hCH ) );
        printf( "chGetXOr %g\n", chGetXOr( hCH ) );
        printf( "chGetXRef %d\n", chGetXRef( hCH ) );
        printf( "chGetXInc %g\n", chGetXInc( hCH ) );

        //! 5. read ch data
        int length = chGetLength( hCH );
        int readLen;
        BYTE *pBuf = new BYTE[ length ];
        if ( NULL == pBuf )
        {
            printf("memory fail\n");
            break;
        }
        
        //! read
        readLen = chRead( hCH, length, pBuf );
        if ( readLen != length )
        {
            printf("chRead %d(%d)\n", readLen, length );
            delete []pBuf;
            break;
        }
        
        //! 6. export out data
        CFile fileOut;
        if ( !fileOut.Open( argv[3], CFile::modeCreate | CFile::modeWrite ) )
        {
            printf( "open fail\n");
            delete []pBuf;
            break;
        }
        
        fileOut.Write( pBuf, length );
        fileOut.Close();

        delete []pBuf;

    }
    while ( 0 );
    
    // clean
    if ( INVALID_HANDLE != hCH )
    {
        chClose( hCH );
        hCH = INVALID_HANDLE;
    }

    if ( INVALID_HANDLE != hWfm )
    {
        wfmClose( hWfm );
        hWfm = INVALID_HANDLE;
    }

	return 0;
}

