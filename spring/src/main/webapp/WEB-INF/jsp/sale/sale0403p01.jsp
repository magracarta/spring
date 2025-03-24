<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-과년대비 > null > 집계표
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var currYear = '${endYearMon}'.slice(0,-4);
		var befYear = '${startYearMon}'.slice(0,-4);

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				useGroupingPanel : false,
				// No. 제거
				showRowNumColumn: false,
				groupingFields : ["maker_group"],
				groupingSummary : {
					dataFields : ["tot_curr_cnt", "tot_bef_cnt", "cal_tot_cnt", "curr_yk_out_cnt", "bef_yk_out_cnt", "cal_yk_out_cnt", "curr_yk_rental_cnt", "bef_yk_rental_cnt", "cal_yk_rental_cnt"
								, "curr_etc_rental_cnt", "bef_etc_rental_cnt", "cal_etc_rental_cnt"],
			    },
			    displayTreeOpen : true,
				enableCellMerge : true,
				showBranchOnGrouping : false,
				//푸터 상단 고정
				footerPosition : "top",
				showFooter : true,
				editable : false,

	         	// 그리드 ROW 스타일 함수 정의
	            rowStyleFunction : function(rowIndex, item) {
	            	if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
	                	return "aui-grid-row-depth3-style";
	                }
	                return null;
				}
			};

			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_group",
					width : "10%",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						console.log(item);
						if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
					    	var oldFieldName = item._$sumFieldValue;
					    	var lastChar =  oldFieldName.charAt(oldFieldName.length-1)
					    	var newFieldName = "";

					    	if(lastChar == "S") {
					    		newFieldName = oldFieldName.slice(0,-1) + "소형 합계";
					    	} else if(lastChar == "L") {
					    		newFieldName = oldFieldName.slice(0,-1) + "대형 합계";
					    	} else if(lastChar == "N") {
					    		newFieldName = oldFieldName.slice(0,-1) + " 합계";
					    	};

					    	return newFieldName;
					   	}
						var maker_name = value.replace(/(L|N|S)/g, "");
						return maker_name;
					},
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-left"
				},
				{
					headerText : "총계",
					children : [
						{
							headerText : currYear,
							dataField : "tot_curr_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : befYear,
							dataField : "tot_bef_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : "증감",
							dataField : "cal_tot_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "판매",
					children : [
						{
							headerText : currYear,
							dataField : "curr_yk_out_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : befYear,
							dataField : "bef_yk_out_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : "증감",
							dataField : "cal_yk_out_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "당사렌탈",
					children : [
						{
							headerText : currYear,
							dataField : "curr_yk_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : befYear,
							dataField : "bef_yk_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : "증감",
							dataField : "cal_yk_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
					]
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점렌탈",
					headerText : "위탁판매점렌탈",
					children : [
						{
							headerText : currYear,
							dataField : "curr_etc_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : befYear,
							dataField : "bef_etc_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
						{
							headerText : "증감",
							dataField : "cal_etc_rental_cnt",
							formatString : "#,##0",
 							width : "6%",
							style : "aui-right",
						},
					]
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "전체합계",
					positionField : "machine_name",
					style : "aui-center",
				},
				{
					dataField : "tot_curr_cnt",
					positionField : "tot_curr_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_bef_cnt",
					positionField : "tot_bef_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "cal_tot_cnt",
					positionField : "cal_tot_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "curr_yk_out_cnt",
					positionField : "curr_yk_out_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "bef_yk_out_cnt",
					positionField : "bef_yk_out_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "cal_yk_out_cnt",
					positionField : "cal_yk_out_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "curr_yk_rental_cnt",
					positionField : "curr_yk_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "bef_yk_rental_cnt",
					positionField : "bef_yk_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "cal_yk_rental_cnt",
					positionField : "cal_yk_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "curr_etc_rental_cnt",
					positionField : "curr_etc_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "bef_etc_rental_cnt",
					positionField : "bef_etc_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "cal_etc_rental_cnt",
					positionField : "cal_etc_rental_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];


			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
 			AUIGrid.setGridData(auiGrid, listJson);

		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGridBom, '장비판매현황-과년대비-집계표');
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
				<c:set var="startYearMon" 	value="${startYearMon}"/>
				<c:set var="endYearMon" 	value="${endYearMon}"/>
				<h4><strong>${fn:substring(startYearMon,0,4)}-${fn:substring(startYearMon,4,6)}월</strong> ~ <strong>${fn:substring(endYearMon,0,4)}-${fn:substring(endYearMon,4,6)}월</strong> 조회결과</h4>
				<button type="button" class="btn btn-default" onclick="fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
			</div>

			<div style="margin-top: 5px; height: 450px; width: 100%;" id="auiGrid"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:window.close();">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
