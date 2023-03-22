alter PROCEDURE sp_TopRoute_Veiculos(   
 @COD_ROTEIRIZACAO	INT  
 , @COD_VEICULOS		VARCHAR(128)	= 0  
)   
AS  

/*

exec sp_TopRoute_Veiculos 37410
exec sp_TopRoute_Veiculos 37305 ,4549
exec sp_TopRoute_Veiculos 37305 
exec sp_TopRoute_Veiculos 37305 ,0



declare @COD_ROTEIRIZACAO int =37410 
declare @COD_VEICULOS		VARCHAR(128)	= 0  

*/

if (OBJECT_ID('tempdb..#VEICULOS')) is not null begin drop table #VEICULOS   end
if (OBJECT_ID('tempdb..#AUX')) is not null begin drop table #AUX   end

create table #VEICULOS (  
	COD_ROTEIRIZACAO				INT 
	,COD_VEICULOS					INT
	,DS_VEICULOS					VARCHAR(100)
	,IDENT_VEICULOS					VARCHAR(15)
	,ROTA							INT
	,QTD_CTRC						INT
	,MODELO							VARCHAR(100)
	,CAPACIDADE						INT
	,NR_PLACA						CHAR(20)
	,SEQ_VIAGEM						INT
	,KM_TOTAL_DISTANCE				INT
	,QT_CAPACIDADE_PADRAO_VEICULOS	BIGINT
	,QT_CAPACIDADE_REAL_VEICULOS	BIGINT
	,PESOTOTAL						DECIMAL(10,2) default(0)
	,OCUPACAO						INT default(0)
	)





INSERT INTO #VEICULOS(
	COD_ROTEIRIZACAO				
	,COD_VEICULOS					
	,DS_VEICULOS					
	,IDENT_VEICULOS					
	,ROTA							
	,QTD_CTRC						
	,MODELO							
	,CAPACIDADE						
	,NR_PLACA						
	,SEQ_VIAGEM						
	,KM_TOTAL_DISTANCE				
	,QT_CAPACIDADE_PADRAO_VEICULOS	
	,QT_CAPACIDADE_REAL_VEICULOS	)
SELECT DISTINCT
	VR.COD_ROTEIRIZACAO
	,vei.COD_VEICULOS
	,VEI.DS_VEICULOS
	,CASE WHEN ISNUMERIC(VEI.IDENT_VEICULOS) = 1 THEN RTRIM(LTRIM(CONVERT(VARCHAR(7), CONVERT(INT, VEI.IDENT_VEICULOS)))) ELSE VEI.IDENT_VEICULOS END IDENT_VEICULOS  
	, VR.COD_ROTAS ROTA  
	, QTD_CTRC   = (select count(*) from  tb_documentos_roteirizacao a where a.COD_ROTEIRIZACAO = @COD_ROTEIRIZACAO and  a.COD_VEICULOS  =  vr.COD_VEICULOS)
	, VC.DS_VEICULOS_CLASSE MODELO  
	, VEI.QT_CAPACIDADE_REAL_VEICULOS CAPACIDADE  
	, VEI.NR_PLACA_VEICULOS AS NR_PLACA  
	,VR.SEQ_VIAGENS_ROTEIRIZACAO AS SEQ_VIAGEM  

	,VR.KM_TOTAL_DISTANCE
	,QT_CAPACIDADE_PADRAO_VEICULOS
	 ,QT_CAPACIDADE_REAL_VEICULOS 
FROM TB_VIAGENS_ROTEIRIZACAO   VR (NOLOCK)
	INNER JOIN TB_VEICULOS VEI (NOLOCK)  
		ON  VEI.COD_VEICULOS = VR.COD_VEICULOS  
	INNER JOIN TB_VEICULOS_CLASSE VC (NOLOCK)  
		ON  VC.COD_VEICULOS_CLASSE = VEI.COD_VEICULOS_CLASSE  
WHERE (VEI.COD_VEICULOS  =  @COD_VEICULOS   OR @COD_VEICULOS    = 0) 
 AND VR.COD_ROTEIRIZACAO = @COD_ROTEIRIZACAO



 SELECT 
	SUM(PESO) PESO
	, COD_VEICULOS
	, QT_CAPACIDADE_REAL_VEICULOS 
	, [OCUPACAO]  =CASE WHEN  QT_CAPACIDADE_REAL_VEICULOS > 0  THEN 	CEILING((SUM(PESO ) * 100 ) /QT_CAPACIDADE_REAL_VEICULOS) ELSE QT_CAPACIDADE_REAL_VEICULOS END 
	INTO #AUX
FROM (
	 ---ENTREGA
	SELECT
		SUM(C.PESO_CALCULO_CONHECIMENTOS) PESO
		,D.COD_VEICULOS 
		,V.QT_CAPACIDADE_REAL_VEICULOS
		, [OCUPACAO]  =CASE WHEN  V.QT_CAPACIDADE_REAL_VEICULOS > 0  THEN 	CEILING((SUM(C.PESO_CALCULO_CONHECIMENTOS ) * 100 ) /V.QT_CAPACIDADE_REAL_VEICULOS) ELSE V.QT_CAPACIDADE_REAL_VEICULOS END 

	FROM TB_DOCUMENTOS_ROTEIRIZACAO D (NOLOCK)  
		INNER JOIN TB_CONHECIMENTOS C (NOLOCK)  
			 ON  C.COD_CONHECIMENTOS = D.COD_DOCUMENTOS
		INNER JOIN TB_VEICULOS  V (NOLOCK)
			ON V.COD_VEICULOS   =  D.COD_VEICULOS
	WHERE COD_ROTEIRIZACAO =  @COD_ROTEIRIZACAO  
	AND D.COD_VEICULOS IS NOT NULL
	AND D.COD_TIPO_DOCUMENTOS = 1
	GROUP BY D.COD_VEICULOS,V.QT_CAPACIDADE_REAL_VEICULOS

	UNION

	--- COLETA

	SELECT
		SUM(C.PESO_INFORMADO_COLETAS) PESO
		,D.COD_VEICULOS 
		,V.QT_CAPACIDADE_REAL_VEICULOS
		, [OCUPACAO]  =CASE WHEN  V.QT_CAPACIDADE_REAL_VEICULOS > 0  THEN 	CEILING((SUM(C.PESO_INFORMADO_COLETAS ) * 100 ) /V.QT_CAPACIDADE_REAL_VEICULOS) ELSE V.QT_CAPACIDADE_REAL_VEICULOS END 

	FROM TB_DOCUMENTOS_ROTEIRIZACAO D (NOLOCK)  
			INNER JOIN TB_COLETAS C (NOLOCK)  
				ON  C.COD_COLETAS = D.COD_DOCUMENTOS  
		INNER JOIN TB_VEICULOS  V (NOLOCK)
			ON V.COD_VEICULOS   =  D.COD_VEICULOS
	WHERE COD_ROTEIRIZACAO =  @COD_ROTEIRIZACAO  
	AND D.COD_VEICULOS IS NOT NULL
	AND D.COD_TIPO_DOCUMENTOS = 3
	GROUP BY D.COD_VEICULOS,V.QT_CAPACIDADE_REAL_VEICULOS
) AS AGRUPAR
GROUP BY COD_VEICULOS,QT_CAPACIDADE_REAL_VEICULOS



update b set
	b.pesoTotal  = a.peso
	,b.OCUPACAO  =  a.ocupacao
FROM #AUX a 
	inner join #VEICULOS b 
		on a.COD_VEICULOS  =  b.COD_VEICULOS


select * 
from #VEICULOS 
order by ident_veiculos , SEQ_VIAGEM




--SELECT
-- C.PESO_INFORMADO_COLETAS  ,
--	D.* 
--FROM TB_DOCUMENTOS_ROTEIRIZACAO D (NOLOCK)  
--		INNER JOIN TB_COLETAS C (NOLOCK)  
--			ON  C.COD_COLETAS = D.COD_DOCUMENTOS  
--WHERE COD_ROTEIRIZACAO =  37410  
--AND D.COD_VEICULOS IS NOT NULL
--AND D.COD_TIPO_DOCUMENTOS = 3


