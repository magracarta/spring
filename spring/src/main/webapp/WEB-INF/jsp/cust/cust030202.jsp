<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 일계표 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridTop();
			createAUIGridMid();
			createAUIGridBottom();
			fnInit();
		});
		
		function fnInit() {
			<%--if(${checkYn} == "Y" && "${SecureUser.org_type}" == "BASE") {--%>
			if(${checkYn} == "Y" && ${page.fnc.F00675_001 eq 'Y'}) {
				$M.reloadComboData("s_org_code", []);
			}
			$("#_goCancelDone").addClass("dpn");				
			$("#_goDone").addClass("dpn");		
		}
		
		function fnChangeEndDt() {
			$M.setValue("s_end_dt", $M.getValue("s_start_dt"));
// 			if("${SecureUser.org_type}" == "BASE") {
// 				$('#s_org_code').combogrid("setValues", "");  
// 			}
// 			goSearchRequirement();
			goSearch();
		}
		
		// 검색조건 조회
		function goSearchRequirement() {
			$M.setValue("s_org_code_str", $M.getValue("s_org_code"));
			$("#title").text("");
			var param = {
					"s_search_type" : "Y",
					"s_org_code_str" : $M.getValue("s_org_code"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_start_year" : $M.getValue("s_start_dt").substring(0, 4) + "1231",
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			$M.goNextPageAjax('/cust/cust030201/searchDay', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							
							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00675_001 eq 'Y'}) {
								$M.reloadComboData("s_org_code", result.orgList);
							}
							
							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00675_001 eq 'Y'}) {
								var orgCodeArr = $M.getValue("s_org_code_str").split("#");
								$('#s_org_code').combogrid("setValues", orgCodeArr);  
							}
							
							$M.setValue("confirm_date", result.confirmDate);
							fnEndChange(result.endYn, result.mngYn, result.title);
							
						};
					}
				);
		}
		
		function goSearch() {
			$M.setValue("s_org_code_arr", $M.getValue("s_org_code"));
			$M.setValue("s_org_code_str", $M.getValue("s_org_code"));
			$("#title").text("");
			var param = {
					"s_org_code_str" : $M.getValue("s_org_code"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_start_year" : $M.getValue("s_start_dt").substring(0, 4) + "1231",
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_search_type" : "Y"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGridTop, result.searchList);
							AUIGrid.setGridData(auiGridMid, result.monthList);
							AUIGrid.setGridData(auiGridBottom, result.inoutList);
							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00675_001 eq 'Y'}) {
								$M.reloadComboData("s_org_code", result.orgList);
							}
							
							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00675_001 eq 'Y'}) {
								var orgCodeArr = $M.getValue("s_org_code_str").split("#");
								$('#s_org_code').combogrid("setValues", orgCodeArr);  
							}
							
							$M.setValue("confirm_date", result.confirmDate);
							fnEndChange(result.endYn, result.mngYn, result.title);
							
						};
					}
				);
		}
		
		// 일마감처리, 일마감취소 버튼 이벤트
		function fnEndChange(endYn, mngYn, title) {
// 			alert(mngYn);
// 			alert(endYn);
			$("#_goCancelDone").addClass("dpn");				
			$("#_goDone").addClass("dpn");		
// 			if(mngYn == "Y") {
// 				$("#_goCancelDone").removeClass("dpn");
// 				$("#_goDone").removeClass("dpn");
// 			} else {
// 				$("#_goCancelDone").addClass("dpn");				
// 				$("#_goDone").addClass("dpn");			
// 			}
			
			if(endYn == "Y" && mngYn == "Y") {
				$("#title").text(title);
				$("#_goCancelDone").removeClass("dpn");	
				$("#_goDone").addClass("dpn");		
			} else if(endYn == "N" && mngYn == "Y") {
				$("#title").text(title);
				$("#_goDone").removeClass("dpn");
				$("#_goCancelDone").addClass("dpn");
			} else if (endYn == "" && mngYn == "Y") {
				$("#_goCancelDone").addClass("dpn");				
				$("#_goDone").removeClass("dpn");				
// 				$("#_goDone").addClass("dpn");				
			}
		}
		
		function goDone() {

			var param = {
				"org_code" : $M.getValue("s_org_code"),
				"end_dt" :  $M.getValue("s_end_dt")
			}
			var msg = "일마감처리 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030202/endConfirm", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
						$("#_goCancelDone").removeClass("dpn");			
						$("#_goDone").addClass("dpn");			
					};
				}
			);
		}
		
		function goCancelDone() {
			var param = {
					"org_code" : $M.getValue("s_org_code"),
					"end_dt" :  $M.getValue("s_end_dt"),
					"confirm_date" :  $M.getValue("confirm_date")
				}
			var msg = "일마감취소 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030202/endCancel", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
						$("#_goDone").removeClass("dpn");
						$("#_goCancelDone").addClass("dpn");		
					};
				}
			);
		}
		
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGridTop, "일계표-기간내 거래집계", exportProps);
		}
		
		function fnExcelDownload() {
			// 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGridMid, "일계표-월간 거래집계", exportProps);
		}
		
		function fnExcelDownSec() {
			// 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGridBottom, "일계표-매입/매출 (입/출금)확정내역", exportProps);
		}
		

		//그리드생성
		function createAUIGridTop() {
			var gridPros = {
				rowIdField : "acc_type_cd",
				showStateColumn : false,
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "구분", 
					dataField : "acc_type_name", 
					width : "125",
					minWidth : "115",
					style : "aui-center"
				},
				{
					headerText : "매출",
					children : [
						{
							dataField : "out_doc_amt",
							headerText : "물품대",
							width : "120",
							minWidth : "120",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right aui-popup",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}, 
						{
							dataField : "out_discount_amt",
							headerText : "할인액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_vat_amt",
							headerText : "부가세",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_total_amt",
							headerText : "계",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_inout_amt",
							headerText : "입금액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}
					]
				}, 
				{
					headerText : "매입",
					children : [
						{
							dataField : "in_doc_amt",
							headerText : "물품대",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right aui-popup",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}, 
						{
							dataField : "in_discount_amt",
							headerText : "할인액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_vat_amt",
							headerText : "부가세",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_total_amt",
							headerText : "계",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_inout_amt",
							headerText : "입금액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120",
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}
					]
				},
				{
					dataField : "acc_type_cd",
					visible : false
				}
				
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "계",
					positionField : "acc_type_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "out_doc_amt",
					positionField : "out_doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_discount_amt",
					positionField : "out_discount_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_vat_amt",
					positionField : "out_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_total_amt",
					positionField : "out_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_doc_amt",
					positionField : "in_doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_discount_amt",
					positionField : "in_discount_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_vat_amt",
					positionField : "in_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_total_amt",
					positionField : "in_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridTop, footerColumnLayout);
			AUIGrid.setGridData(auiGridTop, []);
			$("#auiGridTop").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGridTop, "cellClick", function(event) {
				var popupOption = "";
				console.log(event);
				// 매출
				if(event.dataField == "out_doc_amt") {
					var params = {
							"s_acc_type_cd" : event.item["acc_type_cd"],
							"s_start_dt" : $M.getValue("s_start_dt"),
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "OUT"
					};
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
				// 매입
				if(event.dataField == "in_doc_amt") {
					var params = {
							"s_acc_type_cd" : event.item["acc_type_cd"],
							"s_start_dt" : $M.getValue("s_start_dt"),
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "IN"
					};
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		//그리드생성
		function createAUIGridMid() {
			var gridPros = {
				rowIdField : "acc_type_cd",
				showStateColumn : false,
				showRowNumColumn: false,
				//푸터 상단 고정
				// footerPosition : "top",
				showFooter : true,
				footerPosition : "top",
				editable : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "구분", 
					dataField : "acc_type_name", 
					width : "125",
					minWidth : "125",
					style : "aui-center"
				},
				{
					headerText : "매출",
					children : [
						{
							dataField : "out_doc_amt",
							headerText : "물품대", 
							width : "120",
							minWidth : "120", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right aui-popup",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}, 
						{
							dataField : "out_discount_amt",
							headerText : "할인액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_vat_amt",
							headerText : "부가세",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_total_amt",
							headerText : "계",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "out_inout_amt",
							headerText : "입금액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}
					]
				}, 
				{
					headerText : "매입",
					children : [
						{
							dataField : "in_doc_amt",
							headerText : "물품대",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right aui-popup",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}, 
						{
							dataField : "in_discount_amt",
							headerText : "할인액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_vat_amt",
							headerText : "부가세",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_total_amt",
							headerText : "계",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						},
						{
							dataField : "in_inout_amt",
							headerText : "입금액",
							dataType : "numeric",
							formatString : "#,##0",
							width : "120",
							minWidth : "120", 
							style : "aui-right",
							xlsxTextConversion : true,
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var amt = value;
								return amt == "0" ? "" : $M.setComma(amt);
							}
						}
					]
				},
				{
					dataField : "acc_type_cd",
					visible : false
				}
				
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "계",
					positionField : "acc_type_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "out_doc_amt",
					positionField : "out_doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_discount_amt",
					positionField : "out_discount_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_vat_amt",
					positionField : "out_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_total_amt",
					positionField : "out_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_doc_amt",
					positionField : "in_doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_discount_amt",
					positionField : "in_discount_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_vat_amt",
					positionField : "in_vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "in_total_amt",
					positionField : "in_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGridMid = AUIGrid.create("#auiGridMid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridMid, footerColumnLayout);
			AUIGrid.setGridData(auiGridMid, []);
			$("#auiGridMid").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGridMid, "cellClick", function(event) {
				var popupOption = "";
				console.log(event);
				// 매출
				if(event.dataField == "out_doc_amt") {
					var startDt = $M.getValue("s_end_dt").substring(0, 6) + "01";
					var params = {
							"s_acc_type_cd" : event.item["acc_type_cd"],
							"s_start_dt" : startDt,
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "OUT"
					};
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
				// 매입
				if(event.dataField == "in_doc_amt") {
					var startDt = $M.getValue("s_end_dt").substring(0, 6) + "01";
					var params = {
							"s_acc_type_cd" : event.item["acc_type_cd"],
							"s_start_dt" : startDt,
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "IN"
					};
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		//그리드생성
		function createAUIGridBottom() {
			var gridPros = {
				rowIdField : "gubun",
				showStateColumn : false,
				showRowNumColumn: false,
				editable : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "구분", 
					dataField : "gubun_name", 
					width : "125",
					minWidth : "125", 
					style : "aui-center"
				},
				{
					headerText : "매출",
					children : [
						{
							headerText : "전체",
							children : [
								{
									dataField : "out_all_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									xlsxTextConversion : true,
									style : "aui-right aui-popup",
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "out_all_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						{
							headerText : "확정",
							children : [
								{
									dataField : "out_confirm_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "out_confirm_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						{
							headerText : "미확정",
							children : [
								{
									dataField : "out_untreat_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "out_untreat_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						
					]
				}, 
				{
					headerText : "매입",
					children : [
						{
							headerText : "전체",
							children : [
								{
									dataField : "in_all_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right aui-popup",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "in_all_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						{
							headerText : "확정",
							children : [
								{
									dataField : "in_confirm_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "in_confirm_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						{
							headerText : "미확정",
							children : [
								{
									dataField : "in_untreat_qty",
									headerText : "매수",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}, 
								{
									dataField : "in_untreat_amt",
									headerText : "금액",
									dataType : "numeric",
									formatString : "#,##0",
									width : "100",
									minWidth : "100", 
									style : "aui-right",
									xlsxTextConversion : true,
									labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
										var amt = value;
										return amt == "0" ? "" : $M.setComma(amt);
									}
								}
							]
						}, 
						
					]
				}, 
				{
					dataFieid : "gubun",
					visible : false
				}
				
			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, []);
			$("#auiGridBottom").resize();
			AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
				var popupOption = "";
				var startDt = "";
				console.log(event);
				// 매출
				if(event.dataField == "out_all_qty") {
					if(event.item["gubun"] == "1") {
						startDt = $M.getValue("s_start_dt");
					} else {
						startDt = $M.getValue("s_end_dt").substring(0, 6) + "01";
					}
					var params = {
							"s_start_dt" : startDt,
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "OUT"
					};
					console.log(params.s_org_code_str);
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
				// 매입
				if(event.dataField == "in_all_qty") {
					if(event.item["gubun"] == "1") {
						startDt = $M.getValue("s_start_dt");
					} else {
						startDt = $M.getValue("s_end_dt").substring(0, 6) + "01";
					}
					var params = {
							"s_start_dt" : startDt,
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_org_code_str" : $M.getValue("s_org_code_arr"),
							"s_inout_gubun" : "IN"
					};
					$M.goNextPage('/cust/cust0302p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_org_code_arr" name="s_org_code_arr"> <!-- 파라미터용 input -->
<input type="hidden" id="confirm_date" name="confirm_date">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->					
					<div class="search-wrap mt10">				
						<table class="table">
							<colgroup>
								<col width="55px">
								<col width="260px">
								<col width="55px">
<%--								<c:if test="${SecureUser.org_type ne 'BASE'}">--%>
								<c:if test="${page.fnc.F00675_001 ne 'Y'}">
									<col width="120px">
								</c:if>
<%--								<c:if test="${SecureUser.org_type eq 'BASE'}">--%>
								<c:if test="${page.fnc.F00675_001 eq 'Y'}">
									<col width="300px">
								</c:if>
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>전표일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" onChange="javascript:fnChangeEndDt();">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}">
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
									<th>부서</th>
									<td>
										<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
<%--										<c:if test="${SecureUser.org_type ne 'BASE'}">--%>
										<c:if test="${page.fnc.F00675_001 ne 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
											<input type="hidden" value="${SecureUser.org_code}" id="s_org_code" name="s_org_code" readonly="readonly"> 
										</c:if>
										<!-- 본사의 경우, 전체 센터목록 선택가능 -->
<%--										<c:if test="${SecureUser.org_type eq 'BASE'}">--%>
										<c:if test="${page.fnc.F00675_001 eq 'Y'}">
											<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
											   easyuiname="orgList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>					
										</c:if>	
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>	
								</tr>
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 기간내 거래집계 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>기간내 거래집계</h4>
						</div>
						<div class="right">
							<span id="title" style="font-weight:bold"></span>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridTop" style="margin-top: 5px; height: 240px; width:100%;"></div>
<!-- /기간내 거래집계 -->
<!-- 월간 거래집계 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>월간 거래집계</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridMid" style="margin-top: 5px; height: 240px;"></div>
<!-- /월간 거래집계 -->
<!-- 매입/매출 (입/출금)확정내역 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>매입/매출 (입/출금)확정내역</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridBottom" style="margin-top: 5px; height: 132px;"></div>
<!-- /매입/매출 (입/출금)확정내역 -->
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>