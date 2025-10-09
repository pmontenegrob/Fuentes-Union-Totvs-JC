#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Tbiconn.ch"
#include "Topconn.ch"
#Include "FileIO.ch"

#Define ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpRmSaida  ºAutor  ³Erick Etcheverry  ºFecha ³  08/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa Importação de Remisão de saida         	  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Bolivia\uni                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ImpRmSaida
	Private oDlg

	@ 000,000 TO 120,380 DIALOG oDlg TITLE OemToAnsi("Importación de transferencias de salida")
	@ 003,003 TO 058,188
	@ 010,018 Say "Este programa tiene como objetivo importar una o mas "
	@ 018,018 Say "transferencias de salida*.csv"

	@ 040,128 BMPBUTTON TYPE 01 ACTION MsAguarde({|| Importar(),"Procesando. Hora de inicio: " + Time()})
	@ 040,158 BMPBUTTON TYPE 02 ACTION oDlg:End()

	Activate Dialog oDlg Centered
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Importar  ºAutor  ³Erick Etcheverry   		 ºFecha ³  23/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Importar
	Local nX			:= 1
	Local cTitulo1  	:= "Seleccione Archivo"
	Local cExtens   	:= "Archivo | "
	Local cFile 		:= ""
	Local cLinea		:= ""
	Local cCampo		:= ""
	Local aValores		:= {}
	Local aCpos			:= {}
	Local cFileLog		:= ""
	Local cDirLog		:= ""
	Local cPath			:= ""
	Local lError		:= .F.
	Local nCantReg		:= 0
	Local lFin			:= .F.
	Local aArray		:= {}
	Local aTotCabs		:= {}
	Local xValor
	Local aCabec		:= {}
	Local aItem			:= {}
	Local aLinha		:= {}
	Local lTrans := .f.
	Local aSe1CxC := {}
	Local cTes := ""
	Private lMSErroAuto := .F. //.F. // Inicializa como falso, se voltar verdadeiro e' que deu erro

	/***
	* _________________________________________________________
	* cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
	* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	* <ExpC1> - Expressao de filtro
	* <ExpC2> - Titulo da janela
	* <ExpN1> - Numero de mascara default 1 para *.Exe
	* <ExpC3> - Diretório inicial se necessário
	* <ExpL1> - .F. botão salvar - .T. botão abrir
	* <ExpN2> - Mascara de bits para escolher as opções de visualização do objeto (prconst.ch)
	*/

	cExtens += "*.CSV"
	cFile := cGetFile(cExtens,cTitulo1,,,.T.)

	If File( cFile )

		AutoGrLog( "Fecha Inicio.......: " + DToC(MsDate()) )
		AutoGrLog( "Hora Inicio........: " + Time() )
		AutoGrLog( "Environment........: " + GetEnvServer() )
		AutoGrLog( "Archivo............: " + Alltrim( Lower( cFile ) ) )
		AutoGrLog( " " )

		FT_FUse(cFile)
		FT_FGotop()

		cLinea	:= FT_FREADLN()
		aCpos	:= Str2Array(cLinea,';')

		FT_FSkip()

		While (!FT_FEof() .And. !lFin)

			cLinea		:= FT_FREADLN()
			aValores	:= Str2Array(cLinea,';')
			nCantReg++
			DbSelectArea("SX3")
			DbSetOrder(2)
			For nX := 1 To Len(aCpos)
				cCampo := AllTrim(aCpos[nX])

				If SX3->(DbSeek(cCampo))
					xValor 	:= UPPER(AllTrim(aValores[nX]))

					If !lError

						If lError
							AutoGrLog( aValores[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El valor del campo "+cCampo+" Excede el tamano del diccionario." )
							Exit
						Else
							Do Case
								Case SX3->X3_TIPO == "N"
								xValor := Val(xValor)
								Case SX3->X3_TIPO == "D"
								xValor := CTOD(xValor)
								Case SX3->X3_TIPO == "C"
								xValor := PADR(xValor,TamSX3(SX3->X3_CAMPO)[1])
							EndCase

							aAdd(aArray,{cCampo,xValor,NIL})
						EndIf
					EndIF
				Else
					lFin := .T.
					AutoGrLog( "El campo " + cCampo + " no se encuentra en el diccionario de datos." )
					Exit
				EndIf

			Next nX

			If lError
				aArray  := {}
				FT_FSkip()
				Loop
			EndIf

			If lFin
				Loop
			EndIf

			aAdd(aTotCabs,aArray)
			aArray 	:= {}

			FT_FSkip()
		EndDo

		If !lError
			For nX := 1 To Len(aTotCabs)
				lMSErroAuto := .F.

				nPosSeri := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_SERIE"	})
				nPosForn := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_CLIENTE"})
				nPosLoja := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_LOJA"	})
				nPosEmis := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_EMISSAO"})
				nPosDtDg := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_DTDIGIT"})
				nPosMoed := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_MOEDA"	})
				nPosTxMo := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_TXMOEDA"})
				nPosFila := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_FILDEST"})
				nPosGrup := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "F2_GRPDEP"})

				cxFilial	:= xFilial("SF2")
				cxSerie		:= If(nPosSeri > 0	,aTotCabs[nX,nPosSeri][2]	, "   "	)
				cxProveedor	:= If(nPosForn > 0	,aTotCabs[nX,nPosForn][2]	, ""	)
				cxTienda	:= If(nPosLoja > 0	,aTotCabs[nX,nPosLoja][2]	, " "	)
				dxEmissao	:= If(nPosEmis > 0	,aTotCabs[nX,nPosEmis][2]	, dDataBase)
				dxDtDigit	:= If(nPosDtDg > 0	,aTotCabs[nX,nPosDtDg][2]	, dDataBase)
				nxMoeda		:= If(nPosMoed > 0	,aTotCabs[nX,nPosMoed][2]	, 1		)
				cFilDest    := If(nPosFila > 0	,aTotCabs[nX,nPosFila][2]	, ""	)
				cGrupLoc    := If(nPosGrup > 0	,aTotCabs[nX,nPosGrup][2]	, "0001 "	)

				nxTxMoeda	:= 1
				If nxMoeda <> 1
					nxTxMoeda	:= If(nPosTxMo > 0	,aTotCabs[nX,nPosTxMo][2]	,	RecMoeda(dDataBase,nxMoeda))
				Endif
				//posicione
				cxDocumento := fCorTrans(cxSerie)
				DbSelectArea("SF2")
				SF1->(DbSetOrder(1))//Caso ya exista conseguimos un doc nuevo
				If SF1->(DbSeek(xFilial("SF2")+cxDocumento+cxSerie+cxProveedor+cxTienda))
					cxDocumento := fCorTrans(cxSerie)
				Endif
				aCabec := {}
				aAdd(aCabec,{"F2_FILIAL"	,cxFilial	})
				aAdd(aCabec,{"F2_DOC"		,cxDocumento})
				aAdd(aCabec,{"F2_SERIE"		,cxSerie	})
				aAdd(aCabec,{"F2_CLIENTE"	,cxProveedor})
				aAdd(aCabec,{"F2_LOJA"		,cxTienda	})
				aAdd(aCabec,{"F2_TIPO"		,"NF"		})
				aAdd(aCabec,{"F2_FORMUL"	,"N"		})
				aAdd(aCabec,{"F2_EMISSAO"	,dxEmissao	})
				aAdd(aCabec,{"F2_DTDIGIT"	,dxDtDigit	})
				aAdd(aCabec,{"F2_MOEDA"		,nxMoeda	})
				aAdd(aCabec,{"F2_TXMOEDA"	,nxTxMoeda	})
				aAdd(aCabec,{"F2_TIPODOC"	,"54"		})
				aAdd(aCabec,{"F2_FILDEST"	,cFilDest})
				aAdd(aCabec,{"F2_GRPDEP"	,cGrupLoc})

				aLinha 	:= {}
				nxTote2 := 0

				While   nX <= Len(aTotCabs) .AND. cxFilial == xFilial("SF1");
				.AND. cxSerie  == aTotCabs[nX,nPosSeri][2] .AND. cxProveedor == aTotCabs[nX,nPosForn][2]				;
				.AND. cxTienda == aTotCabs[nX,nPosLoja][2]

					aItem:= {}

					nPosItProd	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_COD"	 	})
					nPosItQuant	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_QUANT"	})
					nPosItVlUni	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_PRCVEN"	})
					nPosItTotal := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_TOTAL"	})
					nPosItTes 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_TES"  	})
					nPosItLocal := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_LOCAL"	})
					nPosItUhin 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UHRINIE"	})
					nPosItUhfi 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UHRFINE"	})
					nPosItUhra 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UHORAEQ"	})
					nPosItUPtd 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UNROPTD"	})
					nPosItUOpe	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UOPERPT"	})
					nPosItItCta := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_ITEMCC"	})
					nPosItCC 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_CCUSTO"		})
					nPosItCLVL 	:= aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_CLVL"	})
					nPosLocDes  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_LOCDEST"	})

					nPosTpComb  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UTPCOMB"	})
					nPosCombus  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UCOMBUS"	})
					nPosOtInsu  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UOTRINS"	})
					nPosActRea  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UACTPTD"	})
					nPosHrsEfe  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UHREFEC"	})
					nPosHrsNul  := aScan(aTotCabs[nX],{|x| Upper(AllTrim(x[1])) == "D2_UHRNUL"	})

					cxProd	:= If(nPosItProd	> 0, aTotCabs[nX,nPosItProd ][2]	,	"")
					nxQuant	:= If(nPosItQuant	> 0, aTotCabs[nX,nPosItQuant][2]	,	0 )
					nxVlUni	:= If(nPosItVlUni	> 0, aTotCabs[nX,nPosItVlUni][2]	,	0 )
					nxTotal	:= If(nPosItTotal	> 0, aTotCabs[nX,nPosItTotal][2]	,	nxQuant * nxVlUni)
					cxTes	:= If(nPosItTes		> 0, aTotCabs[nX,nPosItTes  ][2]	,	"701")
					cxLocal	:= If(nPosItLocal	> 0, aTotCabs[nX,nPosItLocal][2]	,	"" )
					nxUhin	:= If(nPosItUhin	> 0, aTotCabs[nX,nPosItUhin ][2]	,	0)
					nxUhfi	:= If(nPosItUhfi	> 0, aTotCabs[nX,nPosItUhfi ][2]	,	0)
					nxUhra	:= If(nPosItUhra	> 0, aTotCabs[nX,nPosItUhra ][2]	,	0)
					cxUPtd	:= If(nPosItUPtd	> 0, aTotCabs[nX,nPosItUPtd ][2]	,	"000001")
					cxUOpe	:= If(nPosItUOpe	> 0, aTotCabs[nX,nPosItUOpe ][2]	,	"000001")
					cxItCta	:= If(nPosItItCta	> 0, aTotCabs[nX,nPosItItCta][2]	,	"" )
					cxCCost := If(nPosItCC		> 0, aTotCabs[nX,nPosItCC	][2]	,	"" )
					cxClVl	:= If(nPosItCLVL	> 0, aTotCabs[nX,nPosItCLVL][2]	,	"" )
					//cxTesEnt:= If(nPosTesEnt	> 0, aTotCabs[nX,nPosTesEnt][2]	,	"301" )
					cxLocDes:= If(nPosLocDes	> 0, aTotCabs[nX,nPosLocDes][2]	,	"01" )

					cxTipoCo:= If(nPosTpComb	> 0, aTotCabs[nX,nPosTpComb][2]	,	"" )
					cxCombus:= If(nPosCombus	> 0, aTotCabs[nX,nPosCombus][2]	,	"" )
					cxOtrIns:= If(nPosOtInsu	> 0, aTotCabs[nX,nPosOtInsu][2]	,	"" )
					cxActRea:= If(nPosActRea	> 0, aTotCabs[nX,nPosActRea][2]	,	"" )
					cxHrsEfe:= If(nPosHrsEfe	> 0, aTotCabs[nX,nPosHrsEfe][2]	,	"" )
					cxHrsNul:= If(nPosHrsNul	> 0, aTotCabs[nX,nPosHrsNul][2]	,	"" )
					cxTesnte:= "303"

					aAdd(aItem,{"D2_COD"	,cxProd		,Nil})
					aAdd(aItem,{"D2_QUANT"	,nxQuant	,Nil})
					aAdd(aItem,{"D2_PRCVEN"	,nxVlUni	,Nil})
					aAdd(aItem,{"D2_TOTAL"	,nxTotal	,Nil})
					aAdd(aItem,{"D2_TES"	,cxTes		,Nil})
					aAdd(aItem,{"D2_LOCAL"	,cxLocal	,Nil})
					aAdd(aItem,{"D2_UHRINIE",nxUhin		,Nil})
					aAdd(aItem,{"D2_UHRFINE",nxUhfi		,Nil})
					aAdd(aItem,{"D2_UHORAEQ",nxUhra		,Nil})
					aAdd(aItem,{"D2_UNROPTD",cxUPtd		,Nil})
					aAdd(aItem,{"D2_UOPERPT",cxUOpe		,Nil})
					aAdd(aItem,{"D2_ITEMCC",cxItCta	,Nil})
					aAdd(aItem,{"D2_CCUSTO"		,cxCCost	,Nil})
					aAdd(aItem,{"D2_CLVL"	,cxClVl	,Nil})
					aAdd(aItem,{"D2_LOCDEST",cxLocDes	,Nil})
					aAdd(aItem,{"D2_UTPCOMB",cxTipoCo	,Nil})
					aAdd(aItem,{"D2_UCOMBUS",cxCombus	,Nil})
					aAdd(aItem,{"D2_UOTRINS",cxOtrIns	,Nil})
					aAdd(aItem,{"D2_UACTPTD",cxActRea	,Nil})
					aAdd(aItem,{"D2_UHREFEC",cxHrsEfe	,Nil})
					aAdd(aItem,{"D2_UHRNUL",cxHrsNul	,Nil})
					aAdd(aItem,{"D2_TESENT",cxTesnte	,Nil})

					aAdd(aLinha ,aItem)
					nxTote2 = nxTote2 + nxTotal
					nX++

					If nX > Len(aTotCabs)
						Exit
					Endif

				EndDo

				cTes := cxTes

				AADD(aSe1CxC,{cxFilial,cxDocumento,cxSerie,cxProveedor,cxTienda,dxEmissao,nxTote2})

				nX--

				dBkpData 	:= dDataBase
				dDataBase	:= dxEmissao

				LOCXNF(54,aCabec,aLinha,3)

				//MsExecAuto({|x,y,z| Mata102N(x,y,z)}, aCabec, aLinha, 3)  // 3 - Inclusao
				MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCabec,aLinha,3)

				dDataBase	:= dBkpData

				If lMSErroAuto
					RollBackSx8()
					DisarmTransaction()
					MostraErro()
				Else
					AutoGrLog( " - Remisión/Generada: " + cxDocumento + "/" + cxSerie )
					lTrans := .t.
				EndIf
			Next nX
		EndIf
	EndIf

	AutoGrLog( "  " )
	AutoGrLog( "Fecha Fin...........: " + Dtoc(MsDate()) )
	AutoGrLog( "Hora Fin............: " + Time() )
	AutoGrLog( "Registros Procesados: " + cValToChar(nCantReg) )

	cFileLog := NomeAutoLog()

	If cFileLog <> ""
		nX := 1
		While .T.
			If File( Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) ) // El directorio debe estar creado en el servidor bajo DATA
				nX++
				If nX == 999
					Exit
				EndIf
				Loop
			Else
				Exit
			EndIf
		EndDo
		__CopyFile( cPath + Alltrim( cFileLog ), Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) )
		MostraErro(cPath,cFileLog)
		FErase( cFileLog )
	EndIf

	lTes := u_MCTESFI(cTes)
	if lTes
		incFina(aSe1CxC,lTrans)
	endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n     ³          ³ Autor ³                     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripci¢n ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Str2Array(cString,cSep)
	Local 	aReturn := { }		,;
	cAux    := cString	,;
	nPos    := 0

	While At( cSep, cAux ) > 0
		nPos  := At( cSep, cAux )
		cVal  := SubStr( cAux, 1, nPos-1 )
		Aadd( aReturn,  cVal )
		cAux  := SubStr( cAux, nPos+1 )
	EndDo

	Aadd(aReturn,cAux)
Return(aReturn)

//Erick Etcheverry Gnra CXC
static function incFina(aSe1Cxc,lTrans)
	PRIVATE lMsErroAuto := .F.
	cAuxDoc := ""
	cDocSe := ""
	if lTrans
		if len(aSe1Cxc) > 0
			for i := 1 to len(aSe1Cxc)
				if len(alltrim(aSe1Cxc[i][2])) > 0//?si no esta vacio el DOC
					cDocSe := aSe1Cxc[i][2] //guardo el doc generado
					if cDocSe != cAuxDoc //pregunto si no se duplica el doc por varios items sd2
						//carrego SE1
						aTitulo := {} // array para inclusao de novo título
						aAdd(aTitulo, {"E1_FILIAL" , xFilial("SE1"), Nil})
						aAdd(aTitulo, {"E1_TIPO"   , 'NF ', Nil})
						aAdd(aTitulo, {"E1_PREFIXO", aSe1Cxc[i][3], Nil})
						aAdd(aTitulo, {"E1_NUM"    , aSe1Cxc[i][2], Nil})
						aAdd(aTitulo, {"E1_PARCELA", "  ", Nil})
						aAdd(aTitulo, {"E1_CLIENTE", aSe1Cxc[i][4], Nil})
						//aAdd(aTitulo, {"E1_CLIENTE", "CL0002", Nil})
						aAdd(aTitulo, {"E1_LOJA"   , aSe1Cxc[i][5], Nil})
						aAdd(aTitulo, {"E1_NATUREZ", "VENTAS    ", Nil})
						aAdd(aTitulo, {"E1_EMISSAO", aSe1Cxc[i][6], Nil})
						aAdd(aTitulo, {"E1_VENCTO" , aSe1Cxc[i][6], Nil})
						aAdd(aTitulo, {"E1_VENCREA" , aSe1Cxc[i][6], Nil})
						aAdd(aTitulo, {"E1_VLCRUZ" , aSe1Cxc[i][7], Nil})
						aAdd(aTitulo, {"E1_VALOR" , aSe1Cxc[i][7], Nil})

						cAuxDoc = cDocSe
						MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo, 3)

						If lMsErroAuto

							MostraErro()

						Else

							AutoGrLog( " Titulo CXC generado: " + aSe1Cxc[i][2] + "/ A" + "/" + aSe1Cxc[i][4])

						Endif

					endif
				endif
			next i
		endif
	endif
return
//Erick Etcheverry corr de transf
static function fCorTrans(cSeriex)
	Local _cRet		:= ""
	Local _aArea	:= GetArea()
	Local _cQuery	:= ""

	_cQuery := " SELECT COALESCE(MAX(F2_DOC),0) AS MAXSEQ "
	_cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
	_cQuery += " WHERE F2_ESPECIE = 'RTS' "
	_cQuery += " AND F2_SERIE = '" + ALLTRIM(cSeriex) + "' "
	_cQuery += " AND F2_TIPODOC = 54 "
	_cQuery += " AND F2_FILIAL = '" + xFilial("SF2") + "' "
	_cQuery += " AND SF2.D_E_L_E_T_ = ' ' "

	If Select("strSQL")>0
		strSQL->(dbCloseArea())
	End
	TcQuery _cQuery New Alias "strSQL"

	if valtype(strSQL->MAXSEQ) == 'N'
		_cRet := StrZero(strSQL->MAXSEQ + 1, 13)
	ELSE
		_cRet := StrZero(Val(strSQL->MAXSEQ) + 1, 13)
	ENDIF

	RestArea(_aArea)
Return _cRet
