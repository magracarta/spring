<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비통합조회 > null > 보유장비현황
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
		});

		// 엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "센터별보유현황");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				// No. 제거
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				editable: false,
				enableMovingColumn: false,
				showFooter: true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText: "모델명",
					dataField: "machine_name",
					width: "20%",
					style: "aui-center"
				},
				{
					headerText: "평택",
					dataField: "pyeongtaek",
					width: "12%",
					style: "aui-center aui-popup"
				},
				{
					headerText: "김해",
					dataField: "gimhae",
					width: "12%",
					style: "aui-center aui-popup",
				},
				{
					headerText: "대구",
					dataField: "daegu",
					width: "12%",
					style: "aui-center aui-popup",
				},
				{
					headerText: "옥천",
					dataField: "okcheon",
					width: "12%",
					style: "aui-center aui-popup",
				},
				{
					headerText: "센터 외",
					dataField: "etc",
					width: "12%",
					style: "aui-center"
				},
				{
					headerText: "합계",
					dataField: "total",
					style: "aui-center"
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText: "합계",
					positionField: "machine_name"
				},
				{
					dataField: "pyeongtaek",
					positionField: "pyeongtaek",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "gimhae",
					positionField: "gimhae",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "daegu",
					positionField: "daegu",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "okcheon",
					positionField: "okcheon",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "etc",
					positionField: "etc",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "total",
					positionField: "total",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				console.log("event : ", event);
				var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=510, left=0, top=0";
				if(event.dataField == 'pyeongtaek' || event.dataField == 'gimhae' || event.dataField == 'daegu' || event.dataField == 'okcheon')  {			
					
					// 보유장비목록 팝업 호출
					var inOrgCode = "";
					
					switch (event.dataField) {
					    case 'pyeongtaek' :
					    	inOrgCode = "5110";
					        break;
					    case 'gimhae' :
					    	inOrgCode = "5200";
					        break;
					    case 'daegu' :
					    	inOrgCode = "5120";
					        break;
					    case 'okcheon' :
					    	inOrgCode = "5240";
					        break;
					}

					var popupOption = "";
					var params = {
						status_cd : 0,  // 임의 값
						machine_name : event.item.machine_name,
						in_org_code : inOrgCode, // 입고센터
						pre_machine_doc_show_yn : 'N' // 지정출고 기능 사용 여부
					};
					$M.goNextPage('/sale/sale0102p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			}); 
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
			<div class="title-wrap">
				<h4>센터별보유현황</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div style="margin-top: 5px; height: 300px; " id="auiGrid"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
			<!-- /상단 폼테이블 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>