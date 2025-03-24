<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 평균매입가확인 > null > 평균매입가확인상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-09-08 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();		
		});

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
	  			cellMergeRowSpan:  true,
         		// 셀머지된 경우, 행 선택자(selectionMode : singleRow, multipleRows) 로 지정했을 때 병합 셀도 행 선택자에 의해 선택되도록 할지 여부
	          	rowSelectionWithMerge : true,
	          	// 그룹핑 패널 사용
	          	useGroupingPanel : false,
				showFooter : true,
// 				groupingFields : ["price_year_mon"],
// 				groupingSummary :{
// 					dataFields : ["in_pay_qty","in_pay_amt","in_free_qty","in_free_amt","in_disposal_qty","in_disposal_amt","out_pay_qty","out_pay_amt","out_free_qty","out_free_amt","out_disposal_qty","out_disposal_amt","in_avg_qty","in_avg_price","in_avg_amt","sale_price","sale_amt","sale_origin_price","sale_margin_amt"],
// 					excepts : ["mng_no", "seq_no"],
// 					rows: [{
// 						// items (Array) 		: 소계의 대상이 되는 행들
// 						// dataField (String) 	: 소계 대상 필드 						
// 						expFunction : function(items, dataField) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
// 							var val = 0;
// 							var cnt = 1;
// 							if(items.seq_no == 2) {
// 								if(dataField == "in_avg_price" || dataField == "in_avg_qty" || dataField == "in_avg_amt") {
// 									items.forEach(function(item) {			
// 										if(cnt == items.length){
// 											val = $M.toNum(item[dataField]);											
// 										} else {
// 											cnt += 1;
// 										}																		
// 									});	
// 								} else {
// 									var itemName = dataField;			
// 									items.forEach(function(item) {		
// 										//속성을 동적으로 사용하는 경우 배열방식으로 접근 ( [] )
// 										val +=  $M.toNum(item[itemName]);		
// 									});		
	
// 								}
// 								return val == 0 ? '' : val;	
// 							}
							
// 							switch(dataField){
// 								//평균매입가관련 정보(평균매입가 , 평균금액(누적).평균매입금액 )는 소계내역의 가장 최근의 정보를 보여줌 (마지막 누적 내역)
// 								case "in_avg_price":																	
// 									items.forEach(function(item) {										
// 										if(cnt == items.length){
// 												val = $M.toNum(item.in_avg_price);											
// 										}
// 										else{
// 											cnt += 1;
// 										}																		
// 									});									
// 									return val;								
// 								case "in_avg_qty":
// 									items.forEach(function(item) {									
// 										if(cnt == items.length){
// 											val = $M.toNum(item.in_avg_qty);											
// 										}
// 										else{
// 											cnt += 1;
// 										}																		
// 									});									
// 									return val;
// 								case "in_avg_amt":
// 									items.forEach(function(item) {
// 										if(cnt == items.length){
// 											val = $M.toNum(item.in_avg_amt);											
// 										}
// 										else{
// 											cnt += 1;
// 										}																		
// 									});																			
// 									return val;
// 								default:
// 									var itemName = dataField;			
// 									items.forEach(function(item) {		
// 										//속성을 동적으로 사용하는 경우 배열방식으로 접근 ( [] )
// 										val +=  $M.toNum(item[itemName]);		
// 									});		

// 									return val == 0 ? '' : val;												
// 							}
// 						}
// 					}]
// 			    },
			    
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
	                 if(item.seq_no != 2) {
	                    return "aui-as-tot-row-style";
	                 }
	                 return null;
				}	             
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "월",
				    dataField: "price_year_mon",
					style : "aui-center",
					cellMerge : true,	
                    cellColMerge: true, // 셀 가로병합
                    cellColSpan: 3, // 셀 가로병합
					width: "65",
					minWidth: "65",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(item.seq_no == 2) {
						    return value.substring(4,6) + "월"; 
						} else {
							return value;
						}
					},
				},
				{
					headerText : "관리번호",
					dataField : "mng_no",
					style : "aui-center",
					width: "95",
					minWidth: "95",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(item.seq_no == 2) {
							value = value.substring(4);
						} else {
							return value;
						}
						
					     return value; 
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.seq_no == 1) {
							return "aui-as-tot-row-style";
						} else if(item.seq_no == 2) {
							if(item["inout_gubun"] != "IN") {
								return "aui-popup";
							} else if (item["inout_gubun"] == "IN" && ${page.add.AVG_PRICE_SHOW_YN eq 'Y'}) {
								return "aui-popup";
							}
						} else {
							return "aui-as-tot-row-style";
						}
						return "aui-center";
					},
				},
				{
					headerText : "구분",
					dataField : "inout_gubun",
					style : "aui-center",
					width: "65",
					minWidth: "65",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var inoutName = value;
						if(item.seq_no == 2) {
							switch(inoutName) {
								case "IN" : inoutName = "매입"; break;
								case "OUT" : inoutName = "매출"; break;
								case "ADJUST" : inoutName = "재고조정"; break;
								case "CUBE" : inoutName = "큐브"; break;
							}
						}
					    return inoutName; 
					},
				},
				{
					headerText : "입고 당시 단가 기준",
					children : [
						{
							headerText : "입고(유상) +",
							children : [
								{
									dataField : "in_pay_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "in_pay_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "in_pay_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						}, 
						{
							headerText : "입고(무상) +",
							children : [
								{
									dataField : "in_free_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "in_free_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "in_free_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						},
					]
				}, 
				{
					headerText : "평균 매입가 변동 기준",
					children : [
						{
							headerText : "입고(폐기) +",
							children : [
								{
									dataField : "in_disposal_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "in_disposal_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "in_disposal_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						}, 
						{
							headerText : "출고(유상) -",
							children : [
								{
									dataField : "out_pay_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									headerTooltip : { // 헤더 툴팁 표시 HTML 양식
									    show : true,
									    tooltipHtml : '<div>- 일반 : 매출수량<br>- 선주문 : 처리수량</div>'
									},
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "out_pay_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "out_pay_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						},
						{
							headerText : "출고(무상) -",
							children : [
								{
									dataField : "out_free_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "out_free_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "out_free_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						},
						{
							headerText : "출고(폐기) -",
							children : [
								{
									dataField : "out_disposal_qty",
									headerText : "수량",
									width: "65",
									minWidth: "65",
									style : "aui-center",
									labelFunction : myLabelFunction,
								}, 
								{
									dataField : "out_disposal_price",
									headerText : "단가",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								},
								{
									dataField : "out_disposal_amt",
									headerText : "금액",
									width: "85",
									minWidth: "85",
									style : "aui-right",
									labelFunction : myLabelFunction,
								}
							]
						},
					]
				}, 
				{
					headerText : "평균매입가",
					children : [
						{
							dataField : "in_avg_qty",
							headerText : "수량",
							width: "65",
							minWidth: "65",
							style : "aui-center",
							labelFunction : myLabelFunction,
						}, 
						{
							dataField : "in_avg_price",
							headerText : "단가",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							labelFunction : myLabelFunction,
						},
						{
							dataField : "in_avg_amt",
							headerText : "금액",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							labelFunction : myLabelFunction,
						}
					]
				},
				{
					headerText : "유상매출",
					children : [
						{
							dataField : "sale_price",
							headerText : "판매가",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							headerTooltip : { // 헤더 툴팁 표시 HTML 양식
							    show : true,
							    tooltipHtml : '<div>- 입고단가 없을 시 : 직전 판매가<br>- 입고단가 있을 시 : (입고단가 * 1.2 / 0.65) 계산 후 올림 처리</div>'
							},
							labelFunction : myLabelFunction,
						}, 
						{
							dataField : "sale_amt",
							headerText : "매출",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							labelFunction : myLabelFunction,
						}, 
						{
							dataField : "sale_origin_price",
							headerText : "원가",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							labelFunction : myLabelFunction,
						},
						{
							dataField : "sale_margin_amt",
							headerText : "이익",
							width: "85",
							minWidth: "85",
							style : "aui-right",
							labelFunction : myLabelFunction,
						}
					]
				},
				{
					dataField : "seq_no",
					visible : false
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "총합계",
					positionField : "price_year_mon",
					colSpan : 2,
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "in_pay_qty",
					positionField : "in_pay_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_pay_qty);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_pay_amt",
					positionField : "in_pay_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_pay_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_free_qty",
					positionField : "in_free_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_free_qty);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_free_amt",
					positionField : "in_free_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_free_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_disposal_qty",
					positionField : "in_disposal_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_disposal_qty);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_disposal_amt",
					positionField : "in_disposal_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].in_disposal_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_pay_qty",
					positionField : "out_pay_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_pay_qty);
							}
						}
						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_pay_amt",
					positionField : "out_pay_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_pay_amt);
							}
						}
						console.log(sumVal);

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_free_qty",
					positionField : "out_free_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_free_qty);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_free_amt",
					positionField : "out_free_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_free_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_disposal_qty",
					positionField : "out_disposal_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_disposal_qty);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "out_disposal_amt",
					positionField : "out_disposal_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].out_disposal_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "in_avg_qty",
					positionField : "in_avg_qty",
					style : "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						
						//마지막 ROW의 값만 보여주기 ( 평균매입가 관련)
						var val;
						for(var i=0, len=columnValues.length; i<len; i++) {							
							if(i+1 == len ){
								val = columnValues[i];
							}
						}
						val = AUIGrid.formatNumber(val, "#,##0");
						return val;
					}
				},
				{
					dataField : "in_avg_price",
					positionField : "in_avg_price",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						//마지막 ROW의 값만 보여주기 ( 평균매입가 관련)
						var val;
						for(var i=0, len=columnValues.length; i<len; i++) {							
							if(i+1 == len ){
								val = columnValues[i];
							}
						}
						val = AUIGrid.formatNumber(val, "#,##0");
						return val;
					}
				},
				{
					dataField : "in_avg_amt",
					positionField : "in_avg_amt",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						//마지막 ROW의 값만 보여주기 ( 평균매입가 관련)
						var val;
						for(var i=0, len=columnValues.length; i<len; i++) {							
							if(i+1 == len ){
								val = columnValues[i];
							}
						}
						val = AUIGrid.formatNumber(val, "#,##0");
						return val;
					}				
				}, 
				{
					dataField : "sale_price",
					positionField : "sale_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].sale_price);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].sale_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "sale_origin_price",
					positionField : "sale_origin_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].sale_origin_price);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				},
				{
					dataField : "sale_margin_amt",
					positionField : "sale_margin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues, item) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sumVal = 0;
						
						for(var i = 0; i < gridData.length; i++) {
							if(gridData[i].seq_no == "2") {
								sumVal += $M.toNum(gridData[i].sale_margin_amt);
							}
						}

						return AUIGrid.formatNumber(sumVal, "#,##0");
					}
				}
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGrid, 8);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid,  ${partAvgPriceList});

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField == "mng_no" && event.item["inout_gubun"] != "") {
					var param = {};
					var popupOption = "";
					
					switch(event.item["inout_gubun"]) {
					case "IN" : 
						if(${page.add.AVG_PRICE_SHOW_YN eq 'Y'}) {
							param.inout_doc_no = event.item["mng_no"];
							$M.goNextPage('/part/part0302p01', $M.toGetParam(param), {popupStatus : popupOption});
						}
						break;
					case "OUT" : 
						param.inout_doc_no = event.item["mng_no"];
						$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});
						break;
					case "ADJUST" : 
						param.part_adjust_no = event.item["mng_no"];
						$M.goNextPage('/part/part0505p01', $M.toGetParam(param), {popupStatus : popupOption});
						break;
					case "CUBE" : 
						param.part_cube_no = event.item["mng_no"];
						$M.goNextPage('/part/part0703p02', $M.toGetParam(param), {popupStatus : popupOption});
						break;
					};
				}
			});
		}
		
		function myLabelFunction(rowIndex, columnIndex, value, headerText, item) {
			if(value == undefined) {
			    return null; 
			} else {
				return $M.setComma(value);
			}
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품통계-평균매입가확인상세");
		}
		
		function goPrint() {
			//openReportPanel('part/cust0106p01_01.crf','s_cust_no=' + $M.getValue("cust_no") + '&s_start_dt=' + $M.getValue("s_start_dt") + '&s_end_dt=' + $M.getValue("s_end_dt")  + '&prt_gubun=1');
			alert("출력");
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>${maker_name}/${part_production_name}
							(${part_no} <span class="ver-line">${part_name} </span>)
						</h4>			
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>						
				<div style="margin-top: 5px; height: 500px;" id="auiGrid"></div>
			</div>		
<!-- /폼테이블 -->
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