<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-18 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<style type="text/css">
	
		/* 커스텀 행 스타일 ( 세로선 ) */
		.my-column-style {
		    border-right: 1px solid #000000 !important;
		}
					
	</style>
	<script type="text/javascript">
	
		var auiGrid;
		var array 			= [];
		var yearMonList 	= [];
		var dataFieldName 	= [];
		var fieldStatusName = [];
		
		$(document).ready(function() {
			fnInit();
			createAUIGrid();
			
			// 2021-09-15 (SR:12637) 권한에따라 송금완료금액 컬럼 숨기기 적용
			if ($M.getValue("column_view_yn") == "N") {
				AUIGrid.hideColumnByDataField(auiGrid, ["a_remit_lc_total_price"]);
			}
		});

		function fnInit() {
			yearMonList = ${yearMonList};
			
			for(var i = 1; i <= yearMonList.length; ++i) {
				dataFieldName.push("a_month" + [i] + "_appr_qty");
				fieldStatusName.push("month" + [i] + "_confirm_yn");
			}
			dataFieldName = dataFieldName.reverse();
			fieldStatusName = fieldStatusName.reverse();
		}

	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					useGroupingPanel : false,
					showRowNumColumn: false,
				    displayTreeOpen : true,
					enableCellMerge : true,
					showBranchOnGrouping : false,
					summaryMergePolicy : "all",
					//푸터 상단 고정
					footerPosition : "top",
					showFooter : false,
					editable : false,
					enableFilter :true,
					headerHeights : [25, 45],
					// [15324] 틀 고정
					fixedColumnCount : 2,
					
					rowStyleFunction : function(rowIndex, item) {
						if(item.maker_name.indexOf("합계") != -1 || 
								item.maker_name.indexOf("총계") != -1 || 
								item.machine_name.indexOf("합계") != -1) {
							return "aui-grid-row-depth3-style";
						} 
						return null;
					}
			};
			
			var columnLayout = [
				{
					headerText : "메이커",
// 					dataField : "maker_group",
					dataField : "maker_name",
					width : "110",
					minWidth : "20",
					style : "aui-center",
					cellMerge : true, // 셀 세로 병합 실행
					filter : {
						showIcon : true
					}
				}, 
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "120",
					minWidth : "20", 
// 					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.machine_name.indexOf("합계") != -1 ) {
							return "aui-center";
						}
						return "aui-left";
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "총재고<br/>(A+B)", 
					dataField : "a_total_ab",
					width : "50",
					minWidth : "20",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var total_ab = $M.toNum(item.a_tot_a) + $M.toNum(item.a_tot_b);
						total_ab = AUIGrid.formatNumber(total_ab, "#,##0");
						return total_ab == 0 ? "" : total_ab;
					},
				},
				{ 
					headerText : "Order<br/>잔량", 
					dataField : "a_order_cnt", 
					width : "45",
					minWidth : "20",
					formatString : "#,##0",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
					// headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					// 	show : true,
					// 	tooltipHtml : '<div>선적발주서 결제완료 시 수량 제외</div>'
					// }
				},
			];
			
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
			
		  	var columnObjArr = []; // 생성할 컬럼 배열

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				var columnObj = {
					headerText : yearMonList[i].substring(4,6) + "월",
					dataField : dataField,
					width : "3.5%", 
					headerStyle : "aui-fold",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						var confirmYn = dataField.replace(/(_appr_qty)/g, "");
						confirmYn = confirmYn.replace(/(a_)/g, "") + "_confirm_yn";
						if(item[confirmYn] == 'Y' || item.machine_name.indexOf("합계") != -1 || 
								item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
							return "";
						};
						return "aui-row-sale-confirm";
					}
				}
				
				var columnObj2 = {
					dataField : fieldStatusName[i],
					visible : false,
				}
				
				columnObjArr.push(columnObj);
				columnObjArr.push(columnObj2);
			}
			
			var columnAddObj = [
				{
					headerText : "소계<br/>(A)",
					dataField : "a_tot_a", 
					width : "3.5%", 
// 					style : "aui-center",
					style : "my-column-style",
					headerStyle : "my-column-style",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
								
					},
				},
				{
// 					headerText : "선적대기",
// 					children : [
// 						{
							headerText : "선적<br/>발주",
							dataField : "a_ship_cnt",
							width : "3.5%", 
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "";
								}
								return "aui-popup"
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
							headerTooltip : { // 헤더 툴팁 표시 HTML 양식
							    show : true,
							    tooltipHtml : '<div>선적발주서 작성완료</div>'
							}
// 						}, 
// 						{
// 							headerText : "송금<br/>예정",
// 							dataField : "a_lc_cnt",
// 							width : "3.5%", 
// 							style : "aui-center",
// 							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
// 										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
// 									return "";
// 								}
// 								return "aui-popup";
// 							},
// 							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 								value = AUIGrid.formatNumber(value, "#,##0");
// 								return value == 0 ? "" : value;
										
// 							},
// 						},
// 						{
// 							headerText : "항구<br/>대기",
// 							dataField : "a_port_wait_cnt",
// 							width : "3.5%", 
// 							style : "aui-center",
// 							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 								value = AUIGrid.formatNumber(value, "#,##0");
// 								return value == 0 ? "" : value;
										
// 							},
// 						}
// 					]
				},
				{
					headerText : "항해<br>중", 
					dataField : "a_sailing_cnt", 
					width : "3.5%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
								
					},
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>차대번호 입력상태</div>'
					}
				},
				{
					headerText : "한국<br/>보유", 
					dataField : "a_tot_kor_cnt",
					width : "4%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
								
					},
				},
				{ 
					headerText : "계(B)",
					dataField : "a_tot_b", 
					width : "4%", 
// 					style : "aui-center",
					style : "my-column-style",
					headerStyle : "my-column-style",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
								
					},
				},
				{
					headerText : "보유장비",
					style : "my-column-style",
					headerStyle : "my-column-style",
					children : [
						{
							dataField : "a_machine_out_pos_0",
							headerText : "즉시",
							width : "4%", 
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "";
								}
								return "aui-popup";
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						}, 
						{
							dataField : "a_machine_out_pos_2",
							headerText : "정비<br>후",
							width : "4%", 
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "";
								}
								return "aui-popup";
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						},
						{
							dataField : "a_diplay_out_cnt",
							headerText : "전시<br/>출하",
							width : "4%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "";
								}
								return "aui-popup";
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						},
						{
							headerText : "소계",
							dataField : "a_machine_out_total",
							width : "4%", 
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						},
						{
							dataField : "a_out_use_cnt",
							headerText : "출하<br/>가능",
							width : "4%", 
							style : "aui-center",
							style : "my-column-style",
							headerStyle : "my-column-style",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						},
					]
				},
				{
					headerText : "계약품의",
					children : [
						{
							dataField : "a_complete_appr_cnt",
							headerText : "결재<br/>완료",
							width : "4%", 
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
										item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
									return "";
								}
								return "aui-popup"
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						}, 
						{
							dataField : "a_contract_balance_cnt",
							headerText : "계약<br/>잔고",
							width : "4%", 
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value;
										
							},
						}
					]
				},	
				{
					headerText : "송금<br/>예정",
					dataField : "a_lc_cnt",
					width : "3.5%", 
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
								item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
							return "";
						}
						return "aui-popup";
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
							
					},
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>LC OPEN상태</div>'
					}
				},
				{
					headerText : "송금<br/>완료",
					dataField : "a_remit_lc_cnt",
					width : "3.5%", 
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
								item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
							return "";
						}
						return "aui-popup";
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
							
					},
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
					    show : true,
					    tooltipHtml : '<div>송금완료상태</div>'
					}
				},
				{
					dataField : "a_remit_lc_total_price",
					headerText : "송금<br/>완료<br/>금액",
					width : "12%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
								
					},
				},
				{
					dataField : "a_fix_out_cnt",
					headerText : "지정<br/>출고",
					width : "3.5%", 
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0 || item.machine_name.indexOf("합계") != -1 || 
								item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
							return "";
						}
						return "aui-popup"
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0");
						return value == 0 ? "" : value;
					},
				}, 
			]

			for (var i=0; i<columnAddObj.length; i++) {
				columnObjArr.push(columnAddObj[i]);					
			}
			
            // 컬럼 추가.
            AUIGrid.addColumn(auiGrid, columnObjArr, 'last');
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

			// [23426] 총계 틀 고정
			AUIGrid.setFixedRowCount(auiGrid, 1);
			AUIGrid.bind(auiGrid, "filtering", function(event) {
				var filterInfo = event.filterCache;
				var length = 0;
				for (var n in filterInfo) {
					length++;
				}
				if (length <= 0){	// 전체선택일 경우
					AUIGrid.setFixedRowCount(auiGrid, 1);
				}

				if ('machine_name' in event.filterCache) {
					var hasMachineNameEmpty = event.filterCache.machine_name.includes("(필드 값 없음)");
					AUIGrid.setFixedRowCount(auiGrid, hasMachineNameEmpty ? 1 : 0);
				} else {
					var hasMakerNameFull = event.filterCache.maker_name.includes("전체 총계");
					AUIGrid.setFixedRowCount(auiGrid, hasMakerNameFull ? 1 : 0);
				}

			});
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=510, left=0, top=0";
				
				// 소계 영역, 값이 없는 경우 클릭 이벤트X
				if(event.item.machine_name.indexOf("합계") != -1 || 
						event.item.maker_name.indexOf("총계") != -1 || event.item.maker_name.indexOf("합계") != -1  || $M.nvl(event.value, 0) == 0) {
					return;
				};
				
				if(event.dataField == 'a_ship_cnt') {
					
					if (fnPopUpViewCheck() == "Y") {
						// 선적발주목록 팝업
						var popupOption = "";
						var params = {
							machine_name : event.item.machine_name,	
						};
						$M.goNextPage('/sale/sale0102p01', $M.toGetParam(params), {popupStatus : popupOption});
					} 
					
				} else if(event.dataField == 'a_machine_out_pos_0' || event.dataField == 'a_machine_out_pos_1' || event.dataField == 'a_machine_out_pos_2')  {						
					// 즉시,24시간, 정비후
					// 보유장비목록 팝업
					
					var machineOutPosCd = "";
					
					switch (event.dataField) {
					    case 'a_machine_out_pos_0' :
					    	machineOutPosCd = 0;
					        break;
					    case 'a_machine_out_pos_1' :
					    	machineOutPosCd = 1;
					        break;
					    case 'a_machine_out_pos_2' :
					    	machineOutPosCd = 2;
					        break;
					}

					var popupOption = "";
					var params = {
						status_cd : 0,
						machineOutPosCd : machineOutPosCd,
						machine_name : event.item.machine_name,
					};
					$M.goNextPage('/sale/sale0102p02', $M.toGetParam(params), {popupStatus : popupOption});
					
				} else if(event.dataField == 'a_diplay_out_cnt') {
					// 전시출하
					// 보유장비목록 팝업
					var popupOption = "";
					var params = {
						status_cd : 1,
						machine_name : event.item.machine_name,
						out_dt_yn : "N"
					};
					$M.goNextPage('/sale/sale0102p02', $M.toGetParam(params), {popupStatus : popupOption});
					
				} else if(event.dataField == 'a_lc_cnt') {
					// 송금예정
					// 송금예정목록 팝업
					if (fnPopUpViewCheck() == "Y") {
						var popupOption = "";
						var params = {
							machine_name : event.item.machine_name,
						};
						$M.goNextPage('/sale/sale0102p03', $M.toGetParam(params), {popupStatus : popupOption});
					}
					
				} else if(event.dataField == 'a_complete_appr_cnt') {
					// 결재완료
					// 계약품의서
					var popupOption = "";
					var params = {
						machine_name : event.item.machine_name,
					};
					$M.goNextPage('/sale/sale0102p04', $M.toGetParam(params), {popupStatus : popupOption});
					
				} else if (event.dataField == 'a_remit_lc_cnt') {
					// 송금완료
					if (fnPopUpViewCheck() == "Y") {
						var popupOption = "";
						var params = {
							machine_name : event.item.machine_name,
						};
						$M.goNextPage('/sale/sale0102p05', $M.toGetParam(params), {popupStatus : popupOption});
					}
				} else if (event.dataField == 'a_fix_out_cnt') {
					// 지정출고
					var popupOption = "";
					var params = {
						machine_name : event.item.machine_name,
					};
					$M.goNextPage('/sale/sale0102p06', $M.toGetParam(params), {popupStatus : popupOption});
				}
			}); 
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
			
//  		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}

		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "출하명세서-보유장비대비", "");
		}
		
		// 01~12월 컬럼 숨기기
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
// 			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
// 		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
		
		// 21.09.10 (SR : 12088) 선적발주, 송금예정, 송금완료 팝업 열람 권한 체크
		function fnPopUpViewCheck() {
			var flag = "N";
			
			$M.goNextPageAjax(this_page + "/popUp/check", "", {method : 'GET', async : false},
				function(result) {
		    		if(result.success) {
		    			flag = "Y";
		    		} 
				}
			);
			
			return flag;
		}

		// 선적일정표 팝업 호출
		function goMachineLcDetail() {
			var popupOption = "";
			var params = {};
			$M.goNextPage('/sale/sale0102p07', $M.toGetParam(params), {popupStatus : popupOption});
		}
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
	<input type="hidden" id="column_view_yn" name="column_view_yn" value="${column_view_yn}"> <!-- 송금완료금액 컬럼 조회 권한 -->
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
					<div class="btn-group">
						<div class="left text-warning">
	                      		  ※ 생산발주 미확정 건은 주황색으로 표시됩니다.
<!-- 			                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">숨기기</button> -->
								<input type="checkbox" id="s_toggle_column" name="s_toggle_column" onclick="javascript:fnChangeColumn(event)">
								<label for="s_toggle_column" style="color:black;">월별보기</label>
	                    </div>
						<div class="right">
							<c:if test="${page.fnc.F00067_003 eq 'Y'}">
								<button type="button" class="btn btn-important" style="width: 80px;" onclick="javascript:goMachineLcDetail();">선적일정표</button>
							</c:if>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
<!-- 					<div id="auiGrid" style="height:655px; margin-top: 5px; width:900px;"></div> -->
					<div id="auiGrid" style="height:655px; margin-top: 5px;"></div>
				</div>
							
			</div>		
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
	<!-- /contents 전체 영역 -->	
	</div>	
</form>
</body>
</html>