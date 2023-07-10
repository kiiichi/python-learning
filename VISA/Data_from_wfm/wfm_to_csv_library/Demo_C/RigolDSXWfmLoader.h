
#ifndef _RIGOL_DSX_WFM_LOADER_H_
#define _RIGOL_DSX_WFM_LOADER_H_


#define CALL_METHOD __stdcall

// type
#define HANDLE_WFM      int
#define HANDLE_CH       int

#define HANDLE_SESSION  int

#define INVALID_HANDLE  0

// const

#define HORI_MODE_YT    0
#define HORI_MODE_XY    1
#define HORI_MODE_ROLL  2

#define HORI_UNIT_S     0
#define HORI_UNIT_HZ    1

#define VERT_UNIT_V     2
#define VERT_UNIT_A     1
#define VERT_UNIT_W     0
#define VERT_UNIT_U     3

#define VERT_UNIT_Vrms  4
#define VERT_UNIT_DB    5

#define WFM_SEEK_CUR    1
#define WFM_SEEK_END    2
#define WFM_SEEK_SET    0

// ch id
#define ID_CH1          0
#define ID_CH2          1
#define ID_CH3          2
#define ID_CH4          3

#define ID_LA_L         4
#define ID_LA_H         5
#define ID_LA_LH        6

#define ID_MATH         7
#define ID_REF          8


// api
// wfm handle
// 0 -- fail
HANDLE_WFM CALL_METHOD wfmOpen( char *pFileName );
// 0 -- no error
int CALL_METHOD wfmClose( HANDLE_WFM wfmHandle );

// Í¨µÀÑÚÂë 0 -- CH1
//          1 -- CH2
//          2 -- CH3
//          3 -- CH4
//          4 -- LA L
//          5 -- LA H 
int CALL_METHOD wfmGetBm( HANDLE_WFM wfmHandle );

// ch handle
// 0 -- invalid handle
HANDLE_CH CALL_METHOD chOpen( HANDLE_WFM wfmHandle, int chId );
// 0 -- no err
int CALL_METHOD chClose( HANDLE_CH chHandle );

// 0 -- no err
// WFM_SEEK_CUR/WFM_SEEK_SET/WFM_SEEK_END
int CALL_METHOD chSeek( HANDLE_CH chHandle, int offs, int orig );
// size in byte
int CALL_METHOD chRead( HANDLE_CH chHandle, int size, void *pBuf );

// in dot
int CALL_METHOD chGetLength( HANDLE_CH chHandle );
int CALL_METHOD chGetDotSize( HANDLE_CH chHandle );

int CALL_METHOD chGetYUnit( HANDLE_CH chHandle );
int CALL_METHOD chGetYOr( HANDLE_CH chHandle );
int CALL_METHOD chGetYRef( HANDLE_CH chHandle );
float CALL_METHOD chGetYInc( HANDLE_CH chHandle );

int CALL_METHOD chGetXUnit( HANDLE_CH chHandle );
float CALL_METHOD chGetXOr( HANDLE_CH chHandle );
int CALL_METHOD chGetXRef( HANDLE_CH chHandle );
float CALL_METHOD chGetXInc( HANDLE_CH chHandle );

// api type
typedef HANDLE_WFM  (*PAPI_wfmOpen)( char *pFileName );
typedef int  (*PAPI_wfmClose)( HANDLE_WFM wfmHandle );
typedef int  (*PAPI_wfmGetBm)( HANDLE_WFM wfmHandle );

typedef HANDLE_CH  (*PAPI_chOpen)( HANDLE_WFM wfmHandle, int chId );
typedef int  (*PAPI_chClose)( HANDLE_CH chHandle );

typedef int  (*PAPI_chSeek)( HANDLE_CH chHandle, int offs, int orig );
typedef int  (*PAPI_chRead)( HANDLE_CH chHandle, int size, void *pBuf );

typedef int  (*PAPI_chGetLength)( HANDLE_CH chHandle );
typedef int  (*PAPI_chGetDotSize)( HANDLE_CH chHandle );

typedef int  (*PAPI_chGetYUnit)( HANDLE_CH chHandle );
typedef int  (*PAPI_chGetYOr)( HANDLE_CH chHandle );
typedef int  (*PAPI_chGetYRef)( HANDLE_CH chHandle );
typedef float  (*PAPI_chGetYInc)( HANDLE_CH chHandle );

typedef int  (*PAPI_chGetXUnit)( HANDLE_CH chHandle );
typedef float  (*PAPI_chGetXOr)( HANDLE_CH chHandle );
typedef int  (*PAPI_chGetXRef)( HANDLE_CH chHandle );
typedef float  (*PAPI_chGetXInc)( HANDLE_CH chHandle );

// error

#endif