<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-03 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridFirst;
	var auiGridSecond;
	var auiGridThird;
	var auiGridFourth;
	var auiGridFifth;
	var auiGridSixth;
	
	var jpyAmt = 0;  // 미오픈발주 JPY
	var usdAmt = 0;	 // 미오픈발주 USD
	var otherAmt = 0; // 미오픈발주 기타
	
	$(document).ready(function () {
		fnInit();
	});

	function fnInit() {
		createAUIGridFirst();
		createAUIGridSecond();
		createAUIGridThird();
		createAUIGridFourth();
		createAUIGridFifth();
		createAUIGridSixth();
		
		goSearch();
	}
	
	function goFundsInPlanAdd() {
		var param = {
				s_end_dt : $M.getValue("s_end_dt")
		}
		var popupOption = "";
		$M.goNextPage('/acnt/acnt0201p04', $M.toGetParam(param), {popupStatus : popupOption});
	}

	function goFundsOutPlanAdd() {
		var param = {
				s_end_dt : $M.getValue("s_end_dt")
		}
		var popupOption = "";
		$M.goNextPage('/acnt/acnt0201p05', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
	function goPlanDtPopup(event) {
		if(event.dataField == "plan_dt") {
			if (event.item.row_num == 0) {
				// LC OPEN 상세 팝업 호출
				var param = {
						"machine_lc_no" : event.item.funds_out_plan_no
				}
				var popupOption = "";
				$M.goNextPage('/sale/sale0203p01', $M.toGetParam(param), {popupStatus : popupOption});
			} else if(event.item.row_num == -1) {
				alert('선적일정공유표에서 확인해 주세요.');
			} else {
				goFundsOutPlanAdd();  // 지출예정금액 팝업 호출
			}
		}
	}
	
	function goSearch() {
		// 미오픈발주 푸터 금액 초기화
		jpyAmt = 0;  
		usdAmt = 0;
		otherAmt = 0;
		
		$M.setValue("search_dt", $M.getValue("s_end_dt"));
		
		var param = {
				s_end_dt : $M.getValue("s_end_dt"),
			};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					console.log("result : ", result);
					destroyGrid();
// 					jpyAmt = result.fundsMachineOrderAmtList[1].total_amt;
					
					var amtList = result.fundsMachineOrderAmtList;
					for (var i = 0; i < amtList.length; i++) {
						if (amtList[i].money_unit_cd == "JPY") {
							jpyAmt += amtList[i].total_amt;
// 							otherAmt += amtList[i].total_amt;
						} else if (amtList[i].money_unit_cd == "USD") {
							usdAmt += amtList[i].total_amt;
						} else {
							otherAmt += amtList[i].total_amt;
						}
					}
					
					createAUIGridFourth();
					createAUIGridFifth();
					createAUIGridSixth();
					AUIGrid.setGridData(auiGridFirst, result.fundsInPlanBillinList);
					AUIGrid.setGridData(auiGridSecond, result.fundsInPlanList);
					AUIGrid.setGridData(auiGridThird, result.fundsOutPlanKRWList);
					AUIGrid.setGridData(auiGridFourth, result.fundsOutPlanJPYList);
					AUIGrid.setGridData(auiGridFifth, result.fundsOutPlanUSDList);
					AUIGrid.setGridData(auiGridSixth, result.fundsOutPlanETCList);
					
					// 조회 html에 각각 금액 세팅
					var list = result.fundsDailyList;
					console.log("list : ", list);
					
					var wonFooterAmt = AUIGrid.getFooterData(auiGridThird)[1].text;
					var jpyFooterAmt = AUIGrid.getFooterData(auiGridFourth)[0][1].text;
					var usdFooterAmt = AUIGrid.getFooterData(auiGridFifth)[0][1].text;
					var otherFooterAmt = AUIGrid.getFooterData(auiGridSixth)[0][1].text;
					
					console.log("wonFooterAmt : ", wonFooterAmt);
					console.log("jpyFooterAmt : ", jpyFooterAmt);
					console.log("usdFooterAmt : ", usdFooterAmt);
					console.log("otherFooterAmt : ", otherFooterAmt);
					
					for (var i = 0; i <= 5; i++) {
						$("#fundsType"+ i +"_before_money").html($M.numberFormat(list[i].before_money));
						$("#fundsType"+ i +"_in_amt").html($M.numberFormat(list[i].in_amt));
						$("#fundsType"+ i +"_out_amt").html($M.numberFormat(list[i].out_amt));
						$("#fundsType"+ i +"_after_money").html($M.numberFormat(list[i].after_money));
						
						// 비고 (예정대비 부족분) 세팅
						var bigoAmt = 0;
						switch (i) {
							case 1 :
								bigoAmt = list[i].after_money - $M.toNum(wonFooterAmt);
// 								console.log("bigoAmt : ", bigoAmt);
								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
								break;
							case 2 :
								bigoAmt = list[i].after_money - $M.toNum(jpyFooterAmt);
// 								console.log("bigoAmt : ", bigoAmt);
								$("#fundsType"+ i +"_bigo").html($M.numberFormat(parseInt(bigoAmt)));
// 								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
								break;
							case 3 :
								bigoAmt = list[i].after_money - $M.toNum(usdFooterAmt);
// 								console.log("bigoAmt : ", bigoAmt);
								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt.toFixed(2)));
// 								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
								break;
							case 4 :
								bigoAmt = list[i].after_money - $M.toNum(otherFooterAmt);
// 								console.log("bigoAmt : ", bigoAmt.toFixed(2));
								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt.toFixed(2)));
// 								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
								break;
							default :
								$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
								break;
						}
					}
				};
			}		
		);	
	}

	function goDetail(strType) {
		var str = "";
		var fundsTypeCd;
		if(strType == "W") {
			str = "예금잔액(WON)";
			fundsTypeCd = 1;
		} else if(strType == "J") {
			str = "외화예금(JPY)";
			fundsTypeCd = 2;
		} else if(strType == "U") {
			str = "외화예금(USD)";
			fundsTypeCd = 3;
		} else if(strType == "E") {
			str = "외화예금(EUR)";
			fundsTypeCd = 4;
		} else if(strType == "O") {
			str = "예적금(WON)";
			fundsTypeCd = 5;
		}

		var param = {
			"str" : str,
			"str_type" : strType,
			"funds_type_cd" : fundsTypeCd,
			"s_end_dt" : $M.getValue("s_end_dt")
		};

// 		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=330, left=0, top=0";
		var popupOption = "";
		$M.goNextPage('/acnt/acnt0201p01', $M.toGetParam(param), {popupStatus : popupOption});
	}

	function createAUIGridFirst() {
		var gridPros = {
			showRowNumColumn : false,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
		};

		var columnLayout = [
			{
				headerText : "일자",
				dataField : "end_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "금액",
				dataField : "amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "end_dt"
			},
			{
				dataField: "amt",
				positionField: "amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridFirst = AUIGrid.create("#auiGridFirst", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridFirst, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridFirst, []);
		$("#auiGridFirst").resize();

		AUIGrid.bind(auiGridFirst, "cellClick", function(event) {
			if(event.dataField == "end_dt") {
// 				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=550, height=330, left=0, top=0";
				var param = {
						end_dt : event.item.end_dt
				}
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0201p06', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}

	function createAUIGridSecond() {
		var gridPros = {
			showRowNumColumn : false,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
		};

		var columnLayout = [
			{
				headerText : "일자",
				dataField : "plan_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "구분",
				dataField : "money_unit_cd",
				width : "20%",
				style : "aui-center",
				width : "50",
				minWidth : "50",
			},
			{
				headerText : "금액",
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "money_unit_cd"
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridSecond = AUIGrid.create("#auiGridSecond", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridSecond, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridSecond, []);
		$("#auiGridSecond").resize();

		AUIGrid.bind(auiGridSecond, "cellClick", function(event) {
			if(event.dataField == "plan_dt") {
				goFundsInPlanAdd();
			}
		});
	}

	function createAUIGridThird() {
		var gridPros = {
			showRowNumColumn : false,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
		};

		var columnLayout = [
			{
				headerText : "일자",
				dataField : "plan_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "금액",
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "plan_dt",
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridThird = AUIGrid.create("#auiGridThird", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridThird, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridThird, []);
		$("#auiGridThird").resize();

		AUIGrid.bind(auiGridThird, "cellClick", function(event) {
			if(event.dataField == "plan_dt") {
				goFundsOutPlanAdd();
			} else if(event.item.row_num == -1) {
				alert('선적일정공유표에서 확인해 주세요.');
			} 
		});
	}

	function createAUIGridFourth() {
		var gridPros = {
			showRowNumColumn : false,
			showFooter : true,
			footerPosition : "top",
			footerRowCount : 2,
			enableFilter :true,
			rowStyleFunction : function(rowIndex, item) {
				 // LC - 송금예정일자가 지났는데 송금완료를 하지 않았을 경우
				 if(item.row_num == "0") {
					 if (item.plan_dt < $M.getValue("search_dt")) {
						 return "aui-color-red";
					 }
				 }
				 return "";
			}
		};

		var columnLayout = [
			{
				dataField : "funds_out_plan_no",
				visible : false
			},
			{
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "일자",
				dataField : "plan_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "금액",
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [];
		footerLayout[0] = [
			{
				labelText : "합계",
				positionField : "plan_dt"
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer",
			}
		];

		footerLayout[1] = [
			{
				labelText : "미 오픈발주",
				positionField : "plan_dt",
			},
			{
				dataField: "",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer",
	            labelFunction : function(value, columnValues, footerValues) {
                    return jpyAmt;
	           },
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridFourth = AUIGrid.create("#auiGridFourth", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridFourth, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridFourth, []);
		$("#auiGridFourth").resize();

		AUIGrid.bind(auiGridFourth, "cellClick", function(event) {
			goPlanDtPopup(event);
		});
		
		// 미오픈발주 푸터 클릭 bind
		AUIGrid.bind(auiGridFourth, "footerClick", function(event) {
			if (event.footerRowIndex == 1) {
				var moneyUnitCdArr = ["JPY"];
				console.log("푸터 클릭 event : ", event);
				console.log(moneyUnitCdArr);
				
				var param = {
						"money_unit_cd_str" : $M.getArrStr(moneyUnitCdArr)
				}
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0201p08', $M.toGetParam(param), {popupStatus : popupOption});
			}
// 			var footerData = AUIGrid.getFooterData(auiGridFourth);
// 			console.log(JSON.stringify(footerData, null, 4));
		});
	}

	function createAUIGridFifth() {
		var gridPros = {
			showRowNumColumn : false,
			showFooter : true,
			footerPosition : "top",
			footerRowCount : 2,
			enableFilter :true,
			rowStyleFunction : function(rowIndex, item) {
				 // LC - 송금예정일자가 지났는데 송금완료를 하지 않았을 경우
				 if(item.row_num == "0") {
					 if (item.plan_dt < $M.getValue("search_dt")) {
						 return "aui-color-red";
					 }
				 }
				 return "";
			}
		};

		var columnLayout = [
			{
				dataField : "funds_out_plan_no",
				visible : false
			},
			{
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "일자",
				dataField : "plan_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "금액",
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [];
		footerLayout[0] = [
			{
				labelText : "합계",
				positionField : "plan_dt",
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			}
		];

		footerLayout[1] = [
			{
				labelText : "미 오픈발주",
				positionField : "plan_dt",
			},
			{
				dataField: "",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer",
	            labelFunction : function(value, columnValues, footerValues) {
                    return usdAmt;
	           },
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridFifth = AUIGrid.create("#auiGridFifth", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridFifth, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridFifth, []);
		$("#auiGridFifth").resize();

		AUIGrid.bind(auiGridFifth, "cellClick", function(event) {
			goPlanDtPopup(event);
		});
		
		// 미오픈발주 푸터 클릭 bind
		AUIGrid.bind(auiGridFifth, "footerClick", function(event) {
			if (event.footerRowIndex == 1) {
				var moneyUnitCdArr = ["USD"];
				console.log("푸터 클릭 event : ", event);
				console.log(moneyUnitCdArr);
				
				var param = {
						"money_unit_cd_str" : $M.getArrStr(moneyUnitCdArr)
				}
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0201p08', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	
	function createAUIGridSixth() {
		var gridPros = {
			showRowNumColumn : false,
			showFooter : true,
			footerPosition : "top",
			footerRowCount : 2,
			enableFilter :true,
			rowStyleFunction : function(rowIndex, item) {
				 // LC - 송금예정일자가 지났는데 송금완료를 하지 않았을 경우
				 if(item.row_num == "0") {
					 if (item.plan_dt < $M.getValue("search_dt")) {
						 return "aui-color-red";
					 }
				 }
				 return "";
			}
		};

		var columnLayout = [
			{
				dataField : "funds_out_plan_no",
				visible : false
			},
			{
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "일자",
				dataField : "plan_dt",
				dataType : "date",  
				formatString : "yy-mm-dd",
				style : "aui-center aui-popup",
				width : "70",
				minWidth : "70",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "금액",
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0.00",
				style : "aui-right"
			}
		];

		// 푸터 설정
		var footerLayout = [];
		footerLayout[0] = [
			{
				labelText : "합계",
				positionField : "plan_dt",
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			}
		];

		footerLayout[1] = [
			{
				labelText : "미 오픈발주",
				positionField : "plan_dt",
			},
			{
				dataField: "",
				positionField: "plan_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer",
	            labelFunction : function(value, columnValues, footerValues) {
                    return otherAmt;
	           },
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridSixth = AUIGrid.create("#auiGridSixth", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridSixth, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridSixth, []);
		$("#auiGridSixth").resize();

		AUIGrid.bind(auiGridSixth, "cellClick", function(event) {
			goPlanDtPopup(event);
		});
		
		// 미오픈발주 푸터 클릭 bind
		AUIGrid.bind(auiGridSixth, "footerClick", function(event) {
			if (event.footerRowIndex == 1) {
				var moneyUnitCdArr = ["EUR", "CNY"];
				console.log("푸터 클릭 event : ", event);
				console.log(moneyUnitCdArr);
				
				var param = {
						"money_unit_cd_str" : $M.getArrStr(moneyUnitCdArr)
				}
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0201p08', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	
	// 예적금 등록상세
	function goFundsDailySavings() {
		var param = {
// 				deposit_dt : event.item.deposit_dt
			"s_end_dt" : $M.getValue("s_end_dt")
		}
		var popupOption = "";
		$M.goNextPage('/acnt/acnt0201p07', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
	// 미오픈발주 푸터 금액 셋팅을위한 작업
	function destroyGrid() {
		AUIGrid.destroy("#auiGridFourth");
		AUIGrid.destroy("#auiGridFifth");
		AUIGrid.destroy("#auiGridSixth");
		auiGridFourth = null;
		auiGridFifth = null;
		auiGridSixth = null;
	};
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="search_dt" name="search_dt">
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
							<col width="60px">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>작성일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="조회 시작일">
								</div>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<!-- 폼테이블 -->
				<table class="table-border mt10">
					<colgroup>
						<col width="">
						<col width="">
						<col width="">
						<col width="">
						<col width="">
						<col width="">
					</colgroup>
					<thead>
					<tr>
						<th style="font-size: 15px;">구분</th>
						<th class="th-gray" style="font-size: 15px;">전일잔고</th>
						<th class="th-gray" style="font-size: 15px;">당일입고</th>
						<th class="th-gray" style="font-size: 15px;">당일출고</th>
						<th class="th-gray" style="font-size: 15px;">금일잔고</th>
						<th class="th-gray" style="font-size: 15px;">비고(예정대비 부족분)</th>
					</tr>
					</thead>
					<tbody>
					<tr>
						<th style="font-size: 15px;">현금</th>
						<td class="text-right" id="fundsType0_before_money" style="font-size: 15px;"></td>
						<td class="text-right" id="fundsType0_in_amt" style="font-size: 15px;"></td>
						<td class="text-right" id="fundsType0_out_amt" style="font-size: 15px;"></td>
						<td class="text-right" id="fundsType0_after_money" style="font-size: 15px;"></td>
						<td class="text-right" id="fundsType0_bigo" style="font-size: 15px;"></td>
					</tr>
					<tr>
						<th class="text-primary">
							<a class="funds_a_link" href="#" onclick="javascript:goDetail('W');" style="font-size: 15px;">예금잔액(WON)</a>
						</th>
						<td class="text-right" id="fundsType1_before_money" style="font-size: 15px;"></td>  
						<td class="text-right" id="fundsType1_in_amt" style="font-size: 15px;"></td>         
						<td class="text-right" id="fundsType1_out_amt" style="font-size: 15px;"></td>        
						<td class="text-right" id="fundsType1_after_money" style="font-size: 15px;"></td>    
						<td class="text-right" id="fundsType1_bigo" style="font-size: 15px;"></td>           
					</tr>
					<tr>
						<th class="text-primary">
							<a class="funds_a_link" href="#" onclick="javascript:goDetail('J');" style="font-size: 15px;">외화예금(JPY)</a>
						</th>
						<td class="text-right" id="fundsType2_before_money" style="font-size: 15px;"></td> 
						<td class="text-right" id="fundsType2_in_amt" style="font-size: 15px;"></td>       
						<td class="text-right" id="fundsType2_out_amt" style="font-size: 15px;"></td>      
						<td class="text-right" id="fundsType2_after_money" style="font-size: 15px;"></td>  
						<td class="text-right" id="fundsType2_bigo" style="font-size: 15px;"></td>         
					</tr>
					<tr>
						<th class="text-primary">
							<a class="funds_a_link" href="#" onclick="javascript:goDetail('U');" style="font-size: 15px;">외화예금(USD)</a>
						</th>
						<td class="text-right" id="fundsType3_before_money" style="font-size: 15px;"></td> 
						<td class="text-right" id="fundsType3_in_amt" style="font-size: 15px;"></td>       
						<td class="text-right" id="fundsType3_out_amt" style="font-size: 15px;"></td>      
						<td class="text-right" id="fundsType3_after_money" style="font-size: 15px;"></td>  
						<td class="text-right" id="fundsType3_bigo" style="font-size: 15px;"></td>         
					</tr>
					<tr>
						<th class="text-primary">
							<a class="funds_a_link" href="#" onclick="javascript:goDetail('E');" style="font-size: 15px;">외화예금(EUR)</a>
						</th>
						<td class="text-right" id="fundsType4_before_money" style="font-size: 15px;"></td> 
						<td class="text-right" id="fundsType4_in_amt" style="font-size: 15px;"></td>       
						<td class="text-right" id="fundsType4_out_amt" style="font-size: 15px;"></td>      
						<td class="text-right" id="fundsType4_after_money" style="font-size: 15px;"></td>  
						<td class="text-right" id="fundsType4_bigo" style="font-size: 15px;"></td>         
					</tr>
					<tr>
						<th class="text-primary">
							<a class="funds_a_link" href="#" onclick="javascript:goFundsDailySavings();" style="font-size: 15px;">예적금(WON)</a>
						</th>
						<td class="text-right" id="fundsType5_before_money" style="font-size: 15px;"></td> 
						<td class="text-right" id="fundsType5_in_amt" style="font-size: 15px;"></td>       
						<td class="text-right" id="fundsType5_out_amt" style="font-size: 15px;"></td>      
						<td class="text-right" id="fundsType5_after_money" style="font-size: 15px;"></td>  
						<td class="text-right" id="fundsType5_bigo" style="font-size: 15px;"></td>         
					</tr>
					</tbody>
				</table>
				<!-- /폼테이블 -->

				<div class="row">
					<div class="col-2">
						<!-- 입금예정금액(받을어음)-->
						<div class="title-wrap mt10">
							<h4>입금예정금액(받을어음)</h4>
						</div>
						<div id="auiGridFirst" style="margin-top: 5px; height: 300px;"></div>
						<!-- /입금예정금액(받을어음)-->
					</div>
					<div class="col-2">
						<!-- 입금예정금액(외화) -->
						<div class="title-wrap mt10">
							<h4 class="spacing-sm">입금예정금액(외화)</h4>
							<div class="btn-group">
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goFundsInPlanAdd();">입금예정</button>
								</div>
							</div>
						</div>
						<div id="auiGridSecond" style="margin-top: 5px; height: 300px;"></div>
						<!-- /입금예정금액(외화) -->
					</div>
					<div class="col-2">
						<!-- 지출예정금액(WON) -->
						<div class="title-wrap mt10">
							<h4 class="spacing-sm">지출예정금액(WON)</h4>
							<div class="btn-group">
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goFundsOutPlanAdd()">지출예정</button>
								</div>
							</div>
						</div>
						<div id="auiGridThird" style="margin-top: 5px; height: 300px;"></div>
						<!-- /지출예정금액(WON) -->
					</div>
					<div class="col-2">
						<!-- 지출예정금액(JPY) -->
						<div class="title-wrap mt10">
							<h4>지출예정금액(JPY)</h4>
						</div>
						<div id="auiGridFourth" style="margin-top: 5px; height: 300px;"></div>
						<!-- /지출예정금액(JPY) -->
					</div>
					<div class="col-2">
						<!-- 지출예정금액(JUSD) -->
						<div class="title-wrap mt10">
							<h4>지출예정금액(USD)</h4>
						</div>
						<div id="auiGridFifth" style="margin-top: 5px; height: 300px;"></div>
						<!-- /지출예정금액(JUSD) -->
					</div>
					<div class="col-2">
						<!-- 지출예정금액(기타) -->
						<div class="title-wrap mt10">
							<h4>지출예정금액(기타)</h4>
						</div>
						<div id="auiGridSixth" style="margin-top: 5px; height: 300px;"></div>
						<!-- /지출예정금액(기타) -->
					</div>
				</div>
			</div>
		</div>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>