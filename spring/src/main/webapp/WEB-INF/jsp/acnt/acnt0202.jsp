<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-08-31 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGridTop;

	// [3차 QNA-14445] 외화 기능 제거
	// var auiGridBottom;
	
	$(document).ready(function () {
		fnInit();
	});

	function fnInit() {
		createAUIGridTop();

		// [3차 QNA-14445] 외화 기능 제거
		// createAUIGridBottom();
	}

	// 조회
	function goSearch(val) {
		if (val != undefined) {
			$M.setValue("s_end_dt", val);
		}
		
		var param = {
				s_end_dt : $M.getValue("s_end_dt"),
			};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					if (result.feList.length == 0 && result.list.length == 0) {
						alert("조회 결과가 없습니다.");
					}

					// [3차 QNA-14445] 외화 기능 제거
					// if (result.feList.length == 0) {
					// 	AUIGrid.clearGridData(auiGridBottom);
					// } else {
					// 	AUIGrid.setGridData(auiGridBottom, result.feList);
					// }

					if (result.list.length == 0) {
						AUIGrid.clearGridData(auiGridTop);
					} else {
						AUIGrid.setGridData(auiGridTop, result.list);
					}
				};
			}		
		);	
	}

	// 원화 + 외화예금 등록
	function goAdd() {
		console.log($M.getValue("s_end_dt"));
		var param = {
				s_end_dt : $M.getValue("s_end_dt")
		}
		
		var popupOption = "";
		$M.goNextPage('/acnt/acnt0202p04', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 외화 등록
	// [3차 QNA-14445] 외화 기능 제거
	// function goNew() {
	// 	var param = {
	// 			s_end_dt : $M.getValue("s_end_dt")
	// 	}
	//
	// 	var popupOption = "";
	// 	$M.goNextPage('/acnt/acnt0202p05', $M.toGetParam(param), {popupStatus : popupOption});
	// }

	function fnDownloadExcel() {
		var exportProps = {
		         // 제외항목
		  };
	  	fnExportExcel(auiGridTop, "자금일보관리 - 원화 + 외화예금", exportProps);
	}

	// [3차 QNA-14445] 외화 기능 제거
	// function fnExcelDownSec() {
	// 	var exportProps = {
	// 	         제외항목
		  // };
	  	// fnExportExcel(auiGridBottom, "자금일보관리 - 외화", exportProps);
	// }

	function createAUIGridTop() {
		var gridPros = {
			// Row번호 표시 여부
			showRowNumColum : true,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
		};

		var columnLayout = [
			{
				dataField : "funds_type_cd",
				visible : false
			},
			{
				headerText : "계정과목",
				dataField : "funds_type_name",
				style : "aui-center aui-popup",
				width : "100",
				minWidth : "100",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "관리번호",
				dataField : "deposit_code",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "관리명",
				dataField : "deposit_name",
				style : "aui-center",
				width : "160",
				minWidth : "160",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "이월",
				dataField : "before_amt",
				dataType : "numeric",
				width : "140",
				minWidth : "140",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					} else {
						return item.funds_type_cd == "0" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00");  
					}
				},
			},
			{
				headerText : "입금",
				dataField : "in_amt",
				dataType : "numeric",
				width : "140",
				minWidth : "140",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					} else {
					    return item.funds_type_cd == "0" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00"); 
					}
				},
			},
			{
				headerText : "출금",
				dataField : "out_amt",
				dataType : "numeric",
				width : "140",
				minWidth : "140",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					} else {
					    return item.funds_type_cd == "0" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00"); 
					}
				},
			},
			{
				headerText : "잔액",
				dataField : "balance_amt",
				dataType : "numeric",
				width : "140",
				minWidth : "140",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					if (value == 0) {
						return "";
					} else {
					    return item.funds_type_cd == "0" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00"); 
					}
				},
			},
			{
				headerText : "비고",
				dataField : "remark",
				style : "aui-left",
				width : "380",
				minWidth : "80",
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "deposit_name",
				style: "aui-center aui-footer"
			},
// 			{
// 				dataField: "before_amt",
// 				positionField: "before_amt",
// 				operation: "SUM",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
// 				style: "aui-right aui-footer"
// 			},
			{
				dataField: "in_amt",
				positionField: "in_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				rounding : "floor",
				style: "aui-right aui-footer"
			},
			{
				dataField: "out_amt",
				positionField: "out_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				rounding : "floor",
				style: "aui-right aui-footer"
			},
// 			{
// 				dataField: "balance_amt",
// 				positionField: "balance_amt",
// 				operation: "SUM",
// 				formatString : "#,##0.00",
// 				rounding : "floor",
// 				style: "aui-right aui-footer"
// 			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGridTop, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridTop, ${list});
		
		// 원화 + 외화예금 팝업 상세이동
		AUIGrid.bind(auiGridTop, "cellClick", function(event) {
			if(event.dataField == "funds_type_name") {
				console.log(event);
				var param = {
						funds_daily_no : event.item.funds_daily_no,
						funds_dt : event.item.funds_dt,
						funds_type_cd : event.item.funds_type_cd,
						deposit_code : event.item.deposit_code
				};
			
				var popupOption = "";
				$M.goNextPage('/acnt/acnt0202p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}

	// [3차 QNA-14445] 외화 기능 제거
<%--	function createAUIGridBottom() {--%>
<%--		var gridPros = {--%>
<%--			// Row번호 표시 여부--%>
<%--			showRowNumColum : true,--%>
<%--			enableFilter :true,--%>
<%--			showFooter : true,--%>
<%--			footerPosition : "top",--%>
<%--		};--%>

<%--		var columnLayout = [--%>
<%--			{--%>
<%--				dataField : "funds_type_cd",--%>
<%--				visible : false--%>
<%--			},--%>
<%--// 			{--%>
<%--// 				headerText : "관리번호",--%>
<%--// 				dataField : "deposit_code",--%>
<%--// 				style : "aui-center",--%>
<%--// 			},--%>
<%--			{--%>
<%--				headerText : "환종",--%>
<%--				dataField : "money_unit_cd",--%>
<%--				width : "60",--%>
<%--				minWidth : "60",--%>
<%--				style : "aui-center aui-popup",--%>
<%--				filter : {--%>
<%--					showIcon : true--%>
<%--				}--%>
<%--			},--%>
<%--			{--%>
<%--				headerText : "이월",--%>
<%--				dataField : "",--%>
<%--				children : [--%>
<%--					{--%>
<%--						headerText : "외화금액",--%>
<%--						dataField : "fe_before_amt",--%>
<%--						dataType : "numeric",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "환율",--%>
<%--						dataField : "apply_er_price",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.0000",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.0000");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "금액(원)",--%>
<%--						dataField : "before_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "90",--%>
<%--						minWidth : "90",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--// 							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0");--%>
<%--							}--%>
<%--						},--%>
<%--					}--%>
<%--				]--%>
<%--			},--%>
<%--			{--%>
<%--				headerText : "입금",--%>
<%--				dataField : "",--%>
<%--				children : [--%>
<%--					{--%>
<%--						headerText : "외화금액",--%>
<%--						dataField : "fe_in_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "환율",--%>
<%--						dataField : "apply_er_price",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.0000",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.0000");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "금액(원)",--%>
<%--						dataField : "in_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "90",--%>
<%--						minWidth : "90",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--// 							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0");--%>
<%--							}--%>
<%--						},--%>
<%--					}--%>
<%--				]--%>
<%--			},--%>
<%--			{--%>
<%--				headerText : "출금",--%>
<%--				dataField : "",--%>
<%--				children : [--%>
<%--					{--%>
<%--						headerText : "외화금액",--%>
<%--						dataField : "fe_out_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "환율",--%>
<%--						dataField : "apply_er_price",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.0000",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.0000");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "금액(원)",--%>
<%--						dataField : "out_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "90",--%>
<%--						minWidth : "90",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--// 							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0");--%>
<%--							}--%>
<%--						},--%>
<%--					}--%>
<%--				]--%>
<%--			},--%>
<%--			{--%>
<%--				headerText : "잔액",--%>
<%--				dataField : "",--%>
<%--				children : [--%>
<%--					{--%>
<%--						headerText : "외화금액",--%>
<%--						dataField : "fe_balance_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.00",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "환율",--%>
<%--						dataField : "apply_er_price",--%>
<%--						dataType : "numeric",--%>
<%--						width : "80",--%>
<%--						minWidth : "80",--%>
<%--// 						formatString : "#,##0.0000",--%>
<%--// 						rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0.0000");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--					{--%>
<%--						headerText : "금액(원)",--%>
<%--						dataField : "balance_amt",--%>
<%--						dataType : "numeric",--%>
<%--						width : "90",--%>
<%--						minWidth : "90",--%>
<%--//		 				formatString : "#,##0.00",--%>
<%--//		 				rounding : "floor",--%>
<%--						style : "aui-right",--%>
<%--						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {--%>
<%--							if (value == 0) {--%>
<%--								return "";--%>
<%--							} else {--%>
<%--//		 					    return AUIGrid.formatNumber(value, "#,##0.00");--%>
<%--							    return AUIGrid.formatNumber(value, "#,##0");--%>
<%--							}--%>
<%--						},--%>
<%--					},--%>
<%--				]--%>
<%--			},--%>
<%--			{--%>
<%--				headerText : "비고",--%>
<%--				dataField : "remark",--%>
<%--				style : "aui-left",--%>
<%--				width : "210",--%>
<%--				minWidth : "110",--%>
<%--			}--%>
<%--		];--%>

<%--		// 푸터 설정--%>
<%--		var footerLayout = [--%>
<%--			{--%>
<%--				labelText : "합계",--%>
<%--				positionField : "money_unit_cd"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "fe_before_amt",--%>
<%--				positionField: "fe_before_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0.00",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "before_amt",--%>
<%--				positionField: "before_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "fe_in_amt",--%>
<%--				positionField: "fe_in_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0.00",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "in_amt",--%>
<%--				positionField: "in_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "fe_out_amt",--%>
<%--				positionField: "fe_out_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0.00",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "out_amt",--%>
<%--				positionField: "out_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "fe_balance_amt",--%>
<%--				positionField: "fe_balance_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0.00",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			},--%>
<%--			{--%>
<%--				dataField: "balance_amt",--%>
<%--				positionField: "balance_amt",--%>
<%--				operation: "SUM",--%>
<%--				formatString : "#,##0",--%>
<%--				rounding : "floor",--%>
<%--				style: "aui-right aui-footer"--%>
<%--			}--%>
<%--		];--%>

<%--		// 실제로 #grid_wrap에 그리드 생성--%>
<%--		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);--%>
<%--		// 푸터 레이아웃 세팅--%>
<%--		AUIGrid.setFooter(auiGridBottom, footerLayout);--%>
<%--		// 그리드 갱신--%>
<%--		AUIGrid.setGridData(auiGridBottom, ${feList});--%>
<%--		AUIGrid.bind(auiGridBottom, "cellClick", function(event) {--%>
<%--			if(event.dataField == "money_unit_cd") {--%>
<%--				var param = {--%>
<%--						funds_daily_no : event.item.funds_daily_no,--%>
<%--						funds_dt : event.item.funds_dt,--%>
<%--						funds_type_cd : event.item.funds_type_cd,--%>
<%--						deposit_code : event.item.deposit_code--%>
<%--				};--%>

<%--				var popupOption = "";--%>
<%--				$M.goNextPage('/acnt/acnt0202p02', $M.toGetParam(param), {popupStatus : popupOption});--%>
<%--			}--%>
<%--		});--%>
<%--	}--%>
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
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="작성일자">
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
				<!-- 원화 + 외화예금 -->
				<div class="title-wrap mt10">
					<h4>원화 + 외화예금</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGridTop" style="margin-top: 5px; height: 500px;"></div>
				<!-- /원화 + 외화예금 -->

				<!-- 외화 -->
				<%-- [3차 QNA-14445] 외화 기능 제거 --%>
<%--				<div class="title-wrap mt10">--%>
<%--					<h4>외화</h4>--%>
<%--					<div class="btn-group">--%>
<%--						<div class="right">--%>
<%--							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>--%>
<%--						</div>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--				<div id="auiGridBottom" style="margin-top: 5px; height: 300px;"></div>--%>
				<!-- /외화 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>