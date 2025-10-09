#Include 'Protheus.ch'
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram ³GetStockNeg ºAuthor ³Ariel Dominguez Vargasº Date ³ 01/06/2025 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usado en la personalización de precios especial por venta  º±±
±±º          ³ al contado, revisar mas adelante para optimizar			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ UNION	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PreGetListaPadrPre2(cCliente, cLoja, cCondPago)

	Local cListaPadr 	:= ""
	Local cListaCont 	:= ""
	Local cLista		:= ""
	Local cLIstaOrg		:= M->CJ_TABLEA
	Local aArea    		:= GetArea()

	/*Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])== "CK_PRODUTO" })
	Local nPValor	:= aScan(aHeader,{|x| AllTrim(x[2])=='Ck_VALOR'})
	Local nPDescont	:= aScan(aHeader,{|x| AllTrim(x[2])=='CK_DESCONT'})
	Local nPValdesc	:= aScan(aHeader,{|x| AllTrim(x[2])=='CK_VALDESC'})
	Local nPQtdven	:= aScan(aHeader,{|x| AllTrim(x[2])=='CK_QTDVEN'})
	Local nPPrunit	:= aScan(aHeader,{|x| AllTrim(x[2])=='CK_PRUNIT'})
	Local nPPrcven	:= aScan(aHeader,{|x| AllTrim(x[2])=='CK_PRCVEN'})
	*/

	Local nI
	Local nX

	cListaPadr := GetAdvFVal("SA1","A1_TABPADR",xFilial("SA1")+cCliente+ALLTRIM(cLoja),1,"")
	cListaCont := GetAdvFVal("SA1","A1_ULSTCNT",xFilial("SA1")+cCliente+ALLTRIM(cLoja),1,"")

	If cCondPago == "001" .or. cCondPago == "002"
		if empty(cListaCont) 
			cLista := cListaPadr
		Else
			cLista := cListaCont
		EndIf	
	else
		cLista := cListaPadr	
	EndIf
	/*MsgStop("cLIstaOrg : " +cValToChar(cLIstaOrg)  )
	 Aviso("AVISO","El cliente cumple con la condición para una venta con precio especial al contado"+cValToChar(cLIstaOrg) )
	MsgStop("cLista : " +cValToChar(cLista) )
	  Aviso("AVISO","El cliente cumple con la condición para una venta con precio especial al contado")*/
	//M->C5_TABELA := Posicione("DA0",1,xFilial("DA0")+cLista,"DA0_CODTAB")
	IF cLIstaOrg <> cLista
		dbSelectArea("TMP1"		)
		dbGotop()
		While !Eof()
			If !Empty (TMP1->CK_PRODUTO)
				RecLock("TMP1",.F.)
				
				TMP1->CK_PRUNIT  := ROUND(GetAdvFVal("DA1","DA1_PRCVEN",xFilial("SCJ")+ cLista +TMP1->CK_PRODUTO,1,0)*6.96,2)
				//MsgStop("CK_PRUNIT : " +cValToChar(TMP1->CK_PRUNIT ) )//133,632

				TMP1->CK_PRCVEN  := ROUND(TMP1->CK_PRUNIT - TMP1->CK_PRUNIT*TMP1->CK_DESCONT/100,2)
				/*MsgStop("CK_PRCVEN : " +cValToChar(TMP1->CK_PRCVEN ) ) //120,2688
				MsgStop("CK_DESCONT : " +cValToChar(TMP1->CK_DESCONT ))
				MsgStop("CK_QTDVEN : " +cValToChar(TMP1->CK_QTDVEN ) )*/

				//TMP1->CK_VALOR   := ROUND((TMP1->CK_PRUNIT - ROUND((TMP1->CK_PRUNIT*TMP1->CK_DESCONT),2)/100)* TMP1->CK_QTDVEN,2) pvi 157,2264 pvicont  133,632
 				//                      133,632                 133
				TMP1->CK_VALOR := 	ROUND((TMP1->CK_PRUNIT - TMP1->CK_PRUNIT*TMP1->CK_DESCONT/100),2) * TMP1->CK_QTDVEN
				//MsgStop("CK_VALOR : " +cValToChar(CK_VALOR ) )//106,9
				//TMP1->CK_VALOR : 133,632 - ROUND((133,632*10/100) * TMP1->CK_QTDVEN,2)
				//prueba :=ROUND((TMP1->CK_PRUNIT*TMP1->CK_DESCONT/100) * TMP1->CK_QTDVEN,2)
				//MsgStop("prueba : " +cValToChar(prueba ) )
				
				TMP1->CK_VALDESC := (TMP1->CK_PRUNIT-TMP1->CK_PRCVEN )*IIf(TMP1->CK_QTDVEN==0,1,TMP1->CK_QTDVEN)	
				//MsgStop("CK_VALDESC : " +cValToChar(TMP1->CK_VALDESC ) )
				//CK_PRUNIT=  133,63 - (120,27 * 10 /100) * 2 
				 
				MsUnLock()
			EndIf
			dbSkip()
		EndDo
		TMP1->(dbGotop())
		oGetDad:oBrowse:Refresh()
	Endif



	/*If FUNNAME()$"MATA410"*/
		
	/*IF cLIstaOrg <> cLista
		//If !(aCols[nI][Len(aCols[nI])]) // SOLO LINEAS NO BORRADAS
			If !empty(aCols[1][nPosCod])
				For nI := 1 To Len(aCols)                            
					If !empty(aCols[nI][nPosCod])
						aCols[nI][nPPrunit] := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("SCJ")+ cLista +aCols[nI][nPosCod],1,0)*6.96  
						
						aCols[nI][nPPrcven]  := ROUND((aCols[nI][nPPrunit]-(aCols[nI][nPPrunit]*aCols[nI][nPDescont]/100)),2)

						aCols[nI][nPValor]   := ROUND((aCols[nI][nPPrunit]-(aCols[nI][nPPrunit]*aCols[nI][nPDescont]/100))*aCols[nI][nPQtdven],2)

						aCols[nI][nPValdesc]		:= a410Arred((aCols[nI][nPPrUnit]-aCols[nI][nPPrcVen])*IIf(aCols[nI][nPQtdven]==0,1,aCols[nI][nPQtdven]),"CK_VALDESC")

						//aCols[n][nPValdesc]:= a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nQtdVen]==0,1,aCols[n][nQtdVen]),"C6_VALDESC")

					EndIf
				Next nI

				oDlg := GetWndDefault()
		
				For nX := 1 To Len(oDlg:aControls)
					If ValType(oDlg:aControls[nX]) <> "U"
						oDlg:aControls[nX]:ReFresh()
					EndIf	
				Next nX
			
			EndIf
		//Endif
	EndIf*/

	/*Endif*/


	

	RestArea(aArea)

Return cLista

User Function PreGetLstContPre2(cCliente, cLoja, cCondPago)

	
	Local cListaCont 	:= ""
	Local cListaPadr 	:= ""
	Local aArea    	:= GetArea()
	
	cListaPadr := GetAdvFVal("SA1","A1_TABPADR",xFilial("SA1")+cCliente+ALLTRIM(cLoja),1,"")
	cListaCont := GetAdvFVal("SA1","A1_ULSTCNT",xFilial("SA1")+cCliente+ALLTRIM(cLoja),1,"")
	

	If cCondPago == "001" .or. cCondPago == "002"
		if !empty(cListaCont) 
			cListaCont := cListaPadr	
		EndIf
	else 
		cListaCont := ""	
	EndIf

	RestArea(aArea)
Return cListaCont
