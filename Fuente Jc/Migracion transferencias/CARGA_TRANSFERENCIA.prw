#Include "Protheus.ch" 
#INCLUDE "rwmake.CH"
#INCLUDE "TOPCONN.CH"
#include 'parmtype.ch'


/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Replicar LP ºAutor  ³Ariel Dominguez   ºFecha ³  05/09/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Replicar listas de precios                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Union                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION CargaTr() 
    Local aCabTrf := {}  // Arreglo para la cabecera
	Local aItmTrf := {}  // Arreglo para el detalle
  

    Private cArea1   := "" 
    Private cArea2   := "" 
    Private cPerg    :="UREPLP" 
   
 
    
    //ADV: Obtiene los productos a replicar
    GetTrans()
   

    While !(cArea1)->(Eof()) 
      
       
        AAdd( aCabTrf, { "F2_FILIAL"	, (cArea1)->SUCURSAL_ORIGEN, Nil } )
        AAdd( aCabTrf, { "F2_FILDEST"	, (cArea1)->SUCURSAL_DESTINO, Nil } )
        AAdd( aCabTrf, { "F2_CLIENTE"	, AllTrim("SUC0" + SUBSTR((cArea1)->SUCURSAL_ORIGEN,3)), Nil } )
        //SUC005,SUC005,SUC020,SUC000,SUC007,SUC005,
        AAdd( aCabTrf, { "F2_LOJA"   	, "01"		, Nil } )
        AAdd( aCabTrf, { "F2_SERIE"  	, (cArea1)->SERIE, Nil } )
        AAdd( aCabTrf, { "F2_DOC"    	, (cArea1)->DOC, Nil } )
        AAdd( aCabTrf, { "F2_EMISSAO"	, (cArea1)->EMISION	, Nil } )
        AAdd( aCabTrf, { "F2_DTDIGIT"	,  (cArea1)->EMISION, Nil } )
        AAdd( aCabTrf, { "F2_MOEDA"  	, 1					, Nil } )
        AAdd( aCabTrf, { "F2_TXMOEDA"	, 1					, Nil } )
        //AAdd( aCabTrf, { "F2_REFMOED"  	, 1					, Nil } )
        //AAdd( aCabTrf, { "F2_TPDOC"  	, "1"				, Nil } )
        //AAdd( aCabTrf, { "F2_MODCONS"  	, "1"				, Nil } )
        AAdd( aCabTrf, { "F2_ESPECIE"	, "RTS", Nil } )
        //AAdd( aCabTrf, { "F2_VALBRUT"	, aNFs[nx,7]		, Nil } )
        //AAdd( aCabTrf, { "F2_VALMERC"	, aNFs[nx,7]		, Nil } )
        cTexto  := "Contenido de aCabTrf:"

        /*For i:= 1 to Len(aCabTrf)
            cTexto +=Chr(13) + "Campo: " + aCabTrf[i][1] + ", Valor: " + AllTrim(aCabTrf[i][2])
        Next
        MsgAlert(cTexto, "Información")*/
        
       
        GetTransdet(AllTrim((cArea1)->DOC),AllTrim((cArea1)->SUCURSAL_ORIGEN))
      
        aItmTmp :={}
        While !(cArea2)->(Eof()) 
            AAdd( aItmTmp, { "D2_COD"       , (cArea2)->COD_PRODUCTO	, Nil } )
            AAdd( aItmTmp, { "D2_UM"        , (cArea2)->UM, Nil } )
            AAdd( aItmTmp, { "D2_LOCAL"	 	, (cArea2)->BODEGA_DESTINO	, Nil } )
            AAdd( aItmTmp, { "D2_DTVALID"	, (cArea2)->F_VENC	, Nil } )
            AAdd( aItmTmp, { "D2_LOTECTL"	, (cArea2)->LOTE	, Nil } )
            AAdd( aItmTmp, { "D2_LOCALIZ"   , (cArea2)->UBICACION	, Nil } )
            AAdd( aItmTmp, { "D2_QUANT"     , (cArea2)->CANTIDAD	, Nil } )
            //AAdd( aItmTmp, { "D2_PRCVEN"    , aNFs[nx,3,ni,14]	, Nil } )
            //AAdd( aItmTmp, { "D2_TOTAL"     , aNFs[nx,3,ni,15]	, Nil } )
            AAdd( aItmTmp, { "D2_TES"       , (cArea2)->TES_SALIDA	, Nil } )
            AAdd( aItmTmp, { "D2_TESENT"    , (cArea2)->TES_ENTRADA	, Nil } )
            AAdd( aItmTmp, { "D2_ESPECIE"   , "RTS"	, Nil } )
            AAdd( aItmTmp, { "D2_QTDAFAT"   , (cArea2)->CANTIDAD	, Nil } )
           
            cTexto := "Contenido de aItmTmp:"
            (cArea2)->(dbSkip()) 
            For i:= 1 to Len(aItmTmp)
            cTexto +=Chr(13) + "Campo: " + aItmTmp[i][1] + ", Valor: " + AllTrim(aItmTmp[i][2])
            Next
            MsgAlert(cTexto, "Información")
            (cArea2)->(dbSkip()) 
    
        End
        (cArea2)->(DbCloseArea()) 
                
        (cArea1)->(dbSkip())    
    //LocxNf(54 ,aCabTrf , aCabTrf , 3 ,"MATA462TN")
    End               
    (cArea1)->(DbCloseArea()) 
    
    Aviso("CARGA DE TRANSFERENCIAS","Proceso concluido de manera satisfactoria")

Return Nil  

Static Function GetTrans()
    	
	_cSQL := "SELECT DISTINCT SUCURSAL_ORIGEN,SUCURSAL_DESTINO,SERIE,DOC,EMISION FROM UC_TMP_LOAD_TRANSFER_SUC " 
   	_cSQL:= ChangeQuery(_cSQL)
	
    cArea1 := "TRANS1"			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL), cArea1 ,.T.,.T.)   
	dbSelectArea(cArea1)
	dbGoTop()
   
Return Nil 
Static Function GetTransdet(documento,filial)
    	
	_cSQL2 := "SELECT  COD_PRODUCTO,UM, BODEGA_DESTINO, F_VENC,LOTE,UBICACION, CANTIDAD, TES_SALIDA,TES_ENTRADA  FROM UC_TMP_LOAD_TRANSFER_SUC where SUCURSAL_ORIGEN = '"+AllTrim(filial)+"' and DOC ='"+AllTrim(documento)+"'" 
    MsgAlert(_cSQL2, "Información")
   	_cSQL2:= ChangeQuery(_cSQL2)
	
    cArea2 := "TRANS2"			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL2), cArea2 ,.T.,.T.)   
	dbSelectArea(cArea2)
	dbGoTop()
   
Return Nil 

