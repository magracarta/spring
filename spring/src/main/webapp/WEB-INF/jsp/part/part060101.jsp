<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품판매현황-기간별 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 16:18:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			goSearch();
		});
		
		// 부품판매현황-기간별 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_dt 			: $M.getValue("s_start_dt"),
				s_end_dt 			: $M.getValue("s_end_dt")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품판매현황-기간별(월간)", "");
		}

		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
			    displayTreeOpen : true,
				showBranchOnGrouping : false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
              	groupingFields : ["maker_stat_name", "part_production_oke"],
              	groupingSummary : {
                	// 합계 필드는 기초재고,총매입,총판매,기말재고에서 사용합니다.
                	dataFields : ["maker_stat_cd", "in_amt", "part_amt", "part_origin_amt", "part_profit_rate", "part_profit_amt", "part_profit_rate", "svc_amt", "svc_origin_amt", "svc_profit_amt", 
                 				  "svc_profit_rate", "sale_amt", "sale_origin_amt", "sale_profit_amt", "sale_profit_rate", "org_amt_sum", "org_origin_amt_sum", 
                 				   "org_profit_amt_sum", "org_profit_rate_sum", "svc_free_origin_amt", "mch_out_origin_amt", "tot_origin_amt"],
                 	excepts : ["part_production_oke"],
                 	
                 	rows: [{
                        
                    	// items (Array) : 소계의 대상이 되는 행들
                   		expFunction : function(items, dataField) {
                        	var sum = 0;
                           	var cnt = 0;
                           
                           	var amtSum 			= 0;	// 매출
                           	var originAmtSum 	= 0;	// 원가
						   	var profitRateSum	= 0;	// 이익율
                           
                           	switch(dataField) {
                           		case "part_profit_rate":
                           			var subTotalNum = 0;
                              		var profitAmtSum = 0;
                              		var amtSum = 0;
                              			
                                   	items.forEach(function(item) {
                                   		amtSum += Number(item.part_amt);
   										profitAmtSum += Number(item.part_profit_amt);
                                     });    
                                   	
                                   	subTotalNum = (Number(profitAmtSum)) / Number(amtSum) * Number(100);       
                                	subTotalNum = AUIGrid.formatNumber(subTotalNum, "#,##0");       
								return isNaN(subTotalNum) ? 0 : subTotalNum;
                                	
                           		case "svc_profit_rate":
                           			var subTotalNum = 0;
                           			var profitAmtSum = 0;
                           			var amtSum = 0;
                           			
                                	items.forEach(function(item) {
                                		amtSum += Number(item.svc_amt);
										profitAmtSum += Number(item.svc_profit_amt);
                                  	});
                                	
                        			subTotalNum = (Number(profitAmtSum)) / Number(amtSum) * Number(100);       
                                	subTotalNum = AUIGrid.formatNumber(subTotalNum, "#,##0");
                                return isNaN(subTotalNum) ? 0 : subTotalNum;
                                
                           		case "sale_profit_rate":
                           			var subTotalNum = 0;
                           			var profitAmtSum = 0;
                           			var amtSum = 0;
                           			
                                	items.forEach(function(item) {
                                		amtSum += Number(item.sale_amt);
										profitAmtSum += Number(item.sale_profit_amt);
                                  	});
                                	
                                	subTotalNum = (Number(profitAmtSum)) / Number(amtSum) * Number(100);       
                                	subTotalNum = AUIGrid.formatNumber(subTotalNum, "#,##0");       
                                return isNaN(subTotalNum) ? 0 : subTotalNum;
                                
                           		case "org_profit_rate_sum":
                           			var subTotalNum = 0;
                           			var profitAmtSum = 0;
                           			var amtSum = 0;
                           			
                                	items.forEach(function(item) {
                                		amtSum += Number(item.org_amt_sum);
										profitAmtSum += Number(item.org_profit_amt_sum);
                                  	});
                                	
                                	subTotalNum = (Number(profitAmtSum)) / Number(amtSum) * Number(100);       
                                	subTotalNum = AUIGrid.formatNumber(subTotalNum, "#,##0");       
                                return isNaN(subTotalNum) ? 0 : subTotalNum;

                           		case "maker_stat_cd":
                           			var value = "";
                                	items.forEach(function(item) {
                                		value = item.maker_stat_cd;
                                  	});
                                	       
                                return isNaN(value) ? 0 : value;

								default:
                                var itemName = dataField;                           
                                items.forEach(function(item) {      
                                   // 나머지 컬럼 합계
                                   sum +=  Number(item[itemName]);                                                                                       
                                });                                    
                                return isNaN(sum) ? '' : sum;                                    
                           }
                        }
                     }]
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
							headerText : "메이커",
							dataField : "maker_stat_name",
							width : "70",
							minWidth : "70",
							style : "aui-center",
						}, 
						{
							dataField : "maker_stat_cd",
							visible : false,		
						}, 
						{
							headerText : "구분",
							dataField : "part_production_oke",
							width : "85",
							minWidth : "85",
							style : "aui-center aui-popup",
						},
					]
				},
				{
				    headerText: "기간매입",
				    dataField: "in_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
					headerText : "계",
					children : [
						{
							headerText : "매출",
							dataField : "org_amt_sum",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "90",
							minWidth : "90",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						}, 
						{
							headerText : "원가",
							dataField : "org_origin_amt_sum",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "90",
							minWidth : "90",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "이익",
							dataField : "org_profit_amt_sum",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "90",
							minWidth : "90",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "%",
							dataField : "org_profit_rate_sum",
							formatString : "#,##0",	
							width : "30",
							minWidth : "30",
							style : "aui-center",
						},
					]
				},
				{
					headerText : "부품부판매",
					children : [
						{
							headerText : "매출",
							dataField : "part_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						}, 
						{
							headerText : "원가",
							dataField : "part_origin_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "이익",
							dataField : "part_profit_amt",
							dataType : "numeric",
							formatString : "#,##0",
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "%",
							dataField : "part_profit_rate",
							formatString : "#,##0",
							width : "30",
							minWidth : "30",
							style : "aui-center",
						},
					]
				},
				{
					headerText : "서비스판매",
					children : [
						{
							headerText : "매출",
							dataField : "svc_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						}, 
						{
							headerText : "원가",
							dataField : "svc_origin_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "이익",
							dataField : "svc_profit_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "%",
							dataField : "svc_profit_rate",
							formatString : "#,##0",	
							width : "30",
							minWidth : "30",
							style : "aui-center",
						},
					]
				},
				{
					headerText : "마케팅판매",
					children : [
						{
							headerText : "매출",
							dataField : "sale_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						}, 
						{
							headerText : "원가",
							dataField : "sale_origin_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "이익",
							dataField : "sale_profit_amt",
							dataType : "numeric",
							formatString : "#,##0",	
							width : "85",
							minWidth : "85",
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
							},
						},
						{
							headerText : "%",
							dataField : "sale_profit_rate",
							formatString : "#,##0",
							width : "30",
							minWidth : "30",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "서비스",
				    dataField: "svc_free_origin_amt",
					dataType : "numeric",
					formatString : "#,##0",	
					width : "85",
					minWidth : "85",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
				    headerText: "기본출하",
				    dataField: "mch_out_origin_amt",
					dataType : "numeric",
					formatString : "#,##0",	
					width : "85",
					minWidth : "85",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
				{
				    headerText: "총원가",
				    dataField: "tot_origin_amt",
					dataType : "numeric",
					formatString : "#,##0",	
					width : "95",
					minWidth : "95",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, map) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "part_production_oke",
					style : "aui-center aui-footer aui-popup",
				}, 
				{
					dataField : "in_amt",
					positionField : "in_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_amt",
					positionField : "part_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_origin_amt",
					positionField : "part_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_amt",
					positionField : "part_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_rate",
					positionField : "part_profit_rate",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[2];
						var originAmtSum = footerValues[3];
						
						var profitRateSum = (Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100);
						profitRateSum = AUIGrid.formatNumber(profitRateSum, "#,##0");
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "svc_amt",
					positionField : "svc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_origin_amt",
					positionField : "svc_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_profit_amt",
					positionField : "svc_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_profit_rate",
					positionField : "svc_profit_rate",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[6];
						var originAmtSum = footerValues[7];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						profitRateSum = AUIGrid.formatNumber(profitRateSum, "#,##0");
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_origin_amt",
					positionField : "sale_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_amt",
					positionField : "sale_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_rate",
					positionField : "sale_profit_rate",
					// operation : "SUM",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[10];
						var originAmtSum = footerValues[11];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "org_amt_sum",
					positionField : "org_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_origin_amt_sum",
					positionField : "org_origin_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_amt_sum",
					positionField : "org_profit_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_rate_sum",
					positionField : "org_profit_rate_sum",
					// operation : "SUM",
					formatString : "#,##0",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[14];
						var originAmtSum = footerValues[15];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					style : "aui-center aui-footer",
				},
				{
					dataField : "svc_free_origin_amt",
					positionField : "svc_free_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "mch_out_origin_amt",
					positionField : "mch_out_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_origin_amt",
					positionField : "tot_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// AUIGrid.setFixedColumnCount(auiGrid, 3);
			$("#auiGrid").resize();
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_production_oke") {
 					var part_production_oke = event.item.part_production_oke;

 					// 임시처리 수정예정
 	                if(event.item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
 	                	part_production_oke = "계";
	                };
 					var param = {
						"s_start_dt" 			: $M.getValue("s_start_dt"),
						"s_end_dt" 				: $M.getValue("s_end_dt"),
 						"part_production_oke"	: part_production_oke,
 						"maker_stat_cd"			: event.item.maker_stat_cd,
 						"maker_stat_name"		: event.item.maker_stat_name,
 	                }
 		
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0601p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
			});
			
 			// 푸터 클릭 bind
 			AUIGrid.bind(auiGrid, "footerClick", function(event) {
 					var param = {
 							"s_start_dt" 			: $M.getValue("s_start_dt"),
 							"s_end_dt" 				: $M.getValue("s_end_dt"),
 	 						"part_production_oke"	: "계",
//  	 						"maker_stat_cd"			: event.item.maker_stat_cd,
 	 						"maker_stat_name"		: "합계",
 	 	                }
 	 		
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0601p01", $M.toGetParam(param), {popupStatus : popupOption});
 			});
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_start_dt", "s_end_dt"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 기준정보 재생성
        function goChangeSave() {
            var param = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
            };
            $M.goNextPageAjax("/part/part0601/change/save", $M.toGetParam(param), {method: "POST"},
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
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="260px">
								<col width="">
								<col width="">
							</colgroup>
							<tbody>
								<tr>								
									<th>조회기간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5" >
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
														name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" 
														value="${not empty inputParam.s_search_start_dt ? inputParam.s_search_start_dt : searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5" >
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_end_dt" 
															name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" 
															value="${not empty inputParam.s_search_end_dt ? inputParam.s_search_end_dt : searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
									<td class="text-warning text-right">
										<span class="pr15">※  이익률(%) = (매출-원가)/매출*100</span>
										<span>※  총원가 = 계(원가) + 서비스 + 기본출하<!--  (단위:천원) --></span>
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
							<div class="left" style="margin-left:50px;">
                                <span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
                            </div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- 도움말 -->
					<div class="alert alert-secondary mt10">
						<i class="material-iconserror font-16 v-align-middle"></i>
						<span class="text-warning">※  2016년 이전 자료는 집계기준변경으로 인해 실제와 다를 수 있습니다.</span>
					</div>
<!-- /도움말 -->
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>