<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > null > HOMI관리
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-20 16:06:16
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var partNo = "${inputParam.part_no}";  // 부품번호
	var stockDt = "${inputParam.s_current_dt}";  // 재고일자
	
	// T_PART_HOMI_STOCK 에 저장
	// part_no(부품번호) / warehouse_cd(창고코드) / stock_dt(재고일자) / safe_stock(적정재고)
	
	$(document).ready(function() {
		createAUIGrid();
	});
	
	// 그리드 생성
	function createAUIGrid() {
		var gridPros = {
				rowIdField : "warehouse_cd",
				showRowNumColum : true,
				editable : true,
				// 수정 표시
				showStateColumn : true
		};
		
		var columnLayout = [
			{
				dataField : "warehouse_cd",
				visible : false
			},
			{
				dataField : "stock_dt",
				visible : false
			},
			{
				headerText : "창고명",
				dataField : "code_name",
				width : "70%",	
				style : "aui-center",
				editable : false
			},
			{
				headerText : "적정재고",
				dataField : "safe_stock",
				width : "30%",
				style : "aui-center",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return value == "" || value == null ? "0" : value;
				},
			}
		];	
	
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
		$("#total_cnt").html(${total_cnt});
	}

	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 저장
	function goSave() {
		var partNoArr = [];  // 부품번호
		var warehouseCdArr = []; // 창고코드
		var stockDtArr = [];  // 재고일자
		var safeStockArr = [];  // 적정재고

		// 수정된 행 정보 가져오기
		var rows = AUIGrid.getEditedRowColumnItems(auiGrid);
		
		// 수정된 행을 #으로 묶는 작업
		for (var item in rows) {
			rows[item].part_no = partNo;
			rows[item].stock_dt = stockDt;
			
			partNoArr.push(rows[item].part_no);   // 부품번호
			warehouseCdArr.push(rows[item].warehouse_cd); // 창고코드
			stockDtArr.push(rows[item].stock_dt); // 재고일자
			safeStockArr.push(rows[item].safe_stock); // 적정재고
		}

		var param = {
			"part_no_str" : $M.getArrStr(partNoArr),
			"stock_dt_str" : $M.getArrStr(stockDtArr),
			"warehouse_cd_str" : $M.getArrStr(warehouseCdArr),
			"safe_stock_str" : $M.getArrStr(safeStockArr)
		};
		
		$M.goNextPageAjaxSave(this_page +"/save", $M.toGetParam(param), {method : 'POST'}, 
			function(result) {
				if(result.success) {
					self.location.reload();
				};
			}
		);
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>						
				<div id="auiGrid" style="margin-top: 5px; height:440px; width:100%;"></div>
			</div>
			<div class="btn-group mt5">
				<div class="btn-group">	
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>	
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>		
			</div>
<!-- /폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>