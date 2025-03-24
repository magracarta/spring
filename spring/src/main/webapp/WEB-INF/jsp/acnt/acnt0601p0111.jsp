<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > null > 월별내역보기
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-09-17 17:11:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGridSalary;
	
	$(document).ready(function () {
		createAUIGridSalary();
		goSearch();
	});
	
// 	// 월급여업로드
// 	function goExcelUpload() {

// 		var popupOption = "";
// 		var param = {
// 			"s_year" : $M.getValue("s_year")
// 		};

// 		$M.goNextPage('/acnt/acnt0601p0109', $M.toGetParam(param), {popupStatus : popupOption});
// 	}

// 	// 센터별지출업로드
// 	function goExcelUploadSec() {

// 		var popupOption = "";
// 		var param = {
// 			"out_year" : $M.getValue("s_year"),
// 			"org_code" : $M.getValue("org_code")
// 		};

// 		$M.goNextPage('/acnt/acnt0601p0110', $M.toGetParam(param), {popupStatus : popupOption});
// 	}
	
	// 조회
	function goSearch() {
		var yearMon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
		var params = {
			"s_salary_mon": yearMon,
			"s_search_yn" : "Y",
			"mem_no" : '${inputParam.mem_no}',
			"s_year" : $M.getValue("s_year")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridSalary, result.salaryList);
				};
			}		
		);
	}
	
	// 날짜 Setting
	function fnSetYearMon(year, mon) {
		return year + (mon.length == 1 ? "0" + mon : mon);
	}
	
	// 인건비 종합 그리드
	function createAUIGridSalary() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : false
		};

		var columnLayout = [
			{
				headerText : "기간",
				dataField : "salary_mon",
				editable : false,
				width : "120",
				minWidth : "90",
				style : "aui-center"
			},
			{
				headerText : "급여",
				dataField : "salary_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			},
			{
				headerText : "인센티브",
				dataField : "incentive_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			},
			{
				headerText : "기타",
				dataField : "etc_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			},
			{
				headerText : "지급액",
				dataField : "pay_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			},
			{
				headerText : "4대보험",
				dataField : "four_insur_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			},
			{
				headerText : "총합계",
				dataField : "total_salary_amt",
				width : "170",
				minWidth : "130",
				dataType: "numeric",
				formatString: "#,##0",
				style : "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					return value == 0 ? "" : $M.setComma(value);
				}
			}
		];

		auiGridSalary = AUIGrid.create("#auiGridSalary", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridSalary, []);
		$("#auiGridSalary").resize();
	}
	
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_year" name="s_year" value="${inputParam.s_year}">
<input type="hidden" id="s_mon" name="s_mon" value="${inputParam.s_mon}">
<input type="hidden" id="org_code" name="org_code" value="${memInfo.org_code}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->					
			<div>
				<div class="title-wrap">
					<h4>인건비 종합</h4>
					<div class="btn-group">
						<div class="right">
<%-- 							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include> --%>
						</div>
					</div>
				</div>
				<div id="auiGridSalary" style="margin-top: 5px; height: 350px;"></div>
<!-- 급여사항 -->
			<div class="title-wrap mt10">
				<div class="left">
					<h4>급여사항</h4>
					<div class="right text-warning ml5">
						(※ 계약기간이 조회년에 포함되고, 연봉관리에 계약서가 업로드되고, 계약종료일이 마지막날짜인 것 조회)
					</div>
				</div>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="70px">
					<col width="">
					<col width="70px">
					<col width="">
					<col width="70px">
					<col width="">
					<col width="70px">
					<col width="">
					<col width="70px">
					<col width="200px">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right">계약기간</th>
					<td>
						${yearSalary.contract_dt}
					</td>
					<th class="text-right">총임금시간</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="total_salary_hour" name="total_salary_hour" readonly="readonly" format="decimal" value="${yearSalary.total_salary_hour}">
							</div>
							<div class="col width16px">
								h
							</div>
						</div>
					</td>
					<th class="text-right">월급여</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="mon_salary_amt" name="mon_salary_amt" readonly="readonly" format="decimal" value="${yearSalary.mon_salary_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
					<th class="text-right">확정연봉</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="total_salary_amt" name="total_salary_amt" readonly="readonly" format="decimal" value="${yearSalary.total_salary_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
					<th class="text-right">근로계약서</th>
					<c:if test="${not empty yearSalary.file_seq}">
						<td class="text-center underline" onclick="javascript:fileDownload(${yearSalary.file_seq})">${yearSalary.origin_file_name}</td>
					</c:if>

					<c:if test="${empty yearSalary.file_seq}">
						<td></td>
					</c:if>
				</tr>
				</tbody>
			</table>
			<!-- /급여사항 -->				
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
<!-- 						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button> -->
					</div>				
				</div>
			</div>
<!-- /폼테이블1 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>