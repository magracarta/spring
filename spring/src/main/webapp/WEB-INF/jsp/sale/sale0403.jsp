<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-과년대비 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var monthList 	= ${months};
		var curYear 	= "${inputParam.s_current_year}";
		var beforeYear 	= ("${inputParam.s_current_year}" - 1).toString();
		
		$(document).ready(function() {
			fnSetDateInit();
			createAUIGrid();
			goSearch();
			
			console.log("originStartYear : ", $M.getValue("originStartYear"));
			console.log("originStartMon : ", $M.getValue("originStartMon"));
			console.log("originEndYear : ", $M.getValue("originEndYear"));
			console.log("originEndMon : ", $M.getValue("originEndMon"));
		});
		
		function fnSetDateInit() {
			var year 		= $M.dateFormat("${inputParam.s_current_mon}", "yyyy");
			var mon 		= $M.dateFormat("${inputParam.s_current_mon}", "MM");
			
			console.log("year : ", year);
			console.log("mon : ", mon);
			
			// 에러나서 수정함 by 김태훈 2021-01-06
			if (mon.startsWith("0")) {
				mon = mon.substring(1);
			}
			console.log(mon);

			var date = new Date();
			var mm = date.getMonth()+1;
			var mm2 = date.getMonth();
			
			// 현재 1월일경우 에러나서 수정. 220106 김상덕
			var endYear = year;
			if (mm2 == "0") {
				endYear = Number(endYear) - 1;
				mm2 = "12";
			}
			
			console.log(mm);
			console.log(mm2);
			
			$M.setValue("s_start_year", 	Number(year)-1);
			$M.setValue("s_start_mon", 		mm);	
			$M.setValue("s_end_year", 		endYear);
			$M.setValue("s_end_mon", 		mm2);

// 			$M.setValue("s_start_year", 	$M.getValue("originStartYear"));
// 			$M.setValue("s_start_mon", 		$M.getValue("originStartMon"));
// 			$M.setValue("s_end_year", 		$M.getValue("originEndYear"));
// 			$M.setValue("s_end_mon", 		$M.getValue("originEndMon"));
		}
		
		
		function goCurSearch() {
			var mon = $M.getValue("s_end_mon");
			
			if(mon.toString().length == 1) {
				mon = '0' + mon;
			};
			
			var yearMon		 = $M.getValue("s_end_year") + mon;
			var startYearMon = $M.dateFormat($M.addMonths($M.toDate(yearMon), -12), "yyyyMM");
			
			$M.setValue("s_start_year"	, startYearMon.substring(0,4));
			$M.setValue("s_start_mon"	, Number(startYearMon.substring(4,6)));
			
			goSearch();
		}

		function goYkSearch() {
			// 현재년 기준 : 시작(작년 12월) ~ 종료(올해 11월))
			$M.setValue("s_start_year", 	"${inputParam.s_current_year}" -1);
			$M.setValue("s_start_mon", 		"12");
			$M.setValue("s_end_year", 		${inputParam.s_current_year});
			$M.setValue("s_end_mon", 		"11");
			goSearch();
			
		}
		
		function goSearch() {
			console.log("s_start_year : ", $M.getValue("s_start_year"));
			console.log("s_start_mon : ", $M.getValue("s_start_mon"));
			
			var yearMon = fnGetYearMon();
			
			var startYearMon = yearMon.startYearMon; 
			var endYearMon	 = yearMon.endYearMon;

			if($M.toNum(startYearMon) - $M.toNum(endYearMon) < -100) {
				alert("검색 기간은 최대 1년까지 가능합니다.");
				return;
			};

			if($M.nvl(startYearMon, "") == "" ||  $M.nvl(endYearMon, "") == "") {
				alert("조회년월을 확인해 주세요.");
				return;
			};
	
			var param = {
				s_start_dt 	: startYearMon,
				s_end_dt 	: endYearMon,
				s_sale_type	: $M.getValue("s_sale_type"),  // 02:본사렌탈, 03:대리점렌탈, 01:순수판매
			};
			
			console.log(param);
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						monthList = result.months;
						destroyGrid();
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);

						$M.setValue("st_curr_year_mon", result.st_curr_year_mon);
						$M.setValue("ed_curr_year_mon", result.ed_curr_year_mon);
						$M.setValue("st_be_year_mon", result.st_be_year_mon);
						$M.setValue("ed_be_year_mon", result.ed_be_year_mon);
					};
				}
			);
		}
		
		function fnGetYearMon() {
			
			var startMon 	=  $M.getValue("s_start_mon");
			var endMon 		=  $M.getValue("s_end_mon");

			console.log("startMon 1 : ", startMon);
			console.log("endMon 1 : ", endMon);
			
			if(startMon.toString().length <= 1) {
				startMon = '0' + startMon;
			};
			
			if(endMon.toString().length <= 1) {
				endMon = '0' + endMon;				
			};
			
			console.log("startMon 2 : ", startMon);
			console.log("endMon 2 : ", endMon);

			return {
				"startYearMon" : $M.getValue("s_start_year") + startMon,
				"endYearMon"   : $M.getValue("s_end_year") + endMon,
			};
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '장비판매현황 - 과년대비');
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		};
		
		//그리드생성
		function createAUIGrid() {
			// 그리드 데이터필드 저장
			var dataFieldArr = ["a_current_year_cnt", "a_before_year_cnt", "a_current_mon_cnt", "a_before_mon_cnt"];

			for(var i = 0; i < monthList.length; ++i) {
				dataFieldArr.push(monthList[i].curr_mon_field);
				dataFieldArr.push(monthList[i].be_mon_field);
				dataFieldArr.push(monthList[i].increase_mon_field);
			}
			
			var gridPros = {
				rowIdField : "_$uid",
				// fixedColumnCount : 4,
				footerPosition : "top",
				height : 555,
				headerHeight : 40,
// 				showFooter : true,
				showFooter : false,
// 				groupingFields : ["maker_group"],
//               	groupingSummary : {
//               		dataFields : dataFieldArr,
//                  	excepts : ["machine_name"],
//               	},
			    displayTreeOpen : true,
// 				enableCellMerge : false,
				showBranchOnGrouping : false,
				// 그룹핑 썸머리행의 앞부분에 값을 채울지 여부
	            // true 설정하면 그룹핑된 행도 세로 병합이 됨.
// 	            fillValueGroupingSummary : true,
	            // fillValueGroupingSummary=true 설정 일 때에만 유효
	            // 썸머리 행의 위치를 일괄 적으로 groupingFields 의 마지막 필드에 위치시킬지 여부
// 	            adjustSummaryPosition : true,
	            // 그룹핑 후 셀 병합 실행
	            enableCellMerge : true,
	            // 브랜치에 해당되는 행을 출력 여부
	            showBranchOnGrouping : false,
	            showRowNumColumn: false,
	            useGroupingPanel : false,
	         	// 그리드 ROW 스타일 함수 정의
// 	            rowStyleFunction : function(rowIndex, item) {
// 					if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
// 	                   return "aui-grid-row-depth3-style";
// 	                }
// 	                return null;
// 				}
				// [15324] 틀 고정
				fixedColumnCount : 2,
				// [23426] 총계 틀 고정
				fixedRowCount : 1,

				rowStyleFunction : function(rowIndex, item) {
					if(item.maker_name.indexOf("합계") != -1 || 
							item.maker_name.indexOf("총계") != -1 || 
							item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					} 
					return null;
				}
			};
			var headerText  = $M.dateFormat("${inputParam.s_current_mon}", "yyyy-MM");
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "70",
					minWidth : "25", 
					style : "aui-center",
					cellMerge : true,
// 					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
// 						if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
							
// 					    	var oldFieldName = item._$sumFieldValue;
// 					    	var lastChar =  oldFieldName.charAt(oldFieldName.length-1)
// 					    	var newFieldName = "";

// 					    	if(lastChar == "S") {
// 					    		newFieldName = oldFieldName.slice(0,-1) + "소형 합계";
// 					    	} else if(lastChar == "L") {
// 					    		newFieldName = oldFieldName.slice(0,-1) + "대형 합계";
// 					    	} else if(lastChar == "N") {
// 					    		newFieldName = oldFieldName.slice(0,-1) + " 합계";
// 					    	};
					    	
// 					    	return newFieldName;
// 					   	}
// 						var maker_name = value.replace(/(L|N|S)/g, "");
// 						return maker_name;
// 					},
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "120",
					minWidth : "25",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.machine_name.indexOf("합계") != -1 ) {
							return "aui-center";
						}
						return "aui-left";
					},	
				},
				{ 
					headerText : "합계",
					children: [
						{
							headerText : "당기",
							dataField : "a_current_year_cnt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "45",
							minWidth : "25", 
							style : "aui-right",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value > 0) {
									return "aui-popup";
								}
							},
						},
						{
							headerText : "전기",
							dataField : "a_before_year_cnt", 
							dataType : "numeric",
							formatString : "#,##0",
							width : "45",
							minWidth : "25",
							style : "aui-right",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value > 0) {
									return "aui-popup";
								}
							},
						}
					]
				},
				{ 

					headerText : "당월(" + headerText + ")", 
					children: [
						{
							headerText : curYear.slice(2),
							dataField : "a_current_mon_cnt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "30",
							minWidth : "10",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "aui-grid-row-depth3-style";
								}
								return "aui-popup"
							},
						},
						{
							headerText : beforeYear.slice(2),
							dataField : "a_before_mon_cnt",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "30",
							minWidth : "10",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "aui-grid-row-depth3-style";
								}
								return "aui-popup"
							},
						},
						{
							headerText : "증<br>감",
							dataField : "current_mon_increase",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "35",
							minWidth : "10",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {								
								value = item.a_current_mon_cnt - item.a_before_mon_cnt;
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 ||
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "aui-grid-row-depth3-style";
								}
								return ""
							},
						}
					]
				},
			];	

			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "전체합계",
					positionField : "machine_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "current_year_cnt",
					positionField : "current_year_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "before_year_cnt",
					positionField : "before_year_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "current_mon_cnt",
					positionField : "current_mon_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != 0) {
							return "aui-right aui-footer aui-popup"
						};
					},
				},
				{
					dataField : "before_mon_cnt",
					positionField : "before_mon_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer aui-popup",
				},
				{
					dataField : "current_mon_increase",
					positionField : "current_mon_increase",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];
			
			
			for (var i = 0; i < monthList.length; ++i) {
				
				var obj = {
					headerText : monthList[i].year_text, 
					children: [
						{
							headerText : monthList[i].curr_mon_text,
							dataField : "a_" + monthList[i].curr_mon_field,
							dataType : "numeric",
							formatString : "#,##0",
							width : "35",
							minWidth : "10", 
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "aui-grid-row-depth3-style";
								}
								return "aui-popup"
							},
						},
						{
							headerText : monthList[i].be_mon_text,
							dataField : "a_" + monthList[i].be_mon_field,
							dataType : "numeric",
							formatString : "#,##0",
							width : "35",
							minWidth : "10",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								console.log("item : ", item);
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0) {
									return "aui-grid-row-depth3-style";
								}
								return "aui-popup"
							},
						},
						{
							headerText : "증<br>감",
							dataField : "a_" + monthList[i].increase_mon_field,
							dataType : "numeric",
							formatString : "#,##0",
							width : "35",
							minWidth : "10",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								console.log("value : ", item);
								value = AUIGrid.formatNumber(value, "#,##0");
								if(value == 0 && !item._$isGroupSumField) {
									return "";
								};
								return value;
							},
// 							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {								
// 								value = item.a_current_mon_cnt - item.a_before_mon_cnt;
// 								value = AUIGrid.formatNumber(value, "#,##0");
// 								if(value == 0 && !item._$isGroupSumField) {
// 									return "";
// 								};
// 								return value;
// 							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(item._$isGroupSumField) {
									return "aui-grid-row-depth3-style";
								};
							},
						}
					]
				}
				
				var sumObj1 = {
					dataField : monthList[i].curr_mon_field,
					positionField : monthList[i].curr_mon_field,
					formatString : "#,##0",
					dataType : "numeric",
					operation : "SUM",
					style : "aui-right aui-footer",	
				}
				var sumObj2 = {
					dataField : monthList[i].be_mon_field,
					positionField : monthList[i].be_mon_field,
					formatString : "#,##0",
					dataType : "numeric",
					operation : "SUM",
					style : "aui-right aui-footer",	
				}
				
				var sumObj3 = {
					dataField : monthList[i].increase_mon_field,
					positionField : monthList[i].increase_mon_field,
					formatString : "#,##0",
					dataType : "numeric",
					operation : "SUM",
					style : "aui-right aui-footer",	
				}
				
				columnLayout.push(obj);
				footerColumnLayout.push(sumObj1);
				footerColumnLayout.push(sumObj2);
				footerColumnLayout.push(sumObj3);
			}
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField != 'maker_name' && event.dataField != 'machine_name' && event.headerText != "증<br>감") {
					var eventValue = $M.nvl(event.value, 0);

					if(eventValue == 0) {
						return;
					};
					
					var year_mon;
					if(event.dataField == "a_current_mon_cnt") {
						year_mon = "${inputParam.s_current_mon}";
					} else if (event.dataField == "a_before_mon_cnt") {
						year_mon = $M.dateFormat($M.addDate(new Date(), 'year', -1), 'yyyyMM');
					} else {
						year_mon = event.dataField.slice(4);
					};
					
					var params = {
						"year_mon" 			: year_mon,
						"year_mon_st"		: "",	// 합계 상세조회용
						"year_mon_ed"		: "",	// 합계 상세조회용
						"machine_name" 		: event.item.machine_name,
						"maker_cd" 			: event.item.maker_cd,
						"maker_weight_type"	: event.item.maker_weight_type,
						"rental_yn" 		: 'N',
						"search_mode"		: $M.getValue("s_sale_type") == '' ? '00' : $M.getValue("s_sale_type"),
					};
					if (event.item.machine_name.indexOf("합계") != -1 || event.item.maker_name.indexOf("총계")!= -1 || event.item.maker_name.indexOf("합계") != -1) {
						params.machine_name = "";
					}

					if (event.dataField == 'a_current_year_cnt') {
						params.year_mon = "";
						params.year_mon_st = $M.getValue("st_curr_year_mon");
						params.year_mon_ed = $M.getValue("ed_curr_year_mon");
					}
					if (event.dataField == 'a_before_year_cnt') {
						params.year_mon = "";
						params.year_mon_st = $M.getValue("st_be_year_mon");
						params.year_mon_ed = $M.getValue("ed_be_year_mon");
					}
					
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=600, left=0, top=0";
					$M.goNextPage('/sale/sale0402p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}
		
		function goTotalPopup() {
			
			var yearMon = fnGetYearMon();
			
			var params = {
				"end_year_mon"	: yearMon.endYearMon,
				"end_year"	 	: $M.getValue("s_end_year"),
			};
			console.log(params);
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=600, left=0, top=0";
			$M.goNextPage('/sale/sale0403p01', $M.toGetParam(params), {popupStatus : popupOption});
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="originStartDt" name="originStartDt" value="${originStartDt}">
<input type="hidden" id="originEndDt" name="originEndDt" value="${originEndDt}">
<input type="hidden" id="originStartYear" name="originStartYear" value="${originStartYear}">
<input type="hidden" id="originStartMon" name="originStartMon" value="${originStartMon}">
<input type="hidden" id="originEndYear" name="originEndYear" value="${originEndYear}">
<input type="hidden" id="originEndMon" name="originEndMon" value="${originEndMon}">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="350px">
								<col width="210px">
								<col width="70px">
								<col width="230px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년월</th>	
									<td>
										<div class="form-row inline-pd">
											<div class="col-3">
												<select class="form-control width120px" name="s_start_year" id="s_start_year">
													<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
														<option value="${i}">${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-2">
												<select class="form-control width120px" name="s_start_mon" id="s_start_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>">${i}월</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-1 text-center">~</div>
											<div class="col-3">
												<select class="form-control width120px" name="s_end_year" id="s_end_year">
													<c:forEach var="i" begin="2007" end="${inputParam.s_current_year}" step="1">
														<option value="${i}">${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-3">
												<select class="form-control width120px" name="s_end_mon" id="s_end_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>">${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-primary-gra" style="width: 65px;" onclick="javascript:goCurSearch()">1년</button>
										<button type="button" class="btn btn-primary-gra" style="width: 130px;" onclick="javascript:goYkSearch()">YK기준 12월~11월</button>	
									</td>
									<th>판매유형</th>
									<td>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="radio" id="s_sale_type_00" name="s_sale_type" value="" checked="checked" onclick="javascript:goSearch();">
											<label class="form-check-label" for="s_sale_type_00">전체</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="radio" id="s_sale_type_03" name="s_sale_type" value="03" onclick="javascript:goSearch();">
											<label class="form-check-label" for="s_sale_type_03">본사렌탈</label>
										</div>
<!-- 										<div class="form-check form-check-inline checkline"> -->
<!-- 											<input class="form-check-input" type="radio" id="s_sale_type_02" name="s_sale_type" value="02" onclick="javascript:goSearch();"> -->
<!-- 											<label class="form-check-label" for="s_sale_type_02">대리점렌탈</label> -->
<!-- 										</div> -->
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="radio" id="s_sale_type_01" name="s_sale_type" value="01" onclick="javascript:goSearch();">
											<label class="form-check-label" for="s_sale_type_01">순수판매</label>
										</div>
<!-- 										<select class="form-control" id="s_sale_type" name="s_sale_type" onchange="goSearch();"> -->
<!-- 											<option value=""> - 전체 - </option> -->
<!-- 											<option value="02">본사렌탈</option> -->
<!-- 											<option value="03">대리점렌탈</option> -->
<!-- 											<option value="01">순수판매</option> -->
<!-- 										</select> -->
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>			
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div style="margin-top: 5px; height: 600px; " id="auiGrid"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id=total_cnt>0</strong>건
						</div>	
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>					
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>