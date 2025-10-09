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

User Function GetListaPadr(cCliente, cLoja, cCondPago)

	Local cListaPadr 	:= ""
	Local cListaCont 	:= ""
	Local cLista		:= ""
	Local cLIstaOrg		:= M->C5_TABLEA
	Local aArea    		:= GetArea()

	Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])== "C6_PRODUTO" })
	Local nPValor	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_VALOR'})
	Local nPDescont	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_DESCONT'})
	Local nPValdesc	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_VALDESC'})
	Local nPQtdven	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_QTDVEN'})
	Local nPPrunit	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRUNIT'})
	Local nPPrcven	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRCVEN'})


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

	//M->C5_TABELA := Posicione("DA0",1,xFilial("DA0")+cLista,"DA0_CODTAB")
	





	//If FUNNAME()$"MATA410"
		
		IF cLIstaOrg <> cLista
			//If !(aCols[nI][Len(aCols[nI])]) // SOLO LINEAS NO BORRADAS
				If !empty(aCols[1][nPosCod])
					For nI := 1 To Len(aCols)                            
						If !empty(aCols[nI][nPosCod])
							aCols[nI][nPPrunit] := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("SC5")+ cLista +aCols[nI][nPosCod],1,0)*6.96  
							
							aCols[nI][nPPrcven]  := ROUND((aCols[nI][nPPrunit]-(aCols[nI][nPPrunit]*aCols[nI][nPDescont]/100)),2)

							aCols[nI][nPValor]   := ROUND((aCols[nI][nPPrunit]-(aCols[nI][nPPrunit]*aCols[nI][nPDescont]/100))*aCols[nI][nPQtdven],2)

							aCols[nI][nPValdesc]		:= a410Arred((aCols[nI][nPPrUnit]-aCols[nI][nPPrcVen])*IIf(aCols[nI][nPQtdven]==0,1,aCols[nI][nPQtdven]),"C6_VALDESC")

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
		EndIf

	//Endif

	


	RestArea(aArea)

Return cLista

User Function GetLstCont(cCliente, cLoja, cCondPago)

	
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
