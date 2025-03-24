<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > MBO > 센터별 지출/실적 평균지표
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-07 11:48:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var centerList = ${centerList};
		$(document).ready(function () {
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				editable: false,
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				// rowNumber 
				showRowNumColumn: false,
				enableSorting: true,
				rowStyleFunction: function (rowIndex, item) {
					if (item.col.indexOf("누계") != -1) {
						return "aui-grid-selection-row-satuday-bg"
					}

					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "집계내역",
					dataField: "col",
					width: "15%",
				},
				{
					headerText: "1인당 평균 지표",
					dataField: "avg_per_person",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					width: "10%",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
			]

			for (var i = 0; i < centerList.length; ++i) {
				var obj = {
					headerText: centerList[i].org_kor_name,
					dataField: centerList[i].field_name,
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0",
					width: "10%",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				}

				columnLayout.push(obj);
			}

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${centerAmtAvgList});
			// AUIGrid.setFixedColumnCount(auiGrid, 2);
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '센터별 지출/실적 평균지표');
		}

		//닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
	<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	        <div class="main-title">
	        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
	<!-- /타이틀영역 -->
	        <div class="content-wrap">
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			
	<!-- 그리드 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
	<!-- /그리드-->					
				<div class="btn-group mt10">	
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	        </div>
	    </div>
	<!-- /팝업 -->
	</form>
</body>
</html>