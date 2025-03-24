<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 무상정비금액
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
		});

		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "무상정비금액");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showFooter: true,
				footerPosition : "top"
			};

			var columnLayout = [];
			if ("${inputParam.type}" == "1") {
				// 부품비
				columnLayout = [
					{
						headerText: "전표번호",
						dataField: "inout_doc_no",
						width: "14%",
						style: "aui-center",
					},
					{
						headerText: "고객",
						dataField: "cust_name",
						width: "12%",
						style: "aui-center",
					},
					{
						headerText: "업체명",
						dataField: "breg_name",
						width: "17%",
						style: "aui-center",
					},
					{
						headerText: "적요",
						dataField: "desc_text",
						style: "aui-left",
					},
					{
						headerText: "부품비",
						dataField: "free_part_amt",
						width: "12%",
						dataType: "numeric",
						formatString: "#,##0",
						style: "aui-right",
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return  value == "" || value == null ? "" : $M.setComma(value);
                        }
					},
					{
						headerText: "비고",
						dataField: "remark",
						width: "14%",
						style: "aui-center",
					},
				];
			} else if ("${inputParam.type}" == "2") {
				// 출장비/공임
				columnLayout = [
					{
						headerText: "전표번호",
						dataField: "inout_doc_no",
						visible : false
					},
					{
						headerText: "처리일자",
						dataField: "inout_dt",
						dataType: "date",
						formatString: "yyyy-mm-dd",
						style: "aui-center aui-popup",
						width : "100"
					},
					{
						dataField: "machine_seq",
						visible : false
					},
					{
						headerText: "차대번호",
						dataField: "body_no",
						style: "aui-center aui-popup",
						width : "200"
					},
					{
						headerText: "장비계약자",
						dataField: "doc_mem_name",
						style: "aui-center",
					},
					{
						headerText: "장비명",
						dataField: "machine_name",
						style: "aui-center",
					},
					{
						headerText: "판매일자",
						dataField: "sale_dt",
						dataType: "date",
						formatString: "yyyy-mm-dd",
						style: "aui-center",
						width : "100"
					},
					{
						headerText: "차주명",
						dataField: "cust_name",
						style: "aui-center aui-popup",
					},
					{
						dataField: "cust_no",
						visible : false
					},
					{
						headerText: "업체명",
						dataField: "breg_name",
						style: "aui-center",
					},
					{
						headerText: "작성자",
						dataField: "mem_name",
						style: "aui-center",
					},
					{
						headerText: "부품비",
						dataField: "free_part_amt",
						width: "12%",
						dataType: "numeric",
						formatString: "#,##0",
						style: "aui-right",
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return  value == "" || value == null ? "" : $M.setComma(value);
                        }
					},
					{
						headerText: "출장비",
						dataField: "free_travel_amt",
						dataType: "numeric",
						formatString: "#,##0",
						style: "aui-right",
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return  value == "" || value == null ? "" : $M.setComma(value);
                        }
					},
					{
						headerText: "공임비",
						dataField: "free_work_amt",
						dataType: "numeric",
						formatString: "#,##0",
						style: "aui-right",
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return  value == "" || value == null ? "" : $M.setComma(value);
                        }
					},
                    {
                        headerText: "합계",
                        dataField: "sum_amt",
                        dataType: "numeric",
                        formatString: "#,##0",
                        style: "aui-right",
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return  value == "" || value == null ? "" : $M.setComma(value);
                        }
                    },
                    {
						headerText: "비고",
						dataField: "remark",
						width: "14%",
						style: "aui-center",
					},
				];
			}

			var footerColumnLayout = [];
			if ("${inputParam.type}" == "1") {
				// 부품비
				footerColumnLayout = [
					{
						labelText: "합계",
						positionField: "jeokyo",
						style: "aui-center aui-footer",
					},
					{
						dataField: "free_part_amt",
						positionField: "free_part_amt",
						operation: "SUM",
						formatString: "#,##0",
						style: "aui-right aui-footer",
					},
				];
			} else if ("${inputParam.type}" == "2") {
				// 출장비/공임
				footerColumnLayout = [
					{
						labelText: "합계",
						positionField: "mem_name",
						style: "aui-center aui-footer",
					},
					{
						dataField: "free_part_amt",
						positionField: "free_part_amt",
						operation: "SUM",
						formatString: "#,##0",
						style: "aui-right aui-footer",
					},
					{
						dataField: "free_travel_amt",
						positionField: "free_travel_amt",
						operation: "SUM",
						formatString: "#,##0",
						style: "aui-right aui-footer",
					},
					{
						dataField: "free_work_amt",
						positionField: "free_work_amt",
						operation: "SUM",
						formatString: "#,##0",
						style: "aui-right aui-footer",
					},
                    {
                        dataField: "sum_amt",
                        positionField: "sum_amt",
                        operation: "SUM",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                    }
				];
			}

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "body_no") {
                	/* 
                    var popupOption = "";
                    // 매출처리
                    if (event.item.inout_doc_no.startsWith('IN')) {
                        var param = {
                            "inout_doc_no": event.item.inout_doc_no,
                        };
                        $M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus: popupOption});		// 매출처리 상세
                    } else { // 서비스일지
                    	var params = {
                            "s_as_no": event.item.inout_doc_no,
                        };
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                    } 
                    */
                    // (Q&A 13073) 차대번호 선택시 장비대장팝업 211023 김상덕
					var params = {
						"s_machine_seq": event.item.machine_seq
					};
					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
             	// (Q&A 13073) 차주명 선택시 고객대장팝업 211023 김상덕
                if (event.dataField == "cust_name") {
                	var param = {
							cust_no : event.item["cust_no"]
						};
					
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
					$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
                }
             	
             	if(event.dataField == "inout_dt") {
                    var popupOption = "";
                    // 매출처리
                    if (event.item.inout_doc_no.startsWith('IN')) {
                        var param = {
                            "inout_doc_no": event.item.inout_doc_no,
                        };
                        $M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus: popupOption});		// 매출처리 상세
                    } else { // 서비스일지
                    	var params = {
                            "s_as_no": event.item.inout_doc_no,
                        };
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                    } 
             	}
            });

			$("#auiGrid").resize();
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
                    <h4>${subTitle}</h4>
                    <div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary">${total_cnt}</strong>건
                </div>
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