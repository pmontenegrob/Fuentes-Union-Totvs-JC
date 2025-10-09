#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#Include "aarray.ch"
#Include "json.ch"
#INCLUDE "RESTFUL.CH"
#include 'parmtype.ch'
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   MT311ROT   ³ Autor ³ Cleyton                 ³ Data ³ 17/12/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integracion                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MIGRATRANSFJC()

// Inicializamos los arreglos para cabecera y detalle
// Inicializamos las variables necesarias
	/*Local aCabTrf := {}  // Arreglo para la cabecera
	Local aItmTrf := {}  // Arreglo para el detalle
	Local cSQL := ""      // Variable para las consultas SQL
	Local aData, aDocData
	Local cDocumento, cEmision, cProducto
	Local nCant
	Local i, j
	Local nRegs	:= 0*/
	Local cNextAlias := GetNextAlias()
	Local aArea 	 := GetArea()
	Local cQuery	:= ""
		


	cQuery := "SELECT DISTINCT SUCURSAL_DESTINO,SERIE,DOC,EMISION FROM UC_TMP_LOAD_TRANSFER_SUC"

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias ,.T.,.T.) 
	
	dbSelectArea(cNextAlias)
	
	dbGoTop()
	
	If !(Eof()) 
        lExiste := .T.
		
    End               
    (cAreaINC)->(DbCloseArea()) 
    RestArea(cAreaAnt)
	
Return lExiste

	/*MsgAlert("ENTRA 2")
	//TCQuery cQuery New Alias "QRY_SEL"
	MsgAlert("ENTRA 3")
	if !QRY_SEL->(EoF())
		while !QRY_SEL->(EoF())
			//aadd(aValAlic,QRY_SEL->FB_ALIQ)
			MsgAlert(QRY_SEL->DOC)
			QRY_SEL->(dbskip())
		enddo
	endif
	///posicion 1 es el it posicion dos es el iva
	MsgAlert(Alltrim("antes de close area"))
	QRY_SEL->(DbCloseArea())
	RestArea(aArea)
	// Iniciamos la conexión con la base de datos si es necesario
	//DbUseArea(.T., "DBF", "UC_TMP_LOAD_TRANSFER_SUC")  // Si es necesario abrir la tabla
	/*cSQL := "SELECT DISTINCT SUCURSAL_DESTINO, SERIE, DOC,EMISION, EMISION  as F2_DTDIGIT FROM UC_TMP_LOAD_TRANSFER_SUC where SUCURSAL_DESTINO = '0105'"
	aData := SQLExec(cSQL)
	MsgAlert(aData)
	Return("ACABO")*/
	//DbUseArea(.T., "DBF", "UC_TMP_LOAD_TRANSFER_SUC", "UC_TMP_LOAD_TRANSFER_SUC", .T., .T.)
	//MsgAlert(Alltrim("DbUseArea"))
	// Consultar todos los documentos únicos (DOCUMENTO, EMISION) de la tabla temporal
/*BeginSQL Alias cNextAlias
		//SELECT DISTINCT SUCURSAL_DESTINO, SERIE, DOC,EMISION, EMISION  as F2_DTDIGIT FROM UC_TMP_LOAD_TRANSFER_SUC
	SELECT  * FROM SA1010 SA1
EndSQL*/
	//MsgAlert(Alltrim("BeginSQL"))
	//DbSelectArea(cNextAlias) // seleccionar area Area
	//MsgAlert(Alltrim("DbSelectAreaPASO"))

	//(cNextAlias)->( DbGoTop() )
	//MsgAlert(nRespuesta := (cNextAlias)->A1_COD)
	/*If (cNextAlias)->( !Eof() )
		While !(cNextAlias)->(Eof() )
			MsgAlert(Alltrim((cNextAlias)->DOC))
		EndDo
	EndIf*/
	//(cNextAlias)->( dbCloseArea() )
	//RestArea(aArea)
//Return("TERMINO")

	/*While !cNextAlias->(EOF())
		MsgAlert(Alltrim((cNextAlias)->DOC))
		nRegs++
		cNextAlias->(DBSkip())
	EndDo
	cNextAlias->(DBCloseArea())*/
//		MsgInfo("Terminop2")
	//Return
	
//cSQL := "SELECT DISTINCT SUCURSAL_DESTINO, SERIE, DOC,EMISION, EMISION  as F2_DTDIGIT FROM UC_TMP_LOAD_TRANSFER_SUC where SUCURSAL_DESTINO = '0105'"
//aData := TCSQLExec(cSQL)
//MsgAlert("ERROR AL ACTUALIZAR EL COSTO EN CQ")
/*
MsgInfo(aData)
Return
// Procesar cada documento
For i := 1 To Len(aData)
    // Obtener el documento y emisión de la fila actual
    cDocumento := aData[i,1]  // DOCUMENTO
    cEmision := aData[i,2]    // EMISION
	AAdd( aCabTrf, { "F2_FILDEST"	, aNFs[nx,1]		, Nil } )
	AAdd( aCabTrf, { "F2_CLIENTE"	, aNFs[nx,5]		, Nil } )
	AAdd( aCabTrf, { "F2_LOJA"   	, aNFs[nx,6]		, Nil } )
	AAdd( aCabTrf, { "F2_SERIE"  	, aNFs[nx,4]		, Nil } )
	AAdd( aCabTrf, { "F2_DOC"    	, cDocX				, Nil } )
	AAdd( aCabTrf, { "F2_EMISSAO"	, dDataBase			, Nil } )
	AAdd( aCabTrf, { "F2_DTDIGIT"	, dDataBase			, Nil } )
	AAdd( aCabTrf, { "F2_MOEDA"  	, 1					, Nil } )
	AAdd( aCabTrf, { "F2_TXMOEDA"	, 1					, Nil } )
	//AAdd( aCabTrf, { "F2_REFMOED"  	, 1					, Nil } )
	//AAdd( aCabTrf, { "F2_TPDOC"  	, "1"				, Nil } )
	//AAdd( aCabTrf, { "F2_MODCONS"  	, "1"				, Nil } )
	AAdd( aCabTrf, { "F2_ESPECIE"	, aNFs[nx,2]		, Nil } )
    
    // Limpiar los arreglos de cabecera y detalle para este documento
    aCabTrf := {}
    aItmTrf := {}
    
    // Agregar la cabecera a aCabTrf (Documento y Emisión)
    AAdd(aCabTrf, {cDocumento, cEmision})
    
    // Consultar los detalles para el documento actual
    cSQL := "SELECT PRODUCTO, CANT FROM UC_TMP_LOAD_TRANSFER_SUC WHERE DOCUMENTO = '" + cDocumento + "' AND EMISION = '" + cEmision + "'"
    aDocData := SQLExec(cSQL)
    
    // Procesar los registros de detalle para este documento
    For j := 1 To Len(aDocData)
        cProducto := aDocData[j, 1]  // PRODUCTO
        nCant := aDocData[j, 2]     // CANT
		AAdd( aItmTmp, { "D2_COD"       , aNFs[nx,3,ni,01]	, Nil } )
		AAdd( aItmTmp, { "D2_UM"        , aNFs[nx,3,ni,02]	, Nil } )
		AAdd( aItmTmp, { "D2_LOCAL"	 	, aNFs[nx,3,ni,03]	, Nil } )
		AAdd( aItmTmp, { "D2_DTVALID"	, aNFs[nx,3,ni,04]	, Nil } )
		AAdd( aItmTmp, { "D2_LOTECTL"	, aNFs[nx,3,ni,05]	, Nil } )
		AAdd( aItmTmp, { "D2_LOCALIZ"   , aNFs[nx,3,ni,06]	, Nil } )
		AAdd( aItmTmp, { "D2_QUANT"     , aNFs[nx,3,ni,07]	, Nil } )
		//AAdd( aItmTmp, { "D2_PRCVEN"    , aNFs[nx,3,ni,14]	, Nil } )
		//AAdd( aItmTmp, { "D2_TOTAL"     , aNFs[nx,3,ni,15]	, Nil } )
		AAdd( aItmTmp, { "D2_TES"       , aNFs[nx,3,ni,10]	, Nil } )
		AAdd( aItmTmp, { "D2_TESENT"    , aNFs[nx,3,ni,11]	, Nil } )
		AAdd( aItmTmp, { "D2_ESPECIE"   , aNFs[nx,2]		, Nil } )
		AAdd( aItmTmp, { "D2_QTDAFAT"   , aNFs[nx,3,ni,07]	, Nil } )
        
        // Agregar los detalles a aItmTrf (Documento, Emisión, Producto, Cantidad)
        AAdd(aItmTrf, {cDocumento, cEmision, cProducto, nCant})
    EndFor
    
    // Llamar a LocxNf para procesar el documento actual
    //LocxNf(54 ,aCabTrf , aItmTrf , 3 ,"MATA462TN")

EndFor
Return
*/
