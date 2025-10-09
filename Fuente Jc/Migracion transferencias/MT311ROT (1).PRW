#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

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
User Function MT311ROT()

aRotina := ParamIxb
aRotina[aScan(aRotina,{|x| AllTrim(x[2]) == "A311Efetiv"}),2] := "U_UN311EFET"
//ADD OPTION aRotina TITLE "Adeus" ACTION "U_UN311EFET" OPERATION 4 ACCESS 0 ID OP_EFE  	//'Efetivar'

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   UN311EFET  ³ Autor ³ Cleyton                 ³ Data ³ 17/12/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integracion                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UN311EFET()

Local aAreaNNS:=NNS->(GetArea())
Local aAreaNNT:=NNT->(GetArea())
Local aError  := {}
Local aCabTrf := {}
Local aItmTmp := {}
Local aItmTrf := {}
Local aNfs    := {}
Local nPosSuc := 0   
Local nCosto  := 0
Local lRet    := .T.
local lSigue  := .T.
Local lParci  := GetNewPAr("MV_UNSLPRC",.F.) //Permite transferencia parcial
Local nx      := 0
Local ni      := 0
Local nConta  := 0
Local cQry    := ""
Local cAlQry  := GetNextAlias()
Local cDocX   := ""
Local cSerieX := ""
Local cCliX   := ""
Local cLojX   := ""
Local aObjects := {}
Local aSize	   := MsAdvSize()
Local aInfo	   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Local oListBx1 := Nil
Local oDlg     := Nil
Local aCabLbx1 := {"Item","Producto","Almacen","Lote","Ubicacion","Cantidade","Error"}
Local lAutoRas := .F.
Local lAutoUbi := .F.
Local aTmpNNT  := {}
Local nTotQtd  := 0
Local nQtdItm  := 0
Local nCnt     := 0

NNT->(dbSeek(xFilial("NNT")+NNS->NNS_COD))

While NNT->(!Eof()) .And. NNT->(NNT_FILIAL+NNT_COD) == xFilial("NNT")+NNS->NNS_COD //.And. lRet

	nConta++
	If Empty(NNT->NNT_DOC+NNT->NNT_SERIE)
		lSigue   := .T.
		lAutoRas := .F.
		lAutoUbi := .F.
		nCosto   := 0
		nTotQtd  := NNT->NNT_QUANT
		nQtdItm  := 0
		aTmpNNT  := {}
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+NNT->NNT_PROD))
		If SB1->B1_RASTRO == "L"
			If Empty(NNT->NNT_LOTECT)
				lAutoRas := .T.
				/*
				aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Lote no informado"})
				lSigue := .F.
				lRet   := .F.
				*/
			Else
				SB8->(dbSetOrder(3))
				If SB8->(dbSeek(xFilial("SB8")+NNT->NNT_PROD+NNT->NNT_LOCAL+NNT->NNT_LOTECT))
					If SB8->B8_DTVALID < dDataBase
						aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Lote vencido"})
						lSigue := .F.
						lRet   := .F.
					EndIf
					If SB8->B8_SALDO - SB8->B8_EMPENHO <= 0
						aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Lote sin saldo disponible"})
						lSigue := .F.
						lRet   := .F.
					EndIf
				Else
					aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Lote no encontrado"})
					lSigue := .F.
					lRet   := .F.
				EndIf
			EndIf
		EndIf
		If SB1->B1_LOCALIZ == "S"
			If Empty(NNT->NNT_LOCALI)
				lAutoUbi := .T.
				/*
				aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Ubicacion no informada"})
				lSigue := .F.
				lRet   := .F.
				*/
			Else
				SBF->(dbSetOrder(1))
				If SBF->(dbSeek(xFilial("SBF")+NNT->NNT_LOCAL+NNT->NNT_LOCALI+NNT->NNT_PROD+NNT->NNT_NSERIE+AllTrim(NNT->NNT_LOTECT)))
					If SBF->BF_QUANT - SBF->BF_EMPENHO <= 0
						aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Ubicacion sin saldo disponible"})
						lSigue := .F.
						lRet   := .F.
					EndIf
				Else
					aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Ubicacion no encontrada"})
					lSigue := .F.
					lRet   := .F.
				EndIf
			EndIf
		EndIf
		
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2") + NNT->NNT_PROD + NNT->NNT_LOCAL))
			nCosto := SB2->B2_CM1
			If SB2->B2_QATU - SB2->B2_QEMP <= 0
				aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Producto sin saldo disponible"})
				lSigue := .F.
				lRet   := .F.
			EndIf
		Else
			aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"Almacen no encontrado"})
			lSigue := .F.
			lRet   := .F.
		EndIf

		If lAutoRas .Or. lAutoUbi
			
			cQry := "SELECT "
			
			If SB1->B1_RASTRO == "L"
				cQry += "B8_LOTECTL AS LOTE, B8_SALDO-B8_EMPENHO AS SALDO, B8_DTVALID AS VALID, "
			Else
				cQry += "' ' AS LOTE, 0 AS SALDO, ' ' AS VALID, "
			EndIf
			
			If SB1->B1_LOCALIZ == "S"
				cQry += "BF_LOCALIZ AS LOCALIZ, BF_QUANT AS QUANT "
			Else
				cQry += "' ' AS LOCALIZ, 0 AS QUANT "
			EndIf

			cQry += "FROM "
			
			If SB1->B1_RASTRO == "L"
				cQry += RetSqlName("SB8")+" SB8 "
				If SB1->B1_LOCALIZ == "S"	
					cQry += ", "
				EndIf
			EndIf
			If SB1->B1_LOCALIZ == "S"
				cQry += RetSqlName("SBF")+" SBF "
			EndIf			
			
			cQry += " WHERE "

			If SB1->B1_RASTRO == "L"	
				cQry += "B8_FILIAL   = '"+xFilial("SB8") +"' AND "
				cQry += "B8_PRODUTO  = '"+NNT->NNT_PROD  +"' AND "
				cQry += "B8_LOCAL    = '"+NNT->NNT_LOCAL +"' AND "
				cQry += "B8_DTVALID >= '"+DtoS(dDataBase)+"' AND "
				If !Empty(NNT->NNT_LOTECT)
					cQry += "B8_LOTECTL = '"+NNT->NNT_LOTECT+"' AND "
				EndIf
				cQry += "SB8.D_E_L_E_T_ <> '*' "
				If SB1->B1_LOCALIZ == "S"
					cQry += "AND "
					cQry += "B8_LOTECTL = BF_LOTECTL AND "
				EndIf
			EndIf
			If SB1->B1_LOCALIZ == "S"
				cQry += "BF_FILIAL   = '"+xFilial("SBF") +"' AND "
				cQry += "BF_PRODUTO  = '"+NNT->NNT_PROD  +"' AND "
				cQry += "BF_LOCAL    = '"+NNT->NNT_LOCAL +"' AND "
				If !Empty(NNT->NNT_LOCALI)
					cQry += "BF_LOCALIZ = '"+NNT->NNT_LOCALI+"' AND "
				EndIf
				cQry += "SBF.D_E_L_E_T_ <> '*' "
			EndIf
			If SB1->B1_RASTRO == "L"
				cQry += "ORDER BY B8_DTVALID ASC, B8_LOTECTL ASC "
			Else
				cQry += "ORDER BY BF_LOCALIZ ASC "
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlQry,.T.,.T.)
			While (cAlQry)->(!Eof()) .And. nTotQtd > 0
				
				If !((lAutoRas .And. Empty((cAlQry)->LOTE)) .Or. (lAutoUbi .And. Empty((cAlQry)->LOCALIZ)))
					
					nQtdItm := Iif((cAlQry)->SALDO > (cAlQry)->QUANT,(cAlQry)->QUANT,(cAlQry)->SALDO)
					
					aAdd(aTmpNNT,{(cAlQry)->LOTE, STOD((cAlQry)->VALID), (cAlQry)->LOCALIZ,Iif(nQtdItm>nTotQtd,nTotQtd,nQtdItm)})
					nTotQtd -= nQtdItm
				EndIf
				(cAlQry)->(dbSkip())
			EndDo
			(cAlQry)->(dbCloseArea())

			If nTotQtd > 0
				aAdd(aError,{nConta,NNT->NNT_PROD,NNT->NNT_LOCAL,NNT->NNT_LOTECT,NNT->NNT_LOCALI,NNT->NNT_QUANT,"No hay saldo suficiente para lote o ubicacion a indicar."})
				lSigue := .F.
				lRet   := .F.
			EndIf
				
		EndIf

		If lRet .Or. (lParci .And. lSigue) 
			nPosSuc := aScan(aNFs,{|x| x[1] == NNT->NNT_FILDES})
			If nPosSuc == 0
			
				cQry := "SELECT A2_COD, A2_LOJA FROM "+RetSqlName("SA2")+" WHERE "
				cQry += "A2_FILIAL = '"+xFilial("SA2")+"' AND "
				cQry += "D_E_L_E_T_ <> '*' AND "
				cQry += "A2_FILTRF = '"+NNT->NNT_FILORI+"' "
				//cQry += "A2_FILTRF = '"+NNT->NNT_FILDES+"' "
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlQry,.T.,.T.)
				While (cAlQry)->(!Eof())
					cCliX   := (cAlQry)->A2_COD
					cLojX   := (cAlQry)->A2_LOJA
					(cAlQry)->(dbSkip())
				EndDo
				(cAlQry)->(dbCloseArea())

				If NNT->NNT_FILORI <> NNT->NNT_FILDES
					cSerieX := "NAL"
				Else
					cSerieX := "LOC"
				EndIf

				aAdd(aNFs,{NNT->NNT_FILDES,NNS->NNS_ESPECI,{},cSerieX,cCliX,cLojX,0})
				nPosSuc := Len(aNFs)
			EndIf
			
			If Len(aTmpNNT) > 0
				For nCnt := 1 To Len(aTmpNNT)
					aNFs[nPosSuc,7] += nCosto*aTmpNNT[nCnt,4]
					aAdd(aNFs[nPosSuc,3],{	NNT->NNT_PROD  ,;
											NNT->NNT_UM    ,;
											NNT->NNT_LOCAL ,;
											aTmpNNT[nCnt,2],;
											aTmpNNT[nCnt,1],;
											aTmpNNT[nCnt,3],;
											aTmpNNT[nCnt,4],;
											NNT->NNT_LOCLD ,;
											NNT->NNT_LOCDES,;
											NNT->NNT_TS    ,;
											NNT->NNT_TE    ,;
											NNT->NNT_OBS   ,;
											NNT->(Recno()) ,;
											nCosto         ,;
											nCosto*aTmpNNT[nCnt,4]})
				Next
					
			Else
				aNFs[nPosSuc,7] += nCosto*NNT->NNT_QUANT
				aAdd(aNFs[nPosSuc,3],{	NNT->NNT_PROD  ,;
										NNT->NNT_UM    ,;
										NNT->NNT_LOCAL ,;
										NNT->NNT_DTVALI,;
										NNT->NNT_LOTECT,;
										NNT->NNT_LOCALI,;
										NNT->NNT_QUANT ,;
										NNT->NNT_LOCLD ,;
										NNT->NNT_LOCDES,;
										NNT->NNT_TS    ,;
										NNT->NNT_TE    ,;
										NNT->NNT_OBS   ,;
										NNT->(Recno()) ,;
										nCosto         ,;
										nCosto*NNT->NNT_QUANT})
			EndIf
		EndIf
	EndIf
	NNT->(dbSkip())
EndDo

//If Len(aNFs)>0
//	Pergunte('MATXNF',.T.)
//EndIf
	
If lParci .Or. lRet
	For nx:=1 To Len(aNFs)
		If !Empty(aNFs[nx,5])
			aCabTrf := {}
			aItmTrf := {}
			cDocX   := U_CORSERTRA(aNFs[nx,4])                                                                            

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
			//AAdd( aCabTrf, { "F2_VALBRUT"	, aNFs[nx,7]		, Nil } )
			//AAdd( aCabTrf, { "F2_VALMERC"	, aNFs[nx,7]		, Nil } )

			For ni := 1 To Len(aNFs[nx,3])
				aItmTmp := {}
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
				
				AAdd( aItmTrf, aItmTmp)
			Next

			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+aNFs[nx,5]+aNFs[nx,6]))
			LocxNf(54 ,aCabTrf , aItmTrf , 3 ,"MATA462TN")

			SF2->(dbSetOrder(1))
			If !SF2->(dbSeek(xFilial("SF2")+cDocX+aNFs[nx,4]+aNFs[nx,5]+aNFs[nx,6]))
				MostraErro()
				MsgAlert("Factura inconsistente, documento no generado")
				lRet := .F.		
			Else
				For ni := 1 To Len(aNFs[nx,3])
					NNT->(dbGoTo(aNFs[nx,3,ni,13]))
					RecLock("NNT",.F.)
					NNT->NNT_DOC   := cDocX
					NNT->NNT_SERIE := aNFs[nx,4]
					MsUnLock()
				Next
			EndIf
		Else
			MsgStop("No hay cliente registrado para la sucursal "+aNfs[nx,1])
		EndIf
	Next

	RestArea(aAreaNNS)
	If lRet
		RecLock("NNS",.F.)
		NNS->NNS_STATUS := "2"
		MsUnlock()
	EndIf
EndIf

If Len(aError) > 0
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE "Inconsistencias" FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	oListBx1 := TwBrowse():New(aPosObj[1,1]+5 ,aPosObj[1,2]+5 ,aPosObj[3,4]-5 ,aPosObj[3,3]-5 ,,aCabLbx1,,oDlg,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oListBx1:SetArray(aError)
	oListBx1:bLine:={||{Transform(aError[oListBx1:nAt,01],"@E 99,999") ,;
						aError[oListBx1:nAt,02] ,;
						aError[oListBx1:nAt,03] ,;
						aError[oListBx1:nAt,04] ,;
						aError[oListBx1:nAt,05] ,;
						Transform(aError[oListBx1:nAt,06],"@E 999,999,999.99") ,;
						aError[oListBx1:nAt,07] }}
							
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},,/*aBotoes*/)
EndIf

RestArea(aAreaNNT)

Return()

/* si un dia quisera tratar mirando la factura, ai está.. falta cargar el acols y cabec
Local aPergs:= {'MATXNF',.T.}
Private nNFTipo   := 0
Private cNFTipo   := ""
Private cEspecie  := ""
Private lCliente  := .F.
Private cCadastro := ""
Private bFilBrw	  := {|| }
Private nTipo     := 54
Private aRotina   := {}

aAdd(aRotina,{"Pesquisar","LocxPesq(bFilBrw,1)"	, 0 , 1 , 0 , .F. })  		  // "Pesquisar"
aAdd(aRotina,{"Visualizar","LocxDlgNF(aCfgNF,2)"	, 0 , 2 , 0 , NIL })	      // "Visualizar"
aAdd(aRotina,{"Incluir","LocxDlgNF(aCfgNF,3,bFilBrw)"	, 0 , 3 , 0 , NIL})  // "Incluir"

//LoadPergs(aPerg,@aPergs)
Pergunte('MATXNF',.T.)
aCfgNF := MontaCfgNf(nTipo,aPergs,.T.)

//³Incilializa variaveis privates³
NFSetPrv(aCfgNF)

cCadastro := aCfgNF[20]
cEspecDoc := aCfgNF[8]

If Empty(aCfgNF)
	Return .F.
EndIf

aPE := aClone(aCfgNF[17])

LocxDlgNF(aCfgNF,3,bFilBrw)
*/
//Return()

/*
Static Function NFSetPRV(aNF)

nNFTipo		:= aNF[1]
cNFTipo		:= aNF[10]
cEspecie 	:= aNF[8]
lCliente	:= aNF[2]=="SA1"
cCadastro	:= aNF[19]

Return
*/
