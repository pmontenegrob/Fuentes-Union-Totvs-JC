#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WS     ³ MayorDescuento ³ Autor ³ Widen Gonzales					  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Coloca el Mayor descuento entre Cliente y Regla de descuento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TdeP Horeb                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M410LIOK


//Local nPprcven   	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
//Local nPValor	 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
//Local nPDescon		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"}) 
//Local nPValdesc		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nQtdVen  		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
//Local nPPrUnit  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
//Local cXModesc  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_XMODESC"})

//Local nItem			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM" })
//Local nItemB		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UITEMB" })
//Local nTPliq		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UTPLIQ" })

//Local nLote			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL" })
//Local nVenc			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID" })
Local nPTes			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES" })

Local nData			:= 0

Local nDescCab:=0
Local nVenDias, nVenPor, nDiasVen, nPorVenIni, nPorVenFin

Local nPCod 	:= aScan(aHeader,{|x| AllTrim(x[2])== "C6_PRODUTO" })
Local aArea    	:= GetArea()
Local cArea1	:= GetNextAlias()


If aCols[n][nPTes] = "530" .AND. !(aCols[n][Len(aCols[n])]) .AND. xFilial("SC6") <> "0105"
		MsgStop("Las ventas Futuras solo se pueden realizar desde la sucursal Santa Cruz")
		RestArea(aArea)
		Return .F.
EndIf

If FUNNAME()$"MATA410" .and. !EMPTY(ALLTRIM(aCols[n][nPCod])) .and. aCols[n][nQtdVen] > 0 .AND. !(aCols[n][Len(aCols[n])]) .and. aCols[n][nPTes] = "530"
	_cSQL:="SELECT ISNULL(SUM(C6_QTDVEN),0) C6_QTDVEN, ISNULL(AVG(Z50_CANT), 0) Z50_CANT"
	_cSQL:=_cSQL+" FROM Z50010 Z50  "	
	_cSQL:=_cSQL+" LEFT JOIN SC6010 SC6" 
	_cSQL:=_cSQL+" ON SC6.D_E_L_E_T_ = ' '" 
	_cSQL:=_cSQL+" AND C6_PRODUTO = Z50_COD" 
	_cSQL:=_cSQL+" LEFT JOIN SC5010 SC5" 
	_cSQL:=_cSQL+" ON SC5.D_E_L_E_T_ = ' '" 
	_cSQL:=_cSQL+" AND C6_FILIAL = C5_FILIAL" 
	_cSQL:=_cSQL+" AND C6_NUM = C5_NUM"
	_cSQL:=_cSQL+" AND C5_EMISSAO > '20250701'"
	_cSQL:=_cSQL+" WHERE Z50.D_E_L_E_T_ = ' '"
	_cSQL:=_cSQL+" AND Z50_COD = '" + ALLTRIM(aCols[n][nPCod]) + "'" 
	
	_cSQL:= ChangeQuery(_cSQL)
	 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL), cArea1 ,.T.,.F.)   
	dbSelectArea(cArea1)
	dbGoTop()
	
	If !EOF() .AND. (C6_QTDVEN + aCols[n][nQtdVen]) > Z50_CANT .AND. Z50_CANT > 0 
		MsgStop("Cantidad que se intenta vender sobrepasa la planificación de entrada. Cantidad Prevista: " + cValToChar(TRANSFORM(Z50_CANT,"@E 99,999,999.99")) + "  Cantidad en Pedidos: " + cValToChar(TRANSFORM(C6_QTDVEN,"@E 99,999,999.99"))  + "  Saldo Disponible: " + cValToChar(TRANSFORM(Z50_CANT-C6_QTDVEN,"@E 99,999,999.99")) )
		RestArea(aArea)
		Return .F.
	EndIf
	RestArea(aArea)

Endif


/*

If FUNNAME()$"MATA410" .and. !EMPTY(ALLTRIM(aCols[n][nItemB])) .and. ALLTRIM(aCols[n][nItemB]) >= ALLTRIM(aCols[n][nItem]) .and. !EMPTY(ALLTRIM(aCols[n][nTPliq])) //.and. ALLTRIM(aCols[n][nItemB]) > len(aCols)
	MsgStop("Linea informada en el Item de Bonificacion es incorrecto")
	Return .F.
Endif

If FUNNAME()$"MATA410" .and. (ALLTRIM(aCols[n][nTPliq])) == 'VEN'
	IF EMPTY(ALLTRIM(aCols[n][nLote])) .or. EMPTY(aCols[n][nVenc])
		MsgStop("Cuando se selecciona Motivo de Liquidación VEN se tiene que seleccionar un LOTE")
		Return .F.
	EndIf

	nData 		:= DateDiffDay(DDATABASE,aCols[n][nVenc])
	nVenDias 	:= SUPERGETMV("MV_UVENDIA")

	If nData > nVenDias // ADV: 5 meses, mayor a eso no aplica descuento por vencimiento
		MsgStop("Por política interna no se permiten descuentos por VENCIMIENTO a productos con vencimiento mayor a 5 meses ")
		Return .F.
	EndIf

	nVenPor 	:= SUPERGETMV("MV_UVENPOR")
	If aCols[n][nPDescon] > nVenPor
		MsgStop("Por política interna no se permiten descuentos por VENCIMIENTO mayores a 99%")
		Return .F.
	EndIf 

	nDiasVen	:= SUPERGETMV("MV_UVEND1")
	nPorVenIni	:= SUPERGETMV("MV_UVENPI1")
	nPorVenFin	:= SUPERGETMV("MV_UVENPF1")
	If aCols[n][nPDescon] > nPorVenIni .and. aCols[n][nPDescon] <=nPorVenFin .and. nData > nDiasVen
		MsgStop("Por política interna no se permite este porcentaje de descuento a vencimientos mayores a 1 mes")
		Return .F.
	EndIf

	nDiasVen	:= SUPERGETMV("MV_UVEND2")
	nPorVenIni	:= SUPERGETMV("MV_UVENPI2")
	nPorVenFin	:= SUPERGETMV("MV_UVENPF2")
	If aCols[n][nPDescon] > nPorVenIni .and. aCols[n][nPDescon] <=nPorVenFin .and. nData > nDiasVen
		MsgStop("Por política interna no se permite este porcentaje de descuento a vencimientos mayores a 2 meses")
		Return .F.
	EndIf

	nDiasVen	:= SUPERGETMV("MV_UVEND3")
	nPorVenIni	:= SUPERGETMV("MV_UVENPI3")
	nPorVenFin	:= SUPERGETMV("MV_UVENPF3")
	If aCols[n][nPDescon] > nPorVenIni .and. aCols[n][nPDescon] <=nPorVenFin .and. nData > nDiasVen
		MsgStop("Por política interna no se permite este porcentaje de descuento a vencimientos mayores a 3 meses")
		Return .F.
	EndIf

	nDiasVen	:= SUPERGETMV("MV_UVEND4")
	nPorVenIni	:= SUPERGETMV("MV_UVENPI4")
	nPorVenFin	:= SUPERGETMV("MV_UVENPF4")
	If aCols[n][nPDescon] > nPorVenIni .and. aCols[n][nPDescon] <=nPorVenFin .and. nData > nDiasVen
		MsgStop("Por política interna no se permite este porcentaje de descuento a vencimientos mayores a 4 meses")
		Return .F.
	EndIf

	nDiasVen	:= SUPERGETMV("MV_UVEND5")
	nPorVenIni	:= SUPERGETMV("MV_UVENPI5")
	nPorVenFin	:= SUPERGETMV("MV_UVENPF5")
	If aCols[n][nPDescon] > nPorVenIni .and. aCols[n][nPDescon] <=nPorVenFin .and. nData > nDiasVen
		MsgStop("Por política interna no se permite este porcentaje de descuento a vencimientos mayores a 5 meses")
		Return .F.
	EndIf

EndIf


*/

/*Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
*/
//aCols[1][nPPrcVen] := 2 //A410Arred(FtDescCab(aCols[n][nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,valdesc4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
//aCols[1][nPValor]  := 6//A410Arred(aCols[n][nPPrcVen]*nQtdVen,"C6_VALOR",If(cPaisLoc=="CHI" .And. lPrcdec,M->C5_MOEDA,NIL))
//IF empty(aCols[n][nPMotiv])
//IF (M->C5_DESC4 + M->C5_DESC1) >= aCols[n][nPDescon]


//BEZ 20221222 valida que no pueda reducir el precio de venta
/*
if (aCols[n][nPprcven] < aCols[n][nPPrUnit]).and.(aCols[n][nPValdesc]==0 .or. aCols[n][nPDescon]==0)
	MsgStop("No esta permitido reducir el precio de venta")
	Return .F.
end if
*/


///////nDescCab:= M->C5_DESC1 + M->C5_DESC4





//if M->C5_MOEDA=2
	//IF (M->C5_DESC4) > 0
	
	
	/*ADV IF (nDescCab) > 0		
		IF aCols[n][nPDescon] > nDescCab 
			
			if Empty(aCols[n][cXModesc])
				//ALERT('Es mayor')
				//MSGINFO( 'Descuento por Item: '+ alltrim(str(aCols[n][nPDescon])) +' , Nuevo Descuento por Item: '+ (aCols[n][nPDescon]- nDescCab) , "No aplica Descuento Sobre descuento" )
				//MSGINFO( 'Anterior Descuento/Item: '+alltrim(str(aCols[n][nPDescon]))+' , Nuevo Descuento/Item: '+alltrim(str(aCols[n][nPDescon]- nDescCab)), "No aplica Descuento Sobre Descuento" )			
				MSGINFO( 'NO APLICA Descuento x Cabecera: '+ alltrim(str(nDescCab)) +' , SI APLICA Descuento x Item: '+alltrim(str(aCols[n][nPDescon])), "No aplica Descuento Sobre Descuento" )
				aCols[n][cXModesc]:=AllTrim(Str(aCols[n][nPDescon]))
				//aCols[n][nPDescon]:=aCols[n][nPDescon]- nDescCab
				//aCols[n][cXModesc]:='S'
			endif
			//aCols[n][nPValdesc]:=0
			//aCols[n][nPValdesc]:= a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"C6_VALDESC")
			
			//aCols[n][nPPrcVen] := A410Arred(FtDescCab(aCols[n][nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
			aCols[n][nPPrcVen] := A410Arred(FtDescCab(aCols[n][nPPrUnit],{0})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
			aCols[n][nPValor]  := A410Arred(aCols[n][nPPrcVen]*aCols[n][nQtdVen],"C6_VALOR",If(cPaisLoc=="CHI" .And. lPrcdec,M->C5_MOEDA,NIL))
			// Utiliza nPPrcVen
			aCols[n][nPValdesc]:= a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nQtdVen]==0,1,aCols[n][nQtdVen]),"C6_VALDESC")
		else
			IF Empty(aCols[n][cXModesc])	
				//Alert('Es Menor o igual')
				aCols[n][cXModesc]:=AllTrim(Str(aCols[n][nPDescon]))
				aCols[n][nPDescon]:=0
				aCols[n][nPValdesc]:=0
				
				MSGINFO( 'SI APLICA solo Descuento x Cabecera: '+ alltrim(str(nDescCab)) +' , NO APLICA Descuento x Item: '+alltrim(str(aCols[n][nPDescon])), "No aplica Descuento Sobre Descuento" )
				
				aCols[n][nPPrcVen] := A410Arred(FtDescCab(aCols[n][nPPrUnit],{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN")
				aCols[n][nPValor]  := A410Arred(aCols[n][nPPrcVen]*aCols[n][nQtdVen],"C6_VALOR",If(cPaisLoc=="CHI" .And. lPrcdec,M->C5_MOEDA,NIL))
				//aCols[n][nPValdesc]:= A410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nQtdVen]==0,1,aCols[n][nQtdVen]),"C6_VALDESC")
			ENDIF
		endIF
		
	ENDIF

	ADV*/


Return(.T.)
