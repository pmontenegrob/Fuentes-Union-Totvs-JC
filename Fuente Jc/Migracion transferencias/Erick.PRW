Static Function TransfItens(_aTransf,_aPedAux,_aRepoTransf,_aRepoAux,_lProcRet)
	Local 	_cTesTransf  	:=	SuperGetMV("MV_XTESTRA",.F.,"700")   //TES padrão para transferência
	Local 	_cTes 	    	:=	SuperGetMV("MV_XTETRF",.F.,"200")           //TES padrão para entrada de transferência
	Local 	_x,_l,nZY
	Local	_cSerie			:=	cFilAnt
	Local   _cNumDoc		:= 	GtDocTrf(_cSerie)
	Local 	cxLote			:= ""
	Local 	cxLocaliz		:= ""
	Local 	dtValid         :=  Stod('//')
	Private _aCabec			:= 	{}
	Private _aItens			:= 	{}
	Private	_aCliFor		:=	{}//&(SUPERGETMV("MV_XCODCLI", .T., '{}',_cFilEnt))
	Private lMsErroAuto    	:= 	.F.
	default _lProcRet		:= 	.F.    //Define se o retorno será processado automaticamente ou posteriormente de forma manual

	While ((ExtNroTr(_cNumDoc,_cSerie,'RTS') == .T. ))
		_cNumDoc			:= GtDocTrf(_cSerie)
	EndDo

	_cCliTrf := u_RetForOri(_cFilEnt)   //Função padrão utilizada no fonte original  locxnf2.prw


	AADD(_aCliFor,SubStr(_cCliTrf,1,6))
	AADD(_aCliFor,SubStr(_cCliTrf,7,2))


	If Len(_aCliFor) = 0
		Alert("Problema na identificacao do cliente. Verifique parametro MV_XCODCLI")
		return .f.
	EndIf

		/* _aTransf:
			1 - Filial Origem
			2 - Filial Destino
			3 - Produto
			4 - Lote
			5 - Endereco
			6 - Local
			7 - Quantidade
			8 - Data Validade Lote
		*/			

	_nItem  :=  1


	For _x:= 1 To Len(_aTransf)

		cxLote			:= ""
		cxLocaliz		:= ""
		_dtValid         := StoD('//')

		_cPrcUnit := BuscaPreco(_aTransf[_x,3])

		_cProd 	:= Padr(AllTrim(_aTransf[_x,3]),TamSx3("C6_PRODUTO")[1])
		_cLoc 	:= Padr(AllTrim(_aTransf[_x,6]),TamSx3("C6_LOCAL")[1])
		_cLote 	:= Padr(AllTrim(_aTransf[_x,4]),TamSx3("C6_LOTECTL")[1])
		_cEnd 	:= Padr(AllTrim(_aTransf[_x,5]),TamSx3("C6_LOCALIZ")[1])

		DbSelectArea("SB1")
		DbSetOrder(1)

		If !DbSeek(xFilial("SB1")+_cProd)
			Alert("Registro no encontrado en la tabla SB1 :"+xFilial("SB1")+_cProd+" Error cid, 1128")
			Return .f.
		EndIf

		
		If SB1->B1_RASTRO == "L"
			DbSelectArea("SB8")
			DbSetOrder(3)

			If !DbSeek(xFilial("SB8")+_cProd+_cLoc+_cLote)
				Alert("Registro no encontrado en la tabla SB8 :"+xFilial("SB8")+_cProd+_cLoc+_cLote+" Error cod. 1136")
				Return .f.
			else
				cxLote = SB8->B8_LOTECTL
				dtValid = SB8->B8_DTVALID
				_dtValid := SB8->B8_DTVALID
			EndIf
		else
			_cLote := ""
			_dtValid := StoD('//')
		Endif

		
		IF SB1->B1_LOCALIZ == "S"
			DbSelectArea("SBF")
			DbSetOrder(1)

			if !empty(_cEnd)
				If !DbSeek(xFilial("SBF")+_cLoc+_cEnd+_cProd)
					Alert("Registro no encontrado en la tabla SBF:"+xFilial("SBF")+_cLoc+_cEnd+_cProd+" Error cod. 1144")
					Return .f.
				else
					cxLocaliz = SBF->BF_LOCALIZ
				EndIf
			endif
		Else
			_cEnd := ""
		Endif

		_nVlrTotal 	:=	Round(_cPrcUnit*_aTransf[_x,7],2)
		_nPrcUnit	:=	Round(_nVlrTotal / _aTransf[_x,7],4)

		_aLinha := {}

		AAdd( _aLinha, { "D2_COD"       , _cProduto:=_aTransf[_x,3]		, Nil } )
		//AAdd( _aLinha, { "D2_COD"       , _aTransf[_x,3]		, Nil } )
		AAdd( _aLinha, { "D2_QUANT"     , _aTransf[_x,7]		, Nil } )
		AAdd( _aLinha, { "D2_PRCVEN"    , _cPrcUnit				, Nil } )
		AAdd( _aLinha, { "D2_TOTAL"     , _nVlrTotal			, Nil } )
		AAdd( _aLinha, { "D2_TES"       , _cTesTransf			, Nil } )
		AAdd( _aLinha, { "D2_LOCAL"	 	, _aTransf[_x,6]		, Nil } )
		AAdd( _aLinha, { "D2_UM"        , SB1->B1_UM			, Nil } )
		AAdd( _aLinha, { "D2_ESPECIE"   , "RTS"					, Nil } )
		AAdd( _aLinha, { "D2_TIPO"      , "B"					, Nil } )
		
		//If SUBSTR(_cLoc,5,2)=="22"
		//	AAdd( _aLinha, { "D2_LOCDEST "  , SubStr(_cLocDest,1,3)+"-22", Nil } )
		//Else
			AAdd( _aLinha, { "D2_LOCDEST "  , _cLocDest				, Nil } )
		//Endif
		AAdd( _aLinha, { "D2_TESENT"    , _cTes					, Nil } )
		AAdd( _aLinha, { "D2_LOCALIZ"   , SBF->BF_LOCALIZ		, Nil })
		//AAdd( _aLinha, { "D2_LOCALIZ"   , cxLocaliz		, Nil })
		

		IF SB1->B1_RASTRO == "L"
			AAdd( _aLinha, { "D2_LOTECTL"   , _cLote		, Nil })
			AAdd( _aLinha, { "D2_DTVALID"   , _dtValid 		, Nil })

		// Ricardo 05/04/2024
		//if posicione("SB1",1,xfilial('SB1')+_cProduto,'B1_RASTRO')=='L'
		//	AAdd( _aLinha, { "D2_LOTECTL"   , SB8->B8_LOTECTL		, Nil })
		//	AAdd( _aLinha, { "D2_DTVALID"   , SB8->B8_DTVALID 		, Nil })
		endif
		aadd(_aItens, _aLinha)
		_nItem++

	Next

	_cCliente 	:= 	_aCliFor[1]
	_cLoja 		:=	_aCliFor[2]
	_cCondPag	:= 	"000"
	_cGrpDep	:=	_cFilEnt    //Grupo de depósito

	DbSelectArea("SA1")
	dbsetorder(1)
	If !DbSeek(xfilial("SA1")+_cCliente+_cLoja)
		Alert("Cliente no encontrado en el archivo. Transferência no realizada")
		Return .f.
	EndIf

	AAdd( _aCabec, { "F2_CLIENTE"	, _cCliente					, Nil } )
	AAdd( _aCabec, { "F2_FILDEST"	, _cFilEnt					, Nil } )
	AAdd( _aCabec, { "F2_LOJA"   	, _cLoja					, Nil } )
	AAdd( _aCabec, { "F2_SERIE"  	, _cSerie					, Nil } )
	AAdd( _aCabec, { "F2_DOC"    	, _cNumDoc					, Nil } )
	AAdd( _aCabec, { "F2_COND"   	, _cCondPag					, Nil } )
	AAdd( _aCabec, { "F2_EMISSAO"	, dDataBase					, Nil } )
	AAdd( _aCabec, { "F2_DTDIGIT"	, dDataBase					, Nil } )
	AAdd( _aCabec, { "F2_EST"    	, SA1->A1_EST				, Nil } )
	AAdd( _aCabec, { "F2_TIPO"   	, "B"   					, Nil } )
	AAdd( _aCabec, { "F2_ESPECIE"	, "RTS"  					, Nil } )
	AAdd( _aCabec, { "F2_PREFIXO"	, "RTS"    					, Nil } )
	AAdd( _aCabec, { "F2_MOEDA"  	, CriaVar("F2_MOEDA",.t.)	, Nil } )
	AAdd( _aCabec, { "F2_TXMOEDA"	, CriaVar("F2_TXMOEDA",.t.)	, Nil } )
	AAdd( _aCabec, { "F2_FORMUL" 	, "S"   					, Nil } )
	AAdd( _aCabec, { "F2_TIPODOC"	, "54"  					, Nil } )
	AAdd( _aCabec, { "F2_TIPORET" 	, Iif(_lProcRet,"1","2")	, Nil } )
	AAdd( _aCabec, { "F2_FRETE" 	, 0							, Nil } )
	AAdd( _aCabec, { "F2_DESPESA"	, 0     					, Nil } )
	AAdd( _aCabec, { "F2_SEGURO"	, 0   						, Nil } )
	AAdd( _aCabec, { "F2_GRPDEP"	, _cGrpDep 					, Nil } )
	AAdd( _aCabec, { "F2_NUMAUT"	, ""    					, Nil } )
	AAdd( _aCabec, { "F2_LIMEMIS"	, ""    					, Nil } )
	
	//AAdd( _aCabec, { "F2_UOBSRC"	, ""    					, Nil } )

	lMsErroAuto := .F.
	nOpcX := 3

	//Aviso("Array > Cab",u_zArrToTxt(_aCabec, .T.),{"Ok"},,,,,.T.)
	//Aviso("Array > Det",u_zArrToTxt(_aItens, .T.),{"Ok"},,,,,.T.)
	If Len(_aItens) > 0 
		LocxNf(54 ,_aCabec , _aItens , nOpcX ,"MATA462TN") //Generando Transferencia de Sucursal de Salida
	endif

	IF Len(_aTransf)>0
		If SF2->(!DbSeek(xFilial("SF2")+_cNumDoc+_cSerie+_cCliente+_cLoja))//lMsErroAuto
			Alert("Falla al generar nota de transferencia  - Error cod. 1312")
			MostraErro()
			//Se debe realizar el montaje completo, de otro modo rollback de transacciones 
			Return .F.
		Else
			ConfirmSx8()

			//Quando o cadastro en la tabla 75 é feita em tempo de execução o array fica vazio e prejutida o resto do fluxo de execução
			If Empty(_aCliFor[1])
				_aCliFor[1] := SF2->F2_CLIENTE
				_aCliFor[2] := SF2->F2_LOJA
			EndIf

			SF2->(RecLock("SF2"),.F.)
			SF2->F2_VEICUL1	:=	_cGetVeic
			SF2->F2_XMOTORI	:=	_cGetMoto
			SF2->F2_XCARGA	:=	ZZ1->ZZ1_CARGA //_cNumCarga
			SF2->F2_UOBSRC	:=	"TRANSF. POR MONTAJE DE CARGA TRASP.VTAS: "+ZZ1->ZZ1_FILIAL+"-"+ZZ1->ZZ1_CARGA
			SF2->(MsUnlock())

			//Atualizar numero do pedido de transferencia nos itens dos pedidos originais
			If !AtuPedOrigem(_aPedAux)
				Return .F.
			EndIf


			If _lProcRet
				_cFilOri	:= cFilAnt
				sm0->(dbseek(cEmpAnt+_cFilEnt))
				cEmpAnt:=sm0->m0_codigo
				cFilAnt:=sm0->m0_codfil
				_lEndOk 	:= 	.F.
				_lPedEnt 	:=	.F.
				//MsgRun("Enderecando produtos...","Espere",{|| _lEndOk := u_Enderecar(cFilAnt,_cNumDoc,_cSerie,_aCliFor[1],_aCliFor[2])})
				_lEndOk	:=	.T.
				If	_lEndOk
					MsgRun("Generando Pedidos de Entrega","Espere",{|| _lPedEnt := u_PedEntrega(_cFilOri,cFilAnt,_cNumDoc,_cSerie,_aCliFor[1],_aCliFor[2]) })
				EndIf

				sm0->(dbgoto(_nRecSm0))
				cEmpAnt:=sm0->m0_codigo
				cFilAnt:=sm0->m0_codfil

				If _lEndOk .And. _lPedEnt
				Else
					Return .F.
				EndIf
			EndIf
		EndIf
		
		Aviso("Transferencia por Trasp.Ventas entre Sucursales ",_cNumDoc+" / "+_cSerie,{"OK"},,,,,.T.,10)
	Endif

	_aCabec			:= 	{}
	_aItens			:= 	{}

	While ((ExtNroTr(_cNumDoc,_cSerie,'RTS') == .T. ))
		_cNumDoc			:= GtDocTrf(_cSerie)
	EndDo
	
	///genera salidas para las reposiciones
	For _x:= 1 To Len(_aRepoTransf)

		_aLotes := BuscaLotes(_aRepoTransf[_x,1], _aRepoTransf[_x,2], _aRepoTransf[_x,3], _aRepoTransf[_x,4], _aRepoTransf[_x,5] )
		
		If Len(_aLotes) = 0
			Alert("Ningún lote encontrado para el producto "+_aRepoTransf[_x,1]+" "+_aRepoTransf[_x,4])
			Return .F.
		EndIf
	
		/*
		_aLotes => {_LOT->BF_LOCAL,_LOT->BF_LOCALIZ,_LOT->BF_LOTECTL,_LOT->B8_DTVALID,_LOT->QUANT}
		*/

		_cPrcUnit := BuscaPreco(_aRepoTransf[_x,1])

		///recorre lineas de productos con sin lote
		For _l:=1 To Len(_aLotes)

			_cProd 	:= Padr(AllTrim(_aRepoTransf[_x,1]),TamSx3("C6_PRODUTO")[1])
			_cLoc 	:= Padr(AllTrim(_aLotes[_l,1]),TamSx3("C6_LOCAL")[1])
			_cEnd 	:= Padr(AllTrim(_aLotes[_l,2]),TamSx3("C6_LOCALIZ")[1])
			_cLote 	:= Padr(AllTrim(_aLotes[_l,3]),TamSx3("C6_LOTECTL")[1])


			DbSelectArea("SB1")
			DbSetOrder(1)

			If !DbSeek(xFilial("SB1")+_cProd)
				Alert("Registro no encontrado en la tabla SB1 :"+xFilial("SB1")+_cProd)
				Return .f.
			EndIf
			
			If SB1->B1_RASTRO == "L"
				DbSelectArea("SB8")
				DbSetOrder(3)

				If !DbSeek(xFilial("SB8")+_cProd+_cLoc+_cLote)
					Alert("Registro no encontrado en la tabla SB8 :"+xFilial("SB8")+_cProd+_cLoc+_cLote)
					Return .f.
				EndIf
			Endif

			
			If SB1->B1_LOCALIZ == "S"
				DbSelectArea("SBF")
				DbSetOrder(1)
			
				If !DbSeek(xFilial("SBF")+_cLoc+_cEnd+_cProd)
					Alert("Registro no encontrado en la tabla SBF:"+xFilial("SBF")+_cLoc+_cEnd+_cProd)
					Return .f.
				EndIf
			endif

			_nPrcUnit	:=	1 //Round(_nVlrTotal / _aLotes[_l,5],4)
			_nVlrTotal 	:=	_aLotes[_l,5] //Round(_cPrcUnit*_aLotes[_l,5],2)
			
			_aLinha := {}

			If SB1->B1_RASTRO == "L"
				
				AAdd( _aLinha, { "D2_COD"       , _aRepoTransf[_x,1]		, Nil } )
				AAdd( _aLinha, { "D2_QUANT"     , _aLotes[_l,5]		, Nil } )
				AAdd( _aLinha, { "D2_PRCVEN"    , _cPrcUnit				, Nil } )
				AAdd( _aLinha, { "D2_TOTAL"     , _nVlrTotal			, Nil } )
				AAdd( _aLinha, { "D2_TES"       , _cTesTransf			, Nil } )
				AAdd( _aLinha, { "D2_LOCAL"	 	, _aLotes[_l,1]			, Nil } )
				AAdd( _aLinha, { "D2_UM"        , SB1->B1_UM			, Nil } )
				AAdd( _aLinha, { "D2_ESPECIE"   , "RTS"					, Nil } )
				AAdd( _aLinha, { "D2_TIPO"      , "B"					, Nil } )
				
				//If SubStr(_cLoc,5,2)=="22"
				//	AAdd( _aLinha, { "D2_LOCDEST "  , SubStr(_cLocDest,1,3)+"-22", Nil } )
				//Else
					AAdd( _aLinha, { "D2_LOCDEST "  , _cLocDest				, Nil } )
				//Endif
				AAdd( _aLinha, { "D2_TESENT"    , _cTes					, Nil } )
				AAdd( _aLinha, { "D2_LOCALIZ"   , SBF->BF_LOCALIZ		, Nil })
				AAdd( _aLinha, { "D2_LOTECTL"   , SB8->B8_LOTECTL		, Nil })
				AAdd( _aLinha, { "D2_DTVALID"   , SB8->B8_DTVALID 		, Nil })
			else
					
				AAdd( _aLinha, { "D2_COD"       , _aRepoTransf[_x,1]		, Nil } )
				AAdd( _aLinha, { "D2_QUANT"     , _aLotes[_l,5]		, Nil } )
				AAdd( _aLinha, { "D2_PRCVEN"    , _cPrcUnit				, Nil } )
				AAdd( _aLinha, { "D2_TOTAL"     , _nVlrTotal			, Nil } )
				AAdd( _aLinha, { "D2_TES"       , _cTesTransf			, Nil } )
				AAdd( _aLinha, { "D2_LOCAL"	 	, _aLotes[_l,1]		, Nil } )
				AAdd( _aLinha, { "D2_UM"        , SB1->B1_UM			, Nil } )
				AAdd( _aLinha, { "D2_ESPECIE"   , "RTS"					, Nil } )
				AAdd( _aLinha, { "D2_TIPO"      , "B"					, Nil } )
				
				//If SubStr(_cLoc,5,2)=="22"
				//	AAdd( _aLinha, { "D2_LOCDEST "  , SubStr(_cLocDest,1,3)+"-22", Nil } )
				//Else	
					AAdd( _aLinha, { "D2_LOCDEST "  , _cLocDest			, Nil } )
				//Endif
				AAdd( _aLinha, { "D2_TESENT"    , _cTes					, Nil } )
				//AAdd( _aLinha, { "D2_LOCALIZ"   , " "					, Nil })
				//AAdd( _aLinha, { "D2_LOTECTL"   , " "					, Nil })
				//AAdd( _aLinha, { "D2_DTVALID"   , " "			 		, Nil })
			Endif
			aadd(_aItens, _aLinha)
			_nItem++

		Next

	Next

	if len(_aItens)>0

		_cCliente 	:= 	_aCliFor[1]
		_cLoja 		:=	_aCliFor[2]
		_cCondPag	:= 	"000"
		_cGrpDep	:=	_cFilEnt    //Grupo de depósito

		DbSelectArea("SA1")
		dbsetorder(1)
		If !DbSeek(xfilial("SA1")+_cCliente+_cLoja)
			Alert("Cliente no encontrado no cadastro. Transferência não realizada")
			Return .f.
		EndIf

		AAdd( _aCabec, { "F2_CLIENTE"	, _cCliente					, Nil } )
		AAdd( _aCabec, { "F2_FILDEST"	, _cFilEnt					, Nil } )
		AAdd( _aCabec, { "F2_LOJA"   	, _cLoja					, Nil } )
		AAdd( _aCabec, { "F2_SERIE"  	, _cSerie					, Nil } )
		AAdd( _aCabec, { "F2_DOC"    	, _cNumDoc					, Nil } )
		AAdd( _aCabec, { "F2_COND"   	, _cCondPag					, Nil } )
		AAdd( _aCabec, { "F2_EMISSAO"	, dDataBase					, Nil } )
		AAdd( _aCabec, { "F2_DTDIGIT"	, dDataBase					, Nil } )
		AAdd( _aCabec, { "F2_EST"    	, SA1->A1_EST				, Nil } )
		AAdd( _aCabec, { "F2_TIPO"   	, "B"   					, Nil } )
		AAdd( _aCabec, { "F2_ESPECIE"	, "RTS"  					, Nil } )
		AAdd( _aCabec, { "F2_PREFIXO"	, "RTS"    					, Nil } )
		AAdd( _aCabec, { "F2_MOEDA"  	, CriaVar("F2_MOEDA",.t.)	, Nil } )
		AAdd( _aCabec, { "F2_TXMOEDA"	, CriaVar("F2_TXMOEDA",.t.)	, Nil } )
		AAdd( _aCabec, { "F2_FORMUL" 	, "S"   					, Nil } )
		AAdd( _aCabec, { "F2_TIPODOC"	, "54"  					, Nil } )
		AAdd( _aCabec, { "F2_TIPORET" 	, Iif(_lProcRet,"1","2")	, Nil } )
		AAdd( _aCabec, { "F2_FRETE" 	, 0							, Nil } )
		AAdd( _aCabec, { "F2_DESPESA"	, 0     					, Nil } )
		AAdd( _aCabec, { "F2_SEGURO"	, 0   						, Nil } )
		AAdd( _aCabec, { "F2_GRPDEP"	, _cGrpDep 					, Nil } )
		AAdd( _aCabec, { "F2_NUMAUT"	, ""    					, Nil } )
		AAdd( _aCabec, { "F2_LIMEMIS"	, ""    					, Nil } )


		lMsErroAuto := .F.
		nOpcX := 3

		LocxNf(54 ,_aCabec , _aItens , nOpcX ,"MATA462TN")


		If SF2->(!DbSeek(xFilial("SF2")+_cNumDoc+_cSerie+_cCliente+_cLoja))//lMsErroAuto
			Alert("Falla al generar nota de transferencia - Error cod. 1443")
			MostraErro()
			Return .F.
		Else
			ConfirmSx8()

			//Quando o cadastro en la tabla 75 é feita em tempo de execução o array fica vazio e prejutida o resto do fluxo de execução
			If Empty(_aCliFor[1])
				_aCliFor[1] := SF2->F2_CLIENTE
				_aCliFor[2] := SF2->F2_LOJA
			EndIf


			SF2->(RecLock("SF2"),.F.)
			SF2->F2_VEICUL1	:=	_cGetVeic
			SF2->F2_XMOTORI	:=	_cGetMoto
			SF2->F2_XCARGA	:=	ZZ1->ZZ1_CARGA //_cNumCarga
			SF2->F2_UOBSRC	:=	"TRANSF. POR MONTAJE DE CARGA REP.&OTROS: "+ZZ1->ZZ1_FILIAL+"-"+ZZ1->ZZ1_CARGA
			SF2->(MsUnlock())


			DbSelectArea("SZY")
			For nZY:= 1 To Len(_aRepoAux)
				DbGoTo(_aRepoAux[nZY,9])
				RecLock("SZY",.f.)
				SZY->ZY_ESTADO := '5'
				SZY->ZY_XNFTRAN:= _cNumDoc
				SZY->ZY_XSERTRA:= _cSerie
				SZY->ZY_XPESBRU:= _aRepoAux[nZY,15]
				SZY->(MsUnlock())
			Next

			If _lProcRet
				_cFilOri	:= cFilAnt
				sm0->(dbseek(cEmpAnt+_cFilEnt))
				cEmpAnt:=sm0->m0_codigo
				cFilAnt:=sm0->m0_codfil
				_lEndOk 	:= 	.F.
				_lPedEnt 	:=	.F.
				//MsgRun("Enderecando produtos...","Espere",{|| _lEndOk := u_Enderecar(cFilAnt,_cNumDoc,_cSerie,_aCliFor[1],_aCliFor[2])})
				_lEndOk	:=	.T.
				If	_lEndOk
					MsgRun("Generando Pedidos de Entrega","Espere",{|| _lPedEnt := u_PedEntrega(_cFilOri,cFilAnt,_cNumDoc,_cSerie,_aCliFor[1],_aCliFor[2]) })
				EndIf

				sm0->(dbgoto(_nRecSm0))
				cEmpAnt:=sm0->m0_codigo
				cFilAnt:=sm0->m0_codfil

				If _lEndOk .And. _lPedEnt
				Else
					Return .F.
				EndIf
			EndIf
			
		endif
		
		Aviso("Transferencia por Reposiciones entre Sucursales ",_cNumDoc+" / "+_cSerie,{"OK"},,,,,.T.,10)
	EndIf

Return .T.
