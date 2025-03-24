<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 선적일정공유표 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2021-08-06 16:12:48
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
		// lc연결 컬럼의 개수. 4개보다 적을때는 4개로 고정 4개보다 많아지면 그만큼 수량 증가
		var columnCnt = 4;
		// 검색한 날짜의 lc연결 개수
		var searchColumnCnt;
		// lc연결 컬럼들의 pk를 저장해놓는 전역변수
		var columnMachineShipPlanSeq = [];
		// lc연결 컬럼들의 각각의 lc_no를 저장해놓는 전역변수
		var columnMachineLcNo = [];
		// lc연결 컬럼들의 lc연결 상태가 변했는지를 체크해주는 전역변수
		var columnLcChangeCheck = [];
		var myJQCalendarRenderer = {
				type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
				defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
				onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
				maxlength : 8,
				onlyNumeric : true, // 숫자만
				validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
					return fnCheckDate(oldValue, newValue, rowItem);
				},
				showEditorBtnOver : true
		};
		var myInputEditRenderer = {
                type : "InputEditRenderer",
                onlyNumeric : true,
        };
		
		$(document).ready(function(){
			createAUIGrid();
			
			init();
		})
	    
		function init(){
			goSearch();			
		}
		
		function createAUIGrid(){
			var gridPros = {
	                rowIdField: "machine_plant_seq",
	                showStateColumn: true,
	                enableMovingColumn: false,
	                enableSorting : false,
	                editable: true,
	                editableOnFixedCell : true,
                    enableCellMerge: true, // 셀병합 사용여부
	                rowStyleFunction : function(rowIndex, item) {
						if(item.machine_plant_seq == -3) {
							return "aui-grid-row-depth3-style";
						} 
						return null;
					}
            };
			
            var columnLayout = [
                {
                    dataField: "machine_plant_seq",
                    visible: false
                },
                {
                    dataField: "machine_name",
                    headerText: "모델",
                    width : "100",
                    style: "aui-center",
                    editable : false,
            		cellColMerge : true, // 셀 가로 병합 실행
            		cellColSpan : 2, // 셀 가로 병합 대상은 6개로 설정
                },
                {
                    dataField: "unit_price",
                    headerText: "금액",
                    width : "120",
                    styleFunction : function(rowIndex, columnIndex, value, item, dataField){
                    	if(rowIndex != 0 && rowIndex != 1 && rowIndex != 2){
                    		return "aui-editable";
                    	}
                    	return "aui-center";
                    },
                    editRenderer : myInputEditRenderer,
                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                    	if(value == 0 || value == "" || value == undefined){
                    		return "";
                    	}
                    	if(rowIndex != 0 && rowIndex != 1 && rowIndex != 2){
                    		var regexp = /\B(?=(\d{3})+(?!\d))/g;
                    		return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
                    	}
                    	return value;
                    }
                },
                {
                	headerText: "송금요청",
                    headerStyle: "aui-center",
                    dataField: "parent_send_req",
                	children:[
                		{
                			dataField: "1column_send_req_dt",
                			headerText: "<div> <button type='button' class='icon-btn-saerch' onclick='javascript:goRemovePlan(1)' style='float:left;'><i class='textbox-icon icon-clear'></i></button> <span style='vertical-align: sub;'>송금일자</span> <div style='float:right;'><button type='button' class='btn btn-important' id='1column_btn' name='1column_btn' style='width: 80px;' onclick='javascript:goLCOpen(1);'>LC오픈</button> <button type='button' class='btn btn-default' style='width: 20px;' onclick='javascript:fnLCClose(1);'>X</button></div></div>",
                            headerStyle: "aui-center my-column-style",
                			children:[
                				{
                					dataField: "1column_qty",
                					headerText: "수량",
                                    width : "50",
                                    editRenderer : myInputEditRenderer,
                                    styleFunction : myStyleFunction,
                                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    },
                				},
                				{
                					dataField: "1column_total_amt",
                					headerText: "금액",
                                    width : "100",
                                    styleFunction : myStyleFunction,
                                    editRenderer : {
                    					type : "ConditionRenderer",
                    					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
                    						if(rowIndex == 0 || rowIndex == 1){
                    							return myJQCalendarRenderer;
                    						}else{
                    							return myInputEditRenderer;
                    						}
                    					}
                    				},
                    				labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    	return value.substring(2,4)+"-"+value.substring(4,6)+"-"+value.substring(6,8);
                                    }
                				},
                				{
                					dataField: "1column_proc_date",
                					headerText: "송금일자",
                                    width : "100",
                    				dataType : "date",
                    				dataInputString : "yyyymmdd",
                    				formatString : "yy-mm-dd",
                                    editable : false,
                                    style : "aui-background-darkgray my-column-style",
                                    headerStyle: "my-column-style",
                				},
                			]
                		},
                		{
                			dataField: "2column_send_req_dt",
                			headerText: "<div> <button type='button' class='icon-btn-saerch' onclick='javascript:goRemovePlan(2)' style='float:left;'><i class='textbox-icon icon-clear'></i></button> <span style='vertical-align: sub;'>송금일자</span> <div style='float:right;'><button type='button' class='btn btn-important' id='2column_btn' name='2column_btn' style='width: 80px;' onclick='javascript:goLCOpen(2);'>LC오픈</button> <button type='button' class='btn btn-default' style='width: 20px;' onclick='javascript:fnLCClose(2);'>X</button></div></div>",
                            headerStyle: "aui-center my-column-style",
                			children:[
                				{
                					dataField: "2column_qty",
                					headerText: "수량",
                                    width : "50",
                                    editRenderer : myInputEditRenderer,
                                    styleFunction : myStyleFunction,
                                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                				{
                					dataField: "2column_total_amt",
                					headerText: "금액",
                                    width : "100",
                                    styleFunction : myStyleFunction,
                                    editRenderer : {
                    					type : "ConditionRenderer",
                    					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
                    						if(rowIndex == 0 || rowIndex == 1){
                    							return myJQCalendarRenderer;
                    						}else{
                    							return myInputEditRenderer;
                    						}
                    					}
                    				},
                    				labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    	return value.substring(2,4)+"-"+value.substring(4,6)+"-"+value.substring(6,8);
                                    }
                				},
                				{
                					dataField: "2column_proc_date",
                					headerText: "송금일자",
                                    width : "100",
                    				dataType : "date",
                    				dataInputString : "yyyymmdd",
                    				formatString : "yy-mm-dd",
                                    editable : false,
                                    style : "aui-background-darkgray my-column-style",
                                    headerStyle: "my-column-style",
                				},
                			]
                		},
                		{
                			dataField: "3column_send_req_dt",
                			headerText: "<div> <button type='button' class='icon-btn-saerch' onclick='javascript:goRemovePlan(3)' style='float:left;'><i class='textbox-icon icon-clear'></i></button> <span style='vertical-align: sub;'>송금일자</span> <div style='float:right;'><button type='button' class='btn btn-important' id='3column_btn' name='3column_btn' style='width: 80px;' onclick='javascript:goLCOpen(3);'>LC오픈</button> <button type='button' class='btn btn-default' style='width: 20px;' onclick='javascript:fnLCClose(3);'>X</button></div></div>",
                            headerStyle: "aui-center my-column-style",
                			children:[
                				{
                					dataField: "3column_qty",
                					headerText: "수량",
                                    width : "50",
                                    editRenderer : myInputEditRenderer,
                                    styleFunction : myStyleFunction,
                                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                				{
                					dataField: "3column_total_amt",
                					headerText: "금액",
                                    width : "100",
                                    styleFunction : myStyleFunction,
                                    editRenderer : {
                    					type : "ConditionRenderer",
                    					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
                    						if(rowIndex == 0 || rowIndex == 1){
                    							return myJQCalendarRenderer;
                    						}else{
                    							return myInputEditRenderer;
                    						}
                    					}
                    				},
                    				labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    	return value.substring(2,4)+"-"+value.substring(4,6)+"-"+value.substring(6,8);
                                    }
                				},
                				{
                					dataField: "3column_proc_date",
                					headerText: "송금일자",
                                    width : "100",
                    				dataType : "date",
                    				dataInputString : "yyyymmdd",
                    				formatString : "yy-mm-dd",
                                    editable : false,
                                    style : "aui-background-darkgray my-column-style",
                                    headerStyle: "my-column-style",
                				},
                			]
                		},
                		{
                			dataField: "4column_send_req_dt",
                			headerText: "<div> <button type='button' class='icon-btn-saerch' onclick='javascript:goRemovePlan(4)' style='float:left;'><i class='textbox-icon icon-clear'></i></button> <span style='vertical-align: sub;'>송금일자</span> <div style='float:right;'><button type='button' class='btn btn-important' id='4column_btn' name='4column_btn' style='width: 80px;' onclick='javascript:goLCOpen(4);'>LC오픈</button> <button type='button' class='btn btn-default' style='width: 20px;' onclick='javascript:fnLCClose(4);'>X</button></div></div>",
                            headerStyle: "aui-center my-column-style",
                			children:[
                				{
                					dataField: "4column_qty",
                					headerText: "수량",
                                    width : "50",
                                    editRenderer : myInputEditRenderer,
                                    styleFunction : myStyleFunction,
                                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                				{
                					dataField: "4column_total_amt",
                					headerText: "금액",
                                    width : "100",
                                    styleFunction : myStyleFunction,
                                    editRenderer : {
                    					type : "ConditionRenderer",
                    					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
                    						if(rowIndex == 0 || rowIndex == 1){
                    							return myJQCalendarRenderer;
                    						}else{
                    							return myInputEditRenderer;
                    						}
                    					}
                    				},
                    				labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    	return value.substring(2,4)+"-"+value.substring(4,6)+"-"+value.substring(6,8);
                                    }
                				},
                				{
                					dataField: "4column_proc_date",
                					headerText: "송금일자",
                                    width : "100",
                    				dataType : "date",
                    				dataInputString : "yyyymmdd",
                    				formatString : "yy-mm-dd",
                                    editable : false,
                                    style : "aui-background-darkgray my-column-style",
                                    headerStyle: "my-column-style",
                				},
                			]
                		},
                	]
                },
                {
                	dataField: "plan_proc_amt",
        			headerText: "송금 예정/완료 금액",
                    headerStyle: "aui-center",
        			children:[
        				{
        					dataField: "parent_plan_amt",
        					headerText: "송금예정금액",
                            style: "aui-center",
                            children:[
                				{
                					dataField: "plan_qty",
                					headerText: "수량",
                                    width : "50",
                                    editable : false,
                                    style: "aui-center",
                                    expFunction : function(rowIndex, columnIndex, item, dataField) {
                                    	if(rowIndex >= 2){
	                                   		var gridData = AUIGrid.getGridData(auiGrid);
	                   						var sum = 0;
	                   						if(gridData.length == 0){
	                   							return item.plan_qty;
	                   						}	
	                   						for(var key in gridData[rowIndex]){
	                   							var index = key.indexOf("column_qty");
	                   							var col = key.substring(0,index);
	                   							if(index != -1){
	                   								if(!gridData[rowIndex].hasOwnProperty(col+"column_proc_date")){
	                   									console.log(gridData[rowIndex]);
				                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   								}else if(gridData[rowIndex][col+"column_proc_date"] == ""){
				                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   								}
	                   							}
	                   						}
	                   						
	                   						return sum;
                                    	}
                                    },
                                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                				{
                					dataField: "plan_amt",
                					headerText: "금액",
                                    width : "120",
                                    editable : false,
                                    style: "aui-center",
                                    expFunction : function(rowIndex, columnIndex, item, dataField) {
	                                   	if(rowIndex >= 2){
	                                   		var gridData = AUIGrid.getGridData(auiGrid);
	                   						var sum = 0;
	                   						if(gridData.length == 0){
	                   							return item.plan_amt;
	                   						}
	                   						for(var key in gridData[rowIndex]){
	                   							var index = key.indexOf("column_total_amt");
	                   							var col = key.substring(0,index);
	                   							if(index != -1){
	                   								if(!gridData[rowIndex].hasOwnProperty(col+"column_proc_date")){
				                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   								}else if(gridData[rowIndex][col+"column_proc_date"] == ""){
				                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   								}
	                   							}
	                   						}
	                   						
	                   						return sum;
	                                   	}
	                                },
	                                labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                			]
        				},
        				{
        					dataField: "parent_proc_amt",
        					headerText: "송금완료금액",
                            style: "aui-center",
                            children:[
                				{
                					dataField: "proc_qty",
                					headerText: "수량",
                                    width : "50",
                                    editable : false,
                                    style: "aui-center",
                                    expFunction : function(rowIndex, columnIndex, item, dataField) {
                                    	if(rowIndex >= 2){
                                    		var gridData = AUIGrid.getGridData(auiGrid);
                    						var sum = 0;
                    						if(gridData.length == 0){
	                   							return item.proc_qty;
	                   						}
                    						for(var key in gridData[rowIndex]){
                    							var index = key.indexOf("column_qty");
	                   							if(index != -1){
	                   								var col = key.substring(0, index);
	                   								if(gridData[rowIndex].hasOwnProperty(col+"column_proc_date")){
	                   									if(gridData[rowIndex][col+"column_proc_date"] != ""){
	    			                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   									}
	                   								}
	                   							}
	                   						}
                    						
                    						return sum;
                                    	}
                					},
                					labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                				{
                					dataField: "proc_amt",
                					headerText: "금액",
                                    width : "120",
                                    editable : false,
                                    style: "aui-center",
                                    expFunction : function(rowIndex, columnIndex, item, dataField) {
                                    	if(rowIndex >= 2){
                                    		var gridData = AUIGrid.getGridData(auiGrid);
                    						var sum = 0;
                    						if(gridData.length == 0){
	                   							return item.proc_amt;
	                   						}
                    						for(var key in gridData[rowIndex]){
                    							var index = key.indexOf("column_total_amt");
	                   							if(index != -1){
	                   								var col = key.substring(0, index);
	                   								if(gridData[rowIndex].hasOwnProperty(col+"column_proc_date")){
	                   									if(gridData[rowIndex][col+"column_proc_date"] != ""){
	    			                   						sum += $M.toNum(gridData[rowIndex][key]);
	                   									}
	                   								}
	                   							}
	                   						}
                    						
                    						return sum;
                                    	}
                					},
                					labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                                    	if(value == 0 || value == "" || value == undefined){
                                    		return "";
                                    	}
                                    	if(rowIndex != 0 && rowIndex != 1){
                    						value = AUIGrid.formatNumber(value, "#,##0");
                    						return value == 0 ? "" : value;
                                    	}
                                    }
                				},
                			]
        				},
        			]
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            AUIGrid.setFixedRowCount(auiGrid, 3);
            AUIGrid.setFixedColumnCount(auiGrid, 3);
			
            // 셀 수정전 이벤트
            AUIGrid.bind(auiGrid, "cellEditBegin", function(event){
				if((event.rowIndex == 0 || event.rowIndex == 1) && event.dataField.indexOf("column_total_amt") == -1){
					return false;
				}
				if(event.rowIndex == 2){
					return false;
				}
				var index = event.dataField.indexOf("column");
				if(index != -1){
					var col = event.dataField.substring(0,index);
					if(columnMachineLcNo[col-1] != "" && columnMachineLcNo[col-1] != "CLEAR"){
						return false;
					}
				}
            });

            // 셀 완료 직전 이벤트
            AUIGrid.bind(auiGrid, "cellEditEndBefore", function(event){
				if(event.dataField.indexOf("column_qty") != -1){
					var column = event.dataField.substring(0,event.dataField.indexOf("column_qty"));
					var columnName = column+"column_total_amt";
					var oldColumnAmt = AUIGrid.getCellValue(auiGrid, event.rowIndex, columnName);
					
					if(event.value == 0 || event.value == ""){
						if(event.oldValue != undefined && event.oldValue != ""){
							AUIGrid.setCellValue(auiGrid,event.rowIndex, $M.toNum(event.columnIndex) + 1, "");
						}
						
						calGridData(event.dataField, $M.toNum(event.oldValue), 0);
						calGridData(columnName, $M.toNum(oldColumnAmt), 0);
						return "";
					}
					var total_amt = event.value * event.item.unit_price;
					var obj = {};
					obj[column+"column_total_amt"] = total_amt
					
					AUIGrid.updateRow(auiGrid, obj , event.rowIndex);
					calGridData(event.dataField, $M.toNum(event.oldValue), $M.toNum(event.value));
					calGridData(columnName, $M.toNum(oldColumnAmt), $M.toNum(total_amt));
				}else if(event.dataField.indexOf("column_total_amt") != -1 && event.rowIndex >= 3){
					if(event.value == event.oldValue || event.value == ""){
						return event.oldValue;
					}
					var qty = AUIGrid.getCellValue(auiGrid, event.rowIndex, event.columnIndex-1);
					if(qty == "" || qty == undefined){
						setTimeout(function () {
                            AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex-1, "수량을 먼저 입력해야합니다.");
                        }, 1);
						return "";
					}
					calGridData(event.dataField, $M.toNum(event.oldValue), $M.toNum(event.value));
				}
            });
		}
		
		function myStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField){
			if(rowIndex == 0 || rowIndex == 1){
				var index = dataField.indexOf("column_qty");
				if(index != -1){
					return "aui-background-darkgray";
				}
				index = dataField.indexOf("column_total_amt");
				if(index != -1){
					var columnName = dataField.substring(0,index);
					if(columnMachineLcNo[columnName-1] == "" || columnMachineLcNo[columnName-1] == "CLEAR"){
						return "aui-editable";
					}else{
						return "aui-center";
					}
				}
			}else{
				var index = dataField.indexOf("column");
				if(index != -1){
					var columnName = dataField.substring(0,index);
					if(columnMachineLcNo[columnName-1] == "" || columnMachineLcNo[columnName-1] == "CLEAR"){
						return "aui-editable";
					}else{
						return "aui-center";
					}
				}
			}
		}
		
		// 수량 및 금액 계산
		function calGridData(dataField, oldValue, newValue){
			var originTotal = AUIGrid.getCellValue(auiGrid,2,dataField);
			var obj = {};
			
			AUIGrid.setCellValue(auiGrid, 2, dataField, $M.toNum(originTotal) - oldValue + $M.toNum(newValue));
		}
		
		// 검색
		function goSearch(){
			var params = {
				"s_year_mon" : $M.getValue("s_year")+$M.getValue("s_mon"),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get' }, function(result){
				if(result.success){
					$M.setValue("curr_s_year",$M.getValue("s_year"));
					$M.setValue("curr_s_mon",$M.getValue("s_mon"));
					$M.setValue("curr_s_maker_cd",$M.getValue("s_maker_cd"));
					
					if(result.list.length == 0){
						alert("해당 기간내에 생산발주한 모델이 없습니다.");
						columnMachineShipPlanSeq = [];
						columnMachineLcNo = [];
					}else{
						columnMachineShipPlanSeq = result.columnPlanSeqArr.split("#");
						columnMachineLcNo = result.columnMachineLcNoArr.split("#");
						columnLcChangeCheck = [];
						for(var i=0; i<columnMachineLcNo.length; i++){
							columnLcChangeCheck[i] = false;
						}
						searchColumnCnt = result.list[0].max_column_seq;
						if(searchColumnCnt > 4){
							fnAddColNum(searchColumnCnt);
						}else {
							fnColClear();
						}
					}

					AUIGrid.setGridData(auiGrid, result.list);
					if(columnMachineLcNo.length != 0){
						for(var i=1; i<=columnCnt; i++){
							if(columnMachineLcNo[i-1] != ""){
								$("#"+i+"column_btn").html(columnMachineLcNo[i-1].substring(2));
							}
						}
					}
				}
			});
		}
		
		// LC-Open 버튼 클릭
		function goLCOpen(columnIndex){
			var params = {
					"parent_js_name" : "checkAndSetLC",
					"column_index" : columnIndex,
					"s_year_mon" : $M.getValue("s_year")+$M.getValue("s_mon"),
					"s_maker_cd" : $M.getValue("s_maker_cd"),
			}
			
			var popupOption = {};
			
			$M.goNextPage("/sale/sale0208p01", $M.toGetParam(params), { popupStatus : popupOption });
		}
		
		// LC-Close 버튼 클릭
		function fnLCClose(columnIndex){
			if(columnMachineLcNo[columnIndex-1] != ""){
				columnMachineLcNo[columnIndex-1] = "CLEAR";
				columnLcChangeCheck[columnIndex-1] = true;
				AUIGrid.refresh(auiGrid);
				if(columnMachineLcNo.length != 0){
					for(var i=1; i<=columnCnt; i++){
						if(columnMachineLcNo[i-1] != "" && columnMachineLcNo[i-1] != "CLEAR"){
							$("#"+i+"column_btn").html(columnMachineLcNo[i-1].substring(2));
						}
					}
				}
				
				var data = AUIGrid.getGridData(auiGrid);
				for(var i=2; i<data.length;i++) {
					if(data[i].hasOwnProperty(columnIndex+"column_proc_date")){
						var obj = {};
						obj[columnIndex+"column_proc_date"] = "";
						AUIGrid.updateRow(auiGrid, obj , i);
					}
				}
			}
		}
		
		// LC-Open 리턴함수
		function checkAndSetLC(row, columnIndex){
			var plantArr = row.machine_plant_seq_qty_arr.split("#");
			var plantMap = {};
			for(var i=0; i<plantArr.length; i++){
				var plantSeqQty = plantArr[i].split(",");
				plantMap[plantSeqQty[0]] = $M.toNum(plantMap[plantSeqQty[0]]) + $M.toNum(plantSeqQty[1]); 
			}
			var data = AUIGrid.getGridData(auiGrid);
			
			var check = true;
			// 연결하려는 lc의 모델 및 수량이 해당 컬럼과 일치하는지 확인
			for(var key in plantMap){
				for(var i=3; i<data.length; i++){
					var qty = AUIGrid.getCellValue(auiGrid,i,columnIndex+"column_qty");
					if(data[i].machine_plant_seq == key && qty != plantMap[key]){
						check = false;
						break;
					}
				}
			}
			if(check){
				for(var i=3; i<data.length; i++){
					var qty = AUIGrid.getCellValue(auiGrid,i,columnIndex+"column_qty");
					if(qty != "" && qty != plantMap[data[i].machine_plant_seq]){
						check = false;
						break;
					}
				}
			}			
			
			if(check){
				columnMachineLcNo[columnIndex-1] = row.machine_no;
				columnLcChangeCheck[columnIndex-1] = true;
				if(columnMachineLcNo.length != 0){
					for(var i=1; i<=columnCnt; i++){
						if(columnMachineLcNo[i-1] != ""){
							$("#"+i+"column_btn").html(columnMachineLcNo[i-1].substring(2));
						}
					}
				}
				if(row.remit_proc_date != ""){
					for(var i=2; i<data.length; i++){
						if(data[i][columnIndex+"column_qty"] != "" && data[i][columnIndex+"column_qty"] != undefined){
							var item = {
									"machine_plant_seq" : data[i].machine_plant_seq
								}
								item[columnIndex+"column_proc_date"] = row.remit_proc_date;
								AUIGrid.updateRowsById(auiGrid,item);
						}
					}
				}
			}else{
				alert("오픈하려는 LC와 장비내역이 일치하지 않습니다.");
			}
		}
		
		// 검색한 lc의 개수만큼 열 추가
		function fnAddColNum(cnt){
			if(columnCnt > 4){
				fnColClear();
			}
			for(var i=4; i<cnt; i++){
				fnAddCol();
			}
		}
		
		// 열 초기화
		function fnColClear(){
			for(var i=columnCnt; i>4;i--){
				var col = AUIGrid.getColumnIndexByDataField(auiGrid,i+"column_proc_date");
				var col2 = AUIGrid.getColumnIndexByDataField(auiGrid,i+"column_total_amt");
				var col3 = AUIGrid.getColumnIndexByDataField(auiGrid,i+"column_qty");
				var colList = [];
				colList.push(col);
				colList.push(col2);
				colList.push(col3);
				AUIGrid.removeColumn(auiGrid, colList);
			}
			columnCnt = 4;

			AUIGrid.refresh(auiGrid);
		}
		
		// 열추가
		function fnAddCol(){
			if(columnCnt == 12){
				alert("12개까지만 추가 가능합니다.");
				return;
			}
			columnCnt++;
			var columnObj = {
					dataField: columnCnt+"column_send_req_dt",
        			headerText: "<div> <button type='button' class='icon-btn-saerch' onclick='javascript:goRemovePlan("+columnCnt+")' style='float:left;'><i class='textbox-icon icon-clear'></i></button> <span style='vertical-align: sub;'>송금일자</span> <div style='float:right;'><button type='button' class='btn btn-important' id='"+columnCnt+"column_btn' name='"+columnCnt+"column_btn' style='width: 80px;' onclick='javascript:goLCOpen("+columnCnt+");'>LC오픈</button> <button type='button' class='btn btn-default' style='width: 20px;' onclick='javascript:fnLCClose("+columnCnt+");'>X</button></div></div>",
                    headerStyle: "aui-center my-column-style",
			}
			
			var columnObj2 = [
				{
   					dataField: columnCnt+"column_qty",
   					headerText: "수량",
                    editRenderer : myInputEditRenderer,
                    styleFunction : myStyleFunction,
                    width: 50,
                    labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                    	if(value == 0 || value == "" || value == undefined){
                    		return "";
                    	}
                    	if(rowIndex != 0 && rowIndex != 1){
    						value = AUIGrid.formatNumber(value, "#,##0");
    						return value == 0 ? "" : value;
                    	}
                    }
				},
				{
   					dataField: columnCnt+"column_total_amt",
   					headerText: "금액",
                    styleFunction : myStyleFunction,
                    width: 100,
                    editRenderer : {
    					type : "ConditionRenderer",
    					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
    						if(rowIndex == 0 || rowIndex == 1){
    							return myJQCalendarRenderer;
    						}else{
    							return myInputEditRenderer;
    						}
    					}
    				},
    				labelFunction : function(rowIndex, columnIndex, value, item, dataField){
                    	if(value == 0 || value == "" || value == undefined){
                    		return "";
                    	}
                    	if(rowIndex != 0 && rowIndex != 1){
    						value = AUIGrid.formatNumber(value, "#,##0");
    						return value == 0 ? "" : value;
                    	}
                    	return value.substring(2,4)+"-"+value.substring(4,6)+"-"+value.substring(6,8);
                    }
				},
				{
					dataField: columnCnt+"column_proc_date",
					headerText: "송금일자",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
                    editable : false,
                    style : "aui-background-darkgray my-column-style",
                    headerStyle: "my-column-style",
                    width: 100,
				},
			];

			AUIGrid.addTreeColumn(auiGrid, columnObj, "parent_send_req", "last");
			AUIGrid.addTreeColumn(auiGrid, columnObj2, columnCnt+"column_send_req_dt", "last");
			AUIGrid.refresh(auiGrid);
			if(columnMachineLcNo.length != 0){
				for(var i=1; i<=columnCnt; i++){
					if(columnMachineLcNo[i-1] != ""){
						$("#"+i+"column_btn").html(columnMachineLcNo[i-1].substring(2));
					}
				}
			}
		}
		
		function goSave(){
			var lcChange = false;
			var contentChange = false;
			for(var i=0; i<columnLcChangeCheck.length; i++){
				if(columnLcChangeCheck[i]){
					lcChange = true;
					break;
				}
			}
			
			var frm;
			// 1. 변경 컬럼과 lc연결이 변경되지 않은 경우
			// 2. 변경 컬럼이 없지만 lc연결은 변경한 경우 
			// 그 외
			if(fnChangeGridDataCnt(auiGrid) == 0 && !lcChange){
				alert("변경사항이 없습니다.");
				return false;
			}else if(fnChangeGridDataCnt(auiGrid) == 0 && lcChange){
				var list = [];

				for(var i=1; i<=columnLcChangeCheck.length; i++){
					if(columnLcChangeCheck[i-1]){
						var check = true;
						
						var ship_dt = AUIGrid.getCellValue(auiGrid,0,i+"column_total_amt");
						var in_plan_dt = AUIGrid.getCellValue(auiGrid,1,i+"column_total_amt");
						var total_qty = AUIGrid.getCellValue(auiGrid,2,i+"column_qty");

						if(ship_dt == "" || ship_dt == undefined || in_plan_dt == "" || in_plan_dt == undefined  || in_plan_dt == "0" || total_qty == "" || total_qty == undefined){
							check = false;
						}
						
						if(!check){
							alert("변경된 LC내역을 저장하기 위해서는 선적일자, 입고예정일자 및\n적어도 하나의 모델에 대한 입력이 필요합니다.");
							return false;
						}
						// 맵에 각 컬럼의 테이블 내용을 담아서 list에 push
						var param = {};
						
						param[i+"column_parent_machine_ship_plan_seq"] = columnMachineShipPlanSeq[i-1];
						param[i+"column_machine_lc_no"] = columnMachineLcNo[i-1];
						param[i+"column_ship_dt"] = ship_dt;
						param[i+"column_in_plan_dt"] = in_plan_dt;
						
						list.push(param);
					}
				}
				
				frm = $M.jsonArrayToForm(list);
			}else{
				var data = AUIGrid.getEditedRowColumnItems(auiGrid);
				var allData = AUIGrid.getGridData(auiGrid);
				// 변경된 데이터를 저장하기 전에 validation 체크
				for(var i=0; i<data.length; i++){
					if(data[i].machine_plant_seq != -1 && data[i].machine_plant_seq != -2 && data[i].machine_plant_seq != -3){
						for(var key in data[i]){
							var index = key.indexOf("column");
							if(index != -1){
								var num = key.substring(0,index);
								var columnName = num+"column_total_amt";
								if(allData[0][columnName] == "" || allData[0][columnName] == undefined || allData[1][columnName] == "" || allData[1][columnName] == undefined){
									alert("모델별 수량과 금액을 입력하기 위해서는 선적일자와 입고예정일자가 입력되어야합니다.");
									return false;
								}
							}
						}
					}
				}
				for(var i=1; i<=12; i++){
					var columnName = i+"column_total_amt";
					if(allData[0][columnName] != "" && allData[0][columnName] != undefined){
						if(allData[1][columnName] != "" && allData[1][columnName] != undefined){
							var check = false;
							for(var j=3; j<allData.length; j++){
								if(allData[j][columnName] !== "" && allData[j][columnName] != undefined){									
									check = true;
									break;
								}
							}
							
							if(!check){
								alert("적어도 하나의 모델은 수량과 금액이 입력되어야합니다.");
								return;
							}
						}else{
							alert("입고예정일자가 입력되어야합니다.");
							return;
						}
					}else if(allData[1][columnName] != "" && allData[1][columnName] != undefined){
						if(allData[0][columnName] != "" && allData[0][columnName] != undefined){
							var check = false;
							for(var j=3; j<allData.length; j++){
								if(allData[j][columnName] !== "" && allData[j][columnName] != undefined){
									console.log(allData[j]);
									check = true;
									break;
								}
							}
							
							if(!check){
								alert("적어도 하나의 모델은 수량과 금액이 입력되어야합니다.");
								return;
							}
						}else{
							alert("선적일자가 입력되어야합니다.");
							return;
						}
					}
				}

				// 실제 모델들의 선적내용들을 저장할 리스트
				var list = [];
				// 부모 테이블을 미리 만들기 위해서 따로 구분해놓은 리스트
				var list2 = [];
				var editeRowItems = AUIGrid.getEditedRowColumnItems(auiGrid); // 변경된 데이터
				var param = {}
				
				// lc수정 bean 생성
				for(var i=1; i<=columnLcChangeCheck.length; i++){
					if(columnLcChangeCheck[i-1]){
						var check = true;
						
						var ship_dt = AUIGrid.getCellValue(auiGrid,0,i+"column_total_amt");
						var in_plan_dt = AUIGrid.getCellValue(auiGrid,1,i+"column_total_amt");
						var total_qty = AUIGrid.getCellValue(auiGrid,2,i+"column_qty");

						if(ship_dt == "" || ship_dt == undefined || in_plan_dt == "" || in_plan_dt == undefined || total_qty == "" || total_qty == undefined){
							check = false;
						}
						
						if(!check){
							alert("변경된 LC내역을 저장하기 위해서는 선적일자, 입고예정일자 및\n적어도 하나의 모델에 대한 입력이 필요합니다.");
							return false;
						}
						
						param[i+"column_parent_machine_ship_plan_seq"] = columnMachineShipPlanSeq[i-1];
						param[i+"column_machine_lc_no"] = columnMachineLcNo[i-1];
						param[i+"column_ship_dt"] = ship_dt;
						param[i+"column_in_plan_dt"] = in_plan_dt;
					}
				}
				
				// 수정된 row들 각각의 bean생성
				for(var i=0; i<editeRowItems.length; i++) {
					var map = editeRowItems[i];
					if(map["machine_plant_seq"] == -1) {
						for (var key in map) {
							var index = key.indexOf("column");
							if(index != -1){
								var col = key.substring(0,index);
								param[col+"column_parent_machine_ship_plan_seq"] = columnMachineShipPlanSeq[col-1];
								if(columnMachineLcNo[col-1] != ""){
									param[col+"column_machine_lc_no"] = columnMachineLcNo[col-1];
								}
								param[col+"column_ship_dt"] = allData[0][col+"column_total_amt"];
								param[col+"column_in_plan_dt"] = allData[1][col+"column_total_amt"];
							}
						}
					}
					else if(map["machine_plant_seq"] == -2) {
						for (var key in map) {
							var index = key.indexOf("column");
							if(index != -1){
								var col = key.substring(0,index);
								param[col+"column_parent_machine_ship_plan_seq"] = columnMachineShipPlanSeq[col-1];
								if(columnMachineLcNo[col-1] != ""){
									param[col+"column_machine_lc_no"] = columnMachineLcNo[col-1];
								}
								param[col+"column_ship_dt"] = allData[0][col+"column_total_amt"];
								param[col+"column_in_plan_dt"] = allData[1][col+"column_total_amt"];
							}
						}
					}else if(map["machine_plant_seq"] == -3){
						;
					}else{
						var dtlParam = {};
						for (var key in map) {
							if(key == "unit_price"){
								dtlParam["machine_plant_seq"] = map["machine_plant_seq"];
								dtlParam["unit_price"] = map[key];
								dtlParam["send_req_mon"] = $M.getValue("curr_s_year")+$M.getValue("curr_s_mon");
							}else{
								var index = key.indexOf("column");
								if(index != -1){
									var col = key.substring(0,index);
									var item = AUIGrid.getItemsByValue(auiGrid,"machine_plant_seq",map["machine_plant_seq"]);
									dtlParam[col+"column_machine_ship_plan_seq"] = columnMachineShipPlanSeq[col-1];
									dtlParam[col+"column_machine_plant_seq"] = map["machine_plant_seq"];
									dtlParam[col+"column_qty"] = item[0][col+"column_qty"];
									dtlParam[col+"column_total_amt"] = item[0][col+"column_total_amt"];
								}
							}
						}
						list.push(dtlParam);
					}			
				}
				list2.push(param);
				
				
				// 리스트를 form으로 만듬
				frm = $M.jsonArrayToForm(list.concat(list2));
				contentChange = true;
			}

			$M.goNextPageAjaxSave(this_page+"/save", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		if(contentChange){
			    			var check = confirm("변경내용 확인요청 쪽지 발송하시겠습니까?");
			    			if(check){
			    				// var obj = {
				    			// 		"paper_contents" : "선적일정공유표 또는 어테치먼트 발주관리의 선적수량 또는 일정이 변경되었습니다. 확인하시고 업무에 참고하시기 바랍니다.#변경내용: ",
				    			// 		"receiver_mem_no_str" : "MB00000246#MB00000481#MB00000501#MB00000306",
				    			// 		"refer_mem_no_str" : "MB00000178#MB00000060#MB00000133#MB00000133#MB00000020#MB00000376#MB00000540#MB00000428#MB00000590",
				    			// }

								// [재호] 23/11/20 - Q&A17335 : 로그인된 사람의 수진자, 참조자는 제외  
								var userMemNo = '${SecureUser.mem_no}';
								var receiverMemNoList = ['MB00000246', 'MB00000481', 'MB00000501', 'MB00000306'].filter(item => item !== userMemNo);
								var referMemNoList = ['MB00000178','MB00000060','MB00000133','MB00000020','MB00000376','MB00000540','MB00000428','MB00000590'].filter(item => item !== userMemNo);

								var obj = {
									"paper_contents" : "선적일정공유표 또는 어테치먼트 발주관리의 선적수량 또는 일정이 변경되었습니다. 확인하시고 업무에 참고하시기 바랍니다.#변경내용: ",
									"receiver_mem_no_str" : receiverMemNoList.join('#'),
									"refer_mem_no_str" : referMemNoList.join('#'),
								}
				    			
				    			openSendPaperPanel(obj);
			    			}
			    		}
			    		$M.setValue("s_year",$M.getValue("curr_s_year"));
			    		$M.setValue("s_mon",$M.getValue("curr_s_mon"));
			    		goSearch();
					}
				}
			);
			
		}
		
		function goRemovePlan(column){
			if(columnMachineShipPlanSeq[column-1] == 0){
				alert("저장하지 않은 열은 삭제할 수 없습니다.");
				return;
			}
			
			var param = {
				"machine_ship_plan_seq" : columnMachineShipPlanSeq[column-1]
			};
			
			var check = confirm("저장하지 않은 내용은 사라집니다. 계속 진행하시겠습니까?");
			if(!check){
				return;
			}
			
 			$M.goNextPageAjax(this_page+"/remove",$M.toGetParam(param),{method:"POST"},
 				function(result){
 					if(result.success){
			    		$M.setValue("s_year",$M.getValue("curr_s_year"));
			    		$M.setValue("s_mon",$M.getValue("curr_s_mon"));
			    		goSearch();
 					}
 			});
		}
		
		function fnExcelDownload() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "선적일정공유표", exportProps);
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
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="150px">
								<col width="50px">
								<col width="100px">
								<%-- <col width="70px"> --%>
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
<!-- 											(Q&A 13313) 조회년 최대값 수정 -->
											<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
												<jsp:param name="sort_type" value="d"/>
												<jsp:param name="max_year" value="${inputParam.s_current_year+1}"/>
											</jsp:include>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<c:forEach items="${makerList}" var="item">
											<option value="${item.maker_cd}">${item.maker_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
								<td class="right text-warning"> ※ 조회월 기준 3개월 이내 생산발주한 모델이 조회됩니다. </td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>선적일정표</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
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