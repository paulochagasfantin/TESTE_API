CREATE PROCEDURE sp_TopRoute_Veiculos(   
 @COD_ROTEIRIZACAO	INT  
 , @COD_VEICULOS		VARCHAR(128)	= 0  
)   
AS  

/*

exec sp_TopRoute_Veiculos 37305 ,4549
exec sp_TopRoute_Veiculos 37305 
exec sp_TopRoute_Veiculos 37305 ,0


*/


IF (OBJECT_ID('TEMPDB..#VEICULOS'))							IS NOT NULL	BEGIN DROP TABLE #VEICULOS						END

SELECT DISTINCT
	VR.COD_ROTEIRIZACAO
	,vei.COD_VEICULOS
	,VEI.DS_VEICULOS
	,CASE WHEN ISNUMERIC(VEI.IDENT_VEICULOS) = 1 THEN RTRIM(LTRIM(CONVERT(VARCHAR(7), CONVERT(INT, VEI.IDENT_VEICULOS)))) ELSE VEI.IDENT_VEICULOS END IDENT_VEICULOS  
	, VR.COD_ROTAS ROTA  
	, QTD_CTRC   = (select count(*) from  tb_documentos_roteirizacao a where a.COD_ROTEIRIZACAO = @COD_ROTEIRIZACAO and  a.COD_VEICULOS  =  vr.COD_VEICULOS)
	, VC.DS_VEICULOS_CLASSE MODELO  
	, VEI.QT_CAPACIDADE_REAL_VEICULOS CAPACIDADE  
	--, CONVERT(BIT, CASE WHEN ISNULL(COD_MCT_VEICULOS, 0) > 0 THEN 1 ELSE 0 END) FL_RASTREADO  
	, VEI.NR_PLACA_VEICULOS AS NR_PLACA  
	,VR.SEQ_VIAGENS_ROTEIRIZACAO AS SEQ_VIAGEM  
	--,VR.COD_VIAGENS_ROTEIRIZACAO  
	,VR.KM_TOTAL_DISTANCE
	INTO #VEICULOS  
FROM TB_VIAGENS_ROTEIRIZACAO   VR (NOLOCK)
	INNER JOIN TB_VEICULOS VEI (NOLOCK)  
		ON  VEI.COD_VEICULOS = VR.COD_VEICULOS  
	INNER JOIN TB_VEICULOS_CLASSE VC (NOLOCK)  
		ON  VC.COD_VEICULOS_CLASSE = VEI.COD_VEICULOS_CLASSE  
WHERE (VEI.COD_VEICULOS  =  @COD_VEICULOS   OR @COD_VEICULOS    = 0) 
 AND VR.COD_ROTEIRIZACAO = @COD_ROTEIRIZACAO



select * from #VEICULOS order by ident_veiculos , SEQ_VIAGEM


