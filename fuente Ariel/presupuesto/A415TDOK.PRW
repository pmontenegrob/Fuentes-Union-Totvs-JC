#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#Define ENTER  Chr(10) + Chr (13)
User Function A415TDOK()

Local nValTT := 0
Local nValAC := 0
Local lPgAC  := .F.
Local cPgAC  := ""
Local nMinAC := GetNewPar("MV_UMINAC",1000)
Local dDataH := dDataBase
Local lCondE := .F.

// Mapeamos las tablas manualmente (PVI?006, PVP?007) - CAMBIO
If M->CJ_TABELA == "004"
    lCondE := .T.
    cPgAC := "006"
ElseIf M->CJ_TABELA == "005"
    lCondE := .T.
    cPgAC := "007"
EndIf

// Si la moneda no es la principal, ajustamos el mínimo
If M->CJ_MOEDA == 1 
    While !SM2->(dbSeek(Dtos(dDataH)))
        dDataH -= 1
    EndDo
    nMinAC := nMinAC * SM2->M2_MOEDA2
EndIf

// Sumamos valores desde TMP1 (detalle del pedido)
dbSelectArea("TMP1")
dbGotop()
While !Eof()
    nValTT += TMP1->CK_VALOR
    nValAC += TMP1->CK_VALORAC * 0.85
    dbSkip()
EndDo

// Si no cumple el mínimo, no se aplica
If lCondE .And. nValTT < nMinAC
    MsgStop("Condición de precio especial para montos mayores a "+cValToChar(TRANSFORM(nMinAC,"@E 99,999,999.99")))
    Return(.F.)
EndIf

// Si cumple monto y tabla aplica, se ofrece aplicar
If lCondE .And. nValTT >= nMinAC

    If AllTrim(Posicione("SE4",1,xFilial("SE4")+M->CJ_CONDPAG,"E4_COND")) == "0"
        Aviso("AVISO","El cliente cumple con la condición para una venta con precio especial al contado" + ENTER + ;
              "MONTO ACTUAL:" + cValToChar(TRANSFORM(nValTT,"@E 99,999,999.99")) + ENTER + ;
              "MONTO NUEVO:" + cValToChar(TRANSFORM(nValAC,"@E 99,999,999.99")) + ENTER + ;
              "AHORRO:" + cValToChar(TRANSFORM(nValTT-nValAC,"@E 99,999,999.99")),{'Ok'},,,,,.t.)
        lPgAC := .T.
    Else
        lPgAC := MsgYesNo("El cliente cumple con la condición para una venta con precio especial al contado" + ENTER + ;
                 "¿Desea aplicar precio especial?" + ENTER + ;
                 "MONTO ACTUAL:" + cValToChar(TRANSFORM(nValTT,"@E 99,999,999.99")) + ENTER + ;
                 "MONTO NUEVO:" + cValToChar(TRANSFORM(nValAC,"@E 99,999,999.99")) + ENTER + ;
                 "AHORRO:" + cValToChar(TRANSFORM(nValTT-nValAC,"@E 99,999,999.99")), "Atención")
    EndIf
EndIf

// Si se aceptó el cambio, actualizamos la tabla y los valores del pedido
If lPgAC
    M->CJ_TABELA  := cPgAC
  
    dbSelectArea("TMP1")
    dbGotop()
    While !Eof()
        RecLock("TMP1",.F.)
        TMP1->CK_PRUNIT  := TMP1->CK_PRUNIAC + 100 
        TMP1->CK_PRCVEN  := TMP1->CK_PRCVEAC + 100
        TMP1->CK_VALDESC := TMP1->CK_VALDEAC  + 10
        TMP1->CK_VALOR   := TMP1->CK_VALORAC  
        MsUnLock()
        dbSkip()
    EndDo
EndIf

Return(.T.)
