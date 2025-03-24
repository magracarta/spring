<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비현황 > null > 렌탈장비현황상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/ykRentFormula.js"></script>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				showRowNumColumn: true
			};
			// 아래 항목으로 표시하기로함(2020-08-18 회의)
			// 확정컬럼 : 소유센터, 관리센터, 메이커, 모델명, 차대번호, 가동시간, 연식, 매입일자, 매입종류, 운영월수, 운영년수, 매입가, 장비가액, 렌탈매출총액, 감가총액, 수리비총액, 가동률
			var columnLayout = [
				{ 
					headerText : "소유센터", 
					dataField : "own_org_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name", 
					width : "5%", 
					style : "aui-center"
				},
				{
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name",  
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "13%", 
					style : "aui-center"
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour",					
					width : "6%", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "연식", 
					dataField : "made_dt",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "매입일자", 
					dataField : "buy_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "매입종류", 
					dataField : "buy_type_un",
					width : "6%", 
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						return value == "U" ? "중고" : "신차";
					},
					style : "aui-center"
				},
				{ 
					headerText : "번호판번호", 
					dataField : "mreg_no",
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "운영월수", 
					dataField : "op_month", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "운영년수", 
					dataField : "op_year", 
					width : "6%", 
					style : "aui-center",
					dataType : "numeric"
				},
				{ 
					headerText : "매입가", 
					dataField : "buy_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-right"
				},
				{ 
					headerText : "장비가액", 
					dataField : "machine_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-right"
				},
				{ 
					headerText : "렌탈매출총액", 
					dataField : "rental_sale", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-right"
				},
				{ 
					headerText : "감가총액", 
					dataField : "total_reduce_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-right"
				},
				{ 
					headerText : "수리비총액", 
					dataField : "rental_repair_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%", 
					style : "aui-right"
				},
				{ 
					headerText : "가동률", 
					dataField : "util_rate", 
					width : "7%", 
					style : "aui-center"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			var list = ${list}
			var cnt = 0; 
			if (list != "" && list != undefined && list != null) {
				cnt = list.length;
				for (var i = 0; i < cnt; ++i) {
					var diff = $M.getDiff("${inputParam.s_current_dt}", list[i].buy_dt);
					var opMonth = fnCeil((diff/30), -1);
					list[i].op_month = opMonth;
					list[i].op_year = fnCeil((opMonth/12), -1);
				}
			}
			AUIGrid.setGridData(auiGrid, list);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			$("#total_cnt").html(cnt);
			$("#auiGrid").resize();
		}
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비현황상세", exportProps);
	    }
		
		// 닫기
	    function fnClose() {
	    	window.close();
	    }
		
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>렌탈장비현황상세</h4>	
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>