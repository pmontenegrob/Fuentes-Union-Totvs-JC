#INCLUDE "PROTHEUS.CH"

#Define ENTER  Chr(10) + Chr (13)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³	     ³  		  	 ³ Autor ³ Ariel Dominguez				  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT410TOK()
	Local lRet		:= .T.
	Local lCond		:= .F.
    Local aArea    	:= GetArea()
    Local aAreaC9   := SC9->(GetArea())
    Local aAreaC5   := SC5->(GetArea())
    Local aAreaC6   := SC6->(GetArea())

	Local nPValor	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_VALOR'})
	Local nPPrconta	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRCONTA'})
	Local nPDescont	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_DESCONT'})
	Local nPValdesc	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_VALDESC'})
	Local nPQtdven	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_QTDVEN'})
	Local nPPrunit	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRUNIT'})
	Local nPPrcven	:= aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRCVEN'})

	Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])== "C6_PRODUTO" })

	Local nPosTes 	:= aScan(aHeader,{|x| AllTrim(x[2])== "C6_TES" })


	Local nCont		:= 0
	Local nTotal	:= 0
	Local nTotalCre	:= 0
	//Local nMonto	:= 1
	cQryZ48  := GetNextAlias()

	If /*FUNNAME()$"MATA410" .AND.*/ (M->C5_TABELA = "006" .OR. M->C5_TABELA = "007") .AND. M->C5_CONDPAG <> "001" .AND. M->C5_CONDPAG <> "002"
		Alert("Lista de precio especial no se puede usar con condiciones de pago diferente a CONTADO")
		lRet := .F.
	Endif

	
	If /*FUNNAME()$"MATA410" .AND.*/ (M->C5_TABELA = "006" .OR. M->C5_TABELA = "007") .AND. (M->C5_CONDPAG = "001" .OR. M->C5_CONDPAG = "002") .AND. !empty(M->C5_ULISCTD)
		
		For nCont:= 1 to len(aCols)
			If !(aCols[nCont][Len(aCols[nCont])]) // If !(aCols[n][Len(aCols[n])]) SOLO LINEAS NO BORRADAS
				aCols[nCont][nPPrconta] := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("SC5")+ M->C5_ULISCTD +aCols[nCont][nPosCod],1,0)*6.96
			ENDIF
		Next
		
		
		
		For nCont:= 1 to len(aCols)
			If !(aCols[nCont][Len(aCols[nCont])]) // If !(aCols[n][Len(aCols[n])]) SOLO LINEAS NO BORRADAS
				nTotal := nTotal + aCols[nCont][nPValor]
				nTotalCre := nTotalCre + ROUND((aCols[nCont][nPPrconta]-(aCols[nCont][nPPrconta]*aCols[nCont][nPDescont]/100))*aCols[nCont][nPQtdven],2)
			ENDIF
		Next
		
				aviso("AVISO","Por su compra al contado recibe un precio especial" + ENTER + "MONTO AL CREDITO:" + cValToChar(TRANSFORM(nTotalCre,"@E 99,999,999.99")) + ENTER + "MONTO AL CONTADO:" + cValToChar(TRANSFORM(nTotal,"@E 99,999,999.99")) + ENTER + "AHORRO:  " + cValToChar(TRANSFORM(nTotalCre-nTotal,"@E 99,999,999.99")),{'Ok'},,,,,.t.)
			
			
				/*
				For nCont:= 1 to len(aCols)
					aCols[nCont][nPPrunit]  := aCols[nCont][nPPrconta]
					aCols[nCont][nPPrcven]  := ROUND((aCols[nCont][nPPrconta]-(aCols[nCont][nPPrconta]*aCols[nCont][nPDescont]/100)),2)
					aCols[nCont][nPValor]   := ROUND((aCols[nCont][nPPrconta]-(aCols[nCont][nPPrconta]*aCols[nCont][nPDescont]/100))*aCols[nCont][nPQtdven],2)

					aCols[nCont][nPValdesc]		:= a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nPQtdven]==0,1,aCols[n][nPQtdven]),"C6_VALDESC")
				Next
				*/
				lRet := .T.
			
		
	Endif

	If FUNNAME()$"MATA410" .AND. M->C5_CONDPAG = "002" //1= SI 2 = NO
			If GetAdvFVal("SA1","A1_CONTEFE",xFilial("SA1")+ M->C5_CLIENTE + "01" ,1,0) = '2'
					Alert("CLIENTE NO TIENE PERMISOS PARA CONTADO EFECTIVO ")
					lRet := .F.
			EndIf
			
	EndIf



/*
	If FUNNAME()$"MATA410"
		For nCont:= 1 to len(aCols)
			If	(aCols[nCont][nPosCod]) = '012307' .AND. (aCols[nCont][nPQtdven]) > 20  .AND. (aCols[nCont][nPosTes]) = '530'
				Alert("Cantidad que se intenta vender sobrepasa la planificación de entrada")
				lRet := .F.
			EndIf
		Next
	EndIf
*/	

	RestArea(aAreaC6)
    RestArea(aAreaC5)
    RestArea(aAreaC9)
    RestArea(aArea)



Return(lRet)
