<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 평균매입가확인 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-08-28 10:02:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createLeftAUIGrid();		
			createRightAUIGrid();		
		});
		

		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
					
				rowIdField : "_$uid",
				editable : false,
				showFooter : true,
				footerPosition : "top",
// 				headerHeight : 20,
// 				rowHeight : 11, 
// 				footerHeight : 20,

	  			cellMergeRowSpan:  true,
             		// 셀머지된 경우, 행 선택자(selectionMode : singleRow, multipleRows) 로 지정했을 때 병합 셀도 행 선택자에 의해 선택되도록 할지 여부
              	rowSelectionWithMerge : true,
              	// 그룹핑 패널 사용
              	useGroupingPanel : false,
              	// 차례로 maker_name,part_production_name 순으로 그룹핑을 합니다.
              	groupingFields : [ "maker_stat_name","part_production_name"],
              	// 그룹핑 후 합계필드를 출력하도록 설정합니다.
              	groupingSummary : {
                 	// 합계 필드는 기초재고,총매입,총판매,기말재고에서 사용합니다.
                 	dataFields : ["base_total_amt", "buy_total_amt", "sale_total_amt", "end_total_amt","base_total_qty","buy_total_qty","sale_total_qty","end_total_qty"],
                 	excepts : ["part_production_name"],
                 	// 그룹핑 썸머리 행의 구체적 설정
                 	rows: [
	                      {
	                          operation: "SUM",
	                          text : "$value 소계",
	                          formatString: "#,##0",
	                      },
                  	]                 	
              	},

	             // 그룹핑 썸머리행의 앞부분에 값을 채울지 여부
	             // true 설정하면 그룹핑된 행도 세로 병합이 됨.
	             fillValueGroupingSummary : true,
	             // fillValueGroupingSummary=true 설정 일 때에만 유효
	             // 썸머리 행의 위치를 일괄 적으로 groupingFields 의 마지막 필드에 위치시킬지 여부
	             adjustSummaryPosition : true,
	             // 그룹핑 후 셀 병합 실행
	             enableCellMerge : true,
	             // 브랜치에 해당되는 행을 출력 여부
	             showBranchOnGrouping : false,
	 			 editableOnFixedCell : true,
	             // 그리드 ROW 스타일 함수 정의
	             rowStyleFunction : function(rowIndex, item) {
	                 if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
	                    return "aui-grid-row-depth3-style";
	                 }
	                 return null;
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "분류",
					children : [
						{
							dataField : "maker_stat_name",
							headerText : "메이커",
							width : "65",
							minWidth : "65",
							style : "aui-popup"
							
						}, 
						{
							dataField : "maker_stat_cd",
							visible : false						
						}, 						
						{
							dataField : "part_production_name",
							headerText : "구분",
							width : "100",
							minWidth : "100",
							style : "aui-center",				
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
				                 if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
				                    return null;
				                 }else{
				                	 return "aui-popup";
				                 }		                 		                 
							}
						},
						{
							dataField : "part_production_oke",
							visible : false						
						}, 	
					]
				},
				
				{
					headerText : "기초재고",
					children : [
						{
						    headerText: "수량",
						    dataField: "base_total_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "base_total_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 				
				{
					headerText : "매입",
					children : [
						{
						    headerText: "수량",
						    dataField: "buy_total_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "buy_total_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 			
				{
					headerText : "판매",
					children : [
						{
						    headerText: "수량",
						    dataField: "sale_total_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "sale_total_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 	
				{
					headerText : "기말재고",
					children : [
						{
						    headerText: "수량",
						    dataField: "end_total_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "end_total_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}								
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "part_production_name",
					style : "aui-center aui-footer aui-popup",
				}, 
				{
					dataField : "base_total_amt",
					positionField : "base_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "base_total_qty",
					positionField : "base_total_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "buy_total_amt",
					positionField : "buy_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "buy_total_qty",
					positionField : "buy_total_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "sale_total_amt",
					positionField : "sale_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "sale_total_qty",
					positionField : "sale_total_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "end_total_amt",
					positionField : "end_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "end_total_qty",
					positionField : "end_total_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}				
			];
			
			
			// 그리드 출력
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGridLeft, 4);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.setFooter(auiGridLeft, footerColumnLayout);
			$("#auiGridLeft").resize();
			
			// 푸터 클릭 시 이벤트
			AUIGrid.bind(auiGridLeft, "footerClick", function( event ) {
 				if($M.getValue("s_start_year_mon") == 0){
 					alert("조회 후 진행해주세요.");
 					return false;
 				}
 					
				if(event.footerValue == "합계"){
 					var sYearMon 	= $M.getValue("s_start_year_mon");
 					var prevYearMon = $M.addMonths($M.toDate(sYearMon), -1);
 					
	 				var param = {
	 						s_start_year_mon  		: $M.getValue("s_start_year_mon"),
	 						s_end_year_mon 	  		: $M.getValue("s_end_year_mon"),
	 						s_prev_year_mon  		: $M.dateFormat(prevYearMon, 'yyyyMM'),
	 						s_sort_key 		  		: "part_no ",
							s_sort_method 	  		: "asc"
	 					};
	 				
	 				goSearchDetail(param);  
 				}
			});
			// 클릭 시 이벤트
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				if(event.dataField == "part_production_name" &&  !event.item._$isGroupSumField) { 
 										
 					var sYearMon 	= $M.getValue("s_start_year_mon");
 					var prevYearMon = $M.addMonths($M.toDate(sYearMon), -1);
 					
 					
	 				var param = {
	 						s_start_year_mon  		: $M.getValue("s_start_year_mon"),
	 						s_end_year_mon 	  		: $M.getValue("s_end_year_mon"),
	 						s_prev_year_mon  		: $M.dateFormat(prevYearMon, 'yyyyMM'),
	 						s_maker_stat_cd 		: event.item["maker_stat_cd"],
	 						s_part_production_cd 	: event.item["part_production_oke"],
	 						s_sort_key 		  		: "part_no ",
							s_sort_method 	  		: "asc"
	 					};
	 				
	 				goSearchDetail(param);  
 				
 				}
 				if(event.dataField == "maker_stat_name" ) { 
						
 					var sYearMon 	= $M.getValue("s_start_year_mon");
 					var prevYearMon = $M.addMonths($M.toDate(sYearMon), -1);

	 				var param = {
	 						s_start_year_mon  		: $M.getValue("s_start_year_mon"),
	 						s_end_year_mon 	  		: $M.getValue("s_end_year_mon"),
	 						s_prev_year_mon  		: $M.dateFormat(prevYearMon, 'yyyyMM'),
	 						s_maker_stat_cd 		: event.item["maker_stat_cd"],
	 						s_sort_key 		  		: "part_production_cd asc, part.part_no ",
							s_sort_method 	  		: "asc"
	 					};
	 				
	 				goSearchDetail(param);  
 				
 				}
			});
		}
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableFilter :true,
				editableOnFixedCell : true,
// 				headerHeight : 20,
// 				rowHeight : 11, 
// 				footerHeight : 20,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "120",
					minWidth : "120",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "200",
					minWidth : "200",
					style : "aui-left"
				},
				{
					headerText: "생산구분",
					dataField : "part_production_name",
					style : "aui-center"					
				}, 	
				{
					headerText: "산출구분",
					dataField : "part_output_price_cd",
					style : "aui-center"					
				}, 		
				{
					headerText : "기초재고",
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>기초재고수 * 기준월 평균매입가</div>'
					},
					children : [
						{
						    headerText: "수량",
						    dataField: "base_qty",
							width : "65",
							minWidth : "65",
						    dataType : "numeric",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "base_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 				
				{
					headerText : "매입",
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>매입수량 * 매입가</div>'
					},
					children : [
						{
						    headerText: "수량",
						    dataField: "buy_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "buy_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 			
				{
					headerText : "판매",
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>판매수량 * 단가</div>'
					},
					children : [
						{
						    headerText: "수량",
						    dataField: "sale_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right",
							headerTooltip : { // 헤더 툴팁 표시 HTML 양식
							    show : true,
							    tooltipHtml : '<div>- 일반 : 매출수량<br>- 선주문 : 매출수량</div>'
							},
						}, 
						{
						  	headerText: "금액",
						    dataField: "sale_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}, 	
				{
					headerText : "기말재고",
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>기말재고수 * 기준월 평균매입가</div>'
					},
					children : [
						{
						    headerText: "수량",
						    dataField: "end_qty",
						    dataType : "numeric",
							width : "65",
							minWidth : "65",
						    formatString : "#,##0",
							style : "aui-right"
						}, 
						{
						  	headerText: "금액",
						    dataField: "end_amt",
						    dataType : "numeric",
							width : "95",
							minWidth : "95",
						    formatString : "#,##0",
							style : "aui-right"
						}
					]
				}		
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "part_output_price_cd",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "base_amt",
					positionField : "base_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "base_qty",
					positionField : "base_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "buy_amt",
					positionField : "buy_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "buy_qty",
					positionField : "buy_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "sale_qty",
					positionField : "sale_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "end_amt",
					positionField : "end_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "end_qty",
					positionField : "end_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
			];
			
			
			// 그리드 출력
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGridRight, 4);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);
	
			AUIGrid.setFooter(auiGridRight, footerColumnLayout);
			$("#auiGridRight").resize();
			// 클릭 시 이벤트
 			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
 				
 				if(event.dataField == "part_no") {
 				
					var param = {
 							part_no 			: event.item.part_no,
 							start_year_mon  	: $M.getValue("s_start_year_mon"),
	 						end_year_mon 	  	: $M.getValue("s_end_year_mon")
	 						
 					};	
 				
 					var popupOption = "";
 					$M.goNextPage('/part/part0606p01', $M.toGetParam(param), {popupStatus : popupOption});
 				}
 				
			});
		}

        function fnExcelDownSec() {
			fnExportExcel(auiGridLeft, "부품통계-평균매입가확인-메이커");
        }

        function fnDownloadExcel() {
			fnExportExcel(auiGridRight, "부품통계-평균매입가확인-부품");
        }
		
      	//조회시
	   	function goSearch() {
      		
      		var startMon =  $M.getValue("s_start_mon").length == 1 ? '0'+ $M.getValue("s_start_mon") : $M.getValue("s_start_mon");
      		var endMon = $M.getValue("s_end_mon").length == 1 ? '0'+ $M.getValue("s_end_mon") : $M.getValue("s_end_mon");
      		
      		var startYearMon = $M.getValue("s_start_year") + startMon;
      		var endYearMon = $M.getValue("s_end_year") + endMon;

      		$M.setValue("s_start_year_mon",startYearMon);
      		$M.setValue("s_end_year_mon",endYearMon);
      			
      		
			if($M.checkRangeByFieldName('s_start_year_mon', 's_end_year_mon', true) == false) {				
				return;
			}; 
				
			var sYearMon 	= $M.getValue("s_start_year_mon");
			var prevYearMon = $M.addMonths($M.toDate(sYearMon), -1);
			
			var param = {
					
					s_start_year_mon  		: $M.getValue("s_start_year_mon"),
					s_end_year_mon 	  		: $M.getValue("s_end_year_mon"),
					s_prev_year_mon  		: $M.dateFormat(prevYearMon, 'yyyyMM'),
					s_sort_key 		  		: "maker_cd asc, part_production_cd ",
					s_sort_method 	  		: "asc"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get', timeout : 60 * 15 * 1000},
				function(result) {
					if(result.success) {
						console.log(result.list);
						AUIGrid.setGridData(auiGridLeft, result.list);
						AUIGrid.setGridData(auiGridRight, []);	// 요청예정목록 초기화
					};
				}
			);
		}
        
	  	//그리드셀 클릭시
	   	function goSearchDetail(param) {
			//param값 없으면 return
			if(param == null) {
				alert("선택된 평균매입가 정보가 없습니다.");	 
				return;
			}
			console.log(param);
			$M.goNextPageAjax(this_page + "/searchDetail", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRight, result.list);
					};
				}	
			);
		}
		
	  	// 기준정보 재생성
	  	function goChangeSave() {
			var startMon = $M.getValue("s_start_year") + $M.getValue("s_start_mon").padStart(2, '0');
			var endMon = $M.getValue("s_end_year") + $M.getValue("s_end_mon").padStart(2, '0');
      		
			if(startMon > "${inputParam.s_current_mon}") {
				alert("당월(포함) 이전까지 가능 (입력월: " + $M.getValue("s_start_year") + "년 " + $M.getValue("s_start_mon").padStart(2, '0') + "월)");
				return false;
			}
			
            var param = {
           		"s_start_mon" : startMon,
				"s_end_mon" : endMon
            };
            $M.goNextPageAjax(this_page + "/syncAvgPrice", $M.toGetParam(param), {method: "POST", timeout : 60 * 60 * 1000},
                function (result) {
                    if (result.success) {
                        alert("기준정보 재생성을 완료하였습니다.");
                        window.location.reload();
                    }
                }
            );
	  	}
	  	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
					<input type="hidden" id="s_start_dt" name="s_start_dt" value="">
					<input type="hidden" id="s_end_dt" 	 name="s_end_dt"   value="" >
					<input type="hidden" id="s_start_year_mon" name="s_start_year_mon" value="">
					<input type="hidden" id="s_end_year_mon" 	 name="s_end_year_mon"   value="" >
					
					<div class="search-wrap">				
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="140px">		
								<col width="20px">
								<col width="140px">				
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>기준년월</th>
									<td>		
										<div class="form-row inline-pd">							
											<div class="col-7">
												<select class="form-control" id="s_start_year" name="s_start_year" >
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_start_mon" name="s_start_mon" >
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_mon }">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td class="text-center">~</td>
									<td>
										<div class="form-row inline-pd">							
											<div class="col-7">
												<select class="form-control" id="s_end_year" name="s_end_year" >
													<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
														<option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_end_mon" name="s_end_mon" >
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_mon }">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
									</td>	
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
					<div class="row">
						<div class="col-5">
<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
								<div class="btn-group">
		                            <div class="left" style="margin-left:50px;">
		                                <span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
		                            </div>
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
									</div>
								</div>
							</div>		
							<div style="margin-top: 5px; height: 555px;" id="auiGridLeft"></div>
<!-- /조회결과 -->							
						</div>
						<div class="col-7">
<!-- 부품목록 -->
							<div class="title-wrap mt10">
								<h4>부품목록</h4>
								<div class="btn-group">
								<div class="left" style="margin-left:50px;">
		                                <span style="color: #ff7f00;">※ 평균매입가 상세는 2021년9월 이후 매입/판매 기록 있는 부품만 나옵니다.</span>
		                            </div>
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div style="margin-top: 5px; height: 555px;" id="auiGridRight"></div>
<!-- /부품목록 -->	
						</div>
					</div>
				</div>
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>