<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈매출현황 > null > 렌탈매출현황상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
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
				rowIdField : "_$uid",
				showFooter : true,
				footerPosition : "top",
				showRowNumColumn: true
			};
			
			// 아래 항목으로 표시하기로함(2020-08-18 회의)
			// 확정컬럼 : 소유센터, 관리센터, 메이커, 모델명, 차대번호, 가동시간, 연식, 렌탈매출총액, 감가총액, 수리비총액, 가동률, 고객명, 휴대폰, 렌탈시간, 렌탈종료, 렌탈기간, 렌탈금액
			// 렌탈 고객, 시작 종료  가장최신것만
			var columnLayout = [
				{ 
					dataField : "inout_doc_type_no", 
					visible : false,
				},
				{ 
					dataField : "rental_doc_no", 
					visible : false,
				},
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
					width : "6%", 
					style : "aui-center"
				},
				{
					dataField : "maker_cd", 
					visible : false,
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name",  
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "boday_no", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "엔진번호", 
					dataField : "engine_model_1", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "연식", 
					dataField : "made_year", 
					width : "4%", 
					style : "aui-center",
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour",					
					width : "4%", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "가동율", 
					dataField : "util_rate", 
					width : "4%", 
					style : "aui-center",
					dataType : "numeric",
					postfix : "%",
					formatString : "#,##0.##",
				},
				{ 
					headerText : "번호판번호", 
					dataField : "mreg_no",
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "렌탈시작", 
					dataField : "rental_first_st_dt", 
					formatString : "yyyy-mm-dd",
					dataType : "date",   
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈종료", 
					dataField : "rental_first_ed_dt",
					formatString : "yyyy-mm-dd",
					dataType : "date",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈기간", 
					dataField : "day_cnt",
					width : "5%", 
					style : "aui-center",
					dataType : "numeric"
				},
				{ 
					headerText : "렌탈금액", 
					dataField : "total_rental_amt",
					width : "6%", 
					style : "aui-right aui-popup",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "연장시작", 
					dataField : "rental_ex_st_dt",
					formatString : "yyyy-mm-dd",
					dataType : "date",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "연장종료", 
					dataField : "rental_ex_ed_dt",
					formatString : "yyyy-mm-dd",
					dataType : "date",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "연장금액", 
					dataField : "total_rental_ex_amt",
					width : "6%", 
					style : "aui-right aui-popup",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "연장횟수", 
					dataField : "rental_depth",
					width : "4%", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "렌탈합계",
					positionField : "day_cnt",
					style : "aui-center aui-footer",
				},
				{
					dataField : "total_rental_amt",
					positionField : "total_rental_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					labelText : "연장합계",
					positionField : "rental_ex_ed_dt",
					style : "aui-center aui-footer",
				},
				{
					dataField : "total_rental_ex_amt",
					positionField : "total_rental_ex_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];
		
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, listJson);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.resize(auiGrid);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				//그리드 선택 값에 따라 매출처리상세팝업 호출
				if(event.dataField == "total_rental_amt" || event.dataField == "total_rental_ex_amt") {
					if(event.value == 0) {
						return;
					};
					var param = {
						"inout_doc_no" : event.item.inout_doc_no,
		            }
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});			
		}
		
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈매출현황상세", exportProps);
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
					<h4>렌탈매출현황상세</h4>	
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary">${total_cnt}</strong>건
					</div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->	
</form>
</body>
</html>