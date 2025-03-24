<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 급여/손익
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		.table-border th,
		.table-border td {border: 1px solid #ccc; padding: 6px; height: 10px; word-break: break-all;}
	</style>
	
	<script type="text/javascript">

		var auiGridSalary; // 인건비 종합
		var auiGrid02;
		
		$(document).ready(function () {
			
			// 급여 계산방법 그리드
			createAUIGrid03();
			// 근태내역 그리드
			createAUIGrid04();
			
			// 인건비 종합 그리드
// 			createAUIGridSalary();  // 월별내역보기 팝업으로 이동.
			if ("${serviceOrgYn}" == 'Y') {
				createAUIGrid02();
			}
		});

		// 월급여업로드
		function goExcelUpload() {
			
			var popupOption = "";
			var param = {
				"s_year" : $M.getValue("s_year"),
				"s_mon" : $M.getValue("s_mon"),
			};

			$M.goNextPage('/acnt/acnt0601p0109', $M.toGetParam(param), {popupStatus : popupOption});
		}

		function goExcelUploadSec() {

			var popupOption = "";
			var param = {
				"out_year" : $M.getValue("s_year"),
				"org_code" : $M.getValue("org_code")
			};

			$M.goNextPage('/acnt/acnt0601p0110', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 더존 급여 코드 관리
		function goDzCodeMngPopup() {
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=750, left=0, top=0";
			var param = {
			};

			$M.goNextPage('/acnt/acnt0601p0115', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 조회
		function goSearch() {
			var yearMon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
			var params = {
				"s_salary_mon": yearMon,
				"s_center_yn" : $M.getValue("s_center_yn"),
				"s_search_yn" : "Y"
			};

			$M.goNextPage(this_page + "/" + $M.getValue("mem_no"), $M.toGetParam(params), {method: "GET"});
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 인건비 종합 그리드
		/* 
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
					width : "200",
					minWidth : "190",
					style : "aui-center"
				},
				{
					headerText : "급여",
					dataField : "salary_amt",
					width : "200",
					minWidth : "190",
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
					width : "200",
					minWidth : "190",
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
					width : "200",
					minWidth : "190",
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
					width : "200",
					minWidth : "190",
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
					width : "200",
					minWidth : "190",
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
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				}
			];

			auiGridSalary = AUIGrid.create("#auiGridSalary", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridSalary, ${salaryList});
			$("#auiGridSalary").resize();
		}
		 */

		function createAUIGrid02() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false
			};

			var columnLayout = [
				{
					headerText : "기간",
					dataField : "salary_mon",
					editable : false,
					width : "200",
					minWidth : "190",
					style : "aui-center"
				},
				{
					headerText : "총수입",
					dataField : "final_sales",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "인건비",
					dataField : "total_salary_amt",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "센터지출경비",
					dataField : "comm_amt",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "서비스공통경비",
					dataField : "center_out_amt",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "지출계",
					dataField : "out_amt",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "순 수익",
					dataField : "tot_profit",
					width : "200",
					minWidth : "190",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				}
			];

			auiGrid02 = AUIGrid.create("#auiGrid02", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid02, ${list});
			$("#auiGrid02").resize();
		}
		 
		function createAUIGrid03() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false
			};

			var columnLayout = [
				{
					headerText : "지급/공제",
					dataField : "pd_name",
					editable : false,
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "수당명칭",
					dataField : "deduct_name",
					editable : false,
					width : "200",
					minWidth : "190",
					style : "aui-center"
				},
				{
					headerText : "계산방법",
					dataField : "cal_text",
					editable : false,
					width : "300",
					minWidth : "190",
					style : "aui-center",
				},
			];

			auiGrid03 = AUIGrid.create("#auiGrid03", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid03, ${calList});
			$("#auiGrid03").resize();
		}
		 
		function createAUIGrid04() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false
			};

			var columnLayout = [
				{
					headerText : "무급휴가 사용일수",
					dataField : "free_holi_cnt",
					editable : false,
					width : "200",
					minWidth : "190",
					style : "aui-center"
				},
				{
					headerText : "휴일연장 근로시간",
					dataField : "adjust_time",
					width : "300",
					minWidth : "190",
					style : "aui-center",
				},
			];
			
			var workInfo = ${workInfo};
			if ("0" != workInfo[0].free_holi_cnt || "0" != workInfo[0].adjust_time) {
				auiGrid04 = AUIGrid.create("#auiGrid04", columnLayout, gridPros);
				AUIGrid.setGridData(auiGrid04, ${workInfo});
				$("#auiGrid04").resize();
			} else {
				$("#workInfoDiv").addClass("dpn");
			}
		}
		
		// 월별내역보기
		function goDetail() {
			var popupOption = "";
			var param = {
					"s_year" : $M.getValue("s_year"),
					"s_mon" : $M.getValue("s_mon"),
					"mem_no" : $M.getValue("mem_no")
			};

			$M.goNextPage('/acnt/acnt0601p0111', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 급여명세서 출력
		function fnPrint() {

			var list = [];

			var tBody = $("#reportBody");
			var trs = tBody.children("tr");

			var rowIdx = 1;
			$.each(trs, function(index, value){
				var hTr = $(this);
				var items = hTr.children();

				if (items.length != 0) {
					var row = {};
					var cellColor = "";
					// row['cell_color'] = rowIdx%2 == 0 ? "white" : "grey";
					// 기본은 회색or흰색
					cellColor = rowIdx%2 == 0 ? "white" : "grey";
					rowIdx++;

					var leftHeader = hTr.hasClass("pSale") ? "지급내역" : "공제내역";

					row['col_1'] = leftHeader;

					var dataIdx = 2;
					$.each(items, function(idx2, value2) {
						var hItem = $(this);
						// 해더는 위에서 넣었으므로 넘어감. (data_1)
						if (hItem.hasClass("left-header") == false) {
							if(hItem.hasClass("th-skyblue")) {
								cellColor = "skyblue";
							} else if (hItem.hasClass("td-orange")) {
								cellColor = "orange";
							}

							row['col_'+dataIdx] = hItem.text().trim();
							row['col_'+dataIdx+'_color'] = cellColor;
							dataIdx++;
						}
					});
					list.push(row);
				}
			});

			var data = {};

			// 내역원본 st
			/*
			var pHeaderList = ${pSalaryHeaderListJson};
	        var pVauleList = ${pSalaryValListJson};
	        
	        var dHeaderList = ${dSalaryHeaderListJson};
	        var dValueList = ${dSalaryValListJson};
	        
	        var headerList = pHeaderList.concat(dHeaderList);
	        var valueList = pVauleList.concat(dValueList);
	        
	        for (var i in headerList) {
	        	var header = headerList[i].code_name;
	        	var val = valueList[i];
	        	var headerColName = "h_"+($M.toNum(i)+1);
	        	var valColName = "v_"+($M.toNum(i)+1);
	        	data[headerColName] = header; 
	        	data[valColName] = val; 
	        }
			
			// 지급합계액
			data["ph_1"] = $("#ph_1").text();
			data["pv_1"] = "${p_total_salary}";
			
			// 공제합계액
			data["dh_1"] = $("#dh_1").text();
			data["dv_1"] = "${d_deduc_amt}";
			
			// 차인지급액
			data["dh_2"] = $("#dh_2").text();
			data["dv_2"] = "${d_total_salary}";
*/
			// 내역원본 ed
			
			data["title"] = $M.getValue("s_year") + "년 " + $M.getValue("s_mon") + "월 급여, 상여 명세서";
			data["emp_id"] = "${memInfo.emp_id}";
			data["kor_name"] = "${memInfo.kor_name}";
			var memNo = "${memInfo.mem_no}";
			data["org_name"] = _memInfoMap[memNo].org_name;
			data["grade_name"] = _memInfoMap[memNo].grade_name;
			
			// 지급일자
			data["salary_dt"] = "${salary_dt}";
			
			// 근태내역
			var gridData = AUIGrid.getGridData(auiGrid04);
			if (gridData.length > 0) {
				data["free_holi_cnt"] = gridData[0].free_holi_cnt;
				data["adjust_time"] = gridData[0].adjust_time;
			}
			
			// 대표명
			data["breg_rep_name"] = "${breg.breg_rep_name}";
			
			// 지급 계산방법
			var calcGridData = AUIGrid.getGridData(auiGrid03);
			
			var param = {
				"data" : data
				, "calcList" : calcGridData
				, "list" : list
			}
			// openReportPanel('acnt/acnt0601p01_04.crf', param);
			openReportPanel('acnt/acnt0601p01_04_v32.crf', param);
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${memInfo.mem_no}"/>
	<input type="hidden" id="org_code" name="org_code" value="${memInfo.org_code}"/>
	<input type="hidden" id="work_gubun_cd" name="work_gubun_cd" value="${memInfo.work_gubun_cd}"/>

	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<div>
			<!-- 탭내용 -->
			<div class="tabs-inner-line">
				<div class="boxing bd0 pd0 vertical-line mt5">
					<div class="tabs-search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<select class="form-control" id="s_mon" name="s_mon">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
				</div>
			</div>
			<!-- /탭내용 -->
			<!-- 인건비 종합 -->
			<div class="title-wrap mt10" style="display: flex; justify-content: space-between; align-items: center;">
				<h4>인건비 종합</h4>
				<div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<!-- 급여사항 -->
			<table class="table-border mt5">
				<colgroup>
					<col width="125px">
					<col width="">
					<col width="125px">
					<col width="">
					<col width="125px">
					<col width="">
					<col width="125px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right">전년도 지급총액</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="pre_sum_pay_amt" name="pre_sum_pay_amt" readonly="readonly" format="decimal" value="${preSumAmtInfo.pre_sum_pay_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
					<th class="text-right">전년도 급여 총액</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="pre_sum_salary_amt" name="pre_sum_salary_amt" readonly="readonly" format="decimal" value="${preSumAmtInfo.pre_sum_salary_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
					<th class="text-right">전년도 상여 총액</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="pre_sum_incentive_amt" name="pre_sum_incentive_amt" readonly="readonly" format="decimal" value="${preSumAmtInfo.pre_sum_incentive_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
					<th class="text-right">전년도 기타지급액</th>
					<td>
						<div class="row form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="pre_sum_etc_amt" name="pre_sum_etc_amt" readonly="readonly" format="decimal" value="${preSumAmtInfo.pre_sum_etc_amt}">
							</div>
							<div class="col width16px">
								원
							</div>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
			<div class="title-wrap mt10" style="display: flex; justify-content: space-between; align-items: center; width: 800px;">
				<h4>급여,상세명세서</h4>
				<span>지급일자 : ${salary_dt}</span>
				<div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>			
<!-- 폼테이블 -->                   
                    <table class="table-border" style="width: 800px; margin-top:10px;">
                        <colgroup>
                            <col width="90px">
                            <col width="">
                            <col width="">
                            <col width="">
                            <col width="">
                            <col width="">
                            <col width="">
                        </colgroup>
                        <tbody id="reportBody">
							<c:forEach var="items" items="${pSalaryHeaderViewMap}" varStatus="status">
							<%-- 타이틀 컬럼 --%>
							<tr class="pSale">
								<c:if test="${status.first}">
									<th class="left-header" rowspan="${pRowCount}">지급내역</th>
								</c:if>
								<c:forEach var="item" items="${items.value}">
									<th class="th-gray">${item.code_name}</th>
								</c:forEach>
							</tr>

							<%-- 금액 컬럼 --%>
							<tr class="pSale">
								<c:forEach var="item" items="${pSalaryValList}" begin="${status.index * 6}" end="${status.index * 6 + 5}">
									<td class="text-right">${item}</td>
								</c:forEach>
							</tr>
							</c:forEach>

                            <tr class="pSale">
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-skyblue">
                                    <strong id="ph_1">지급합계액</strong>
                                </th>
                            </tr>
                            <tr class="pSale">
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right td-orange text-secondary">
                                    <strong>${p_total_salary}</strong>
                                </td>
                            </tr>

							<c:forEach var="items" items="${dSalaryHeaderViewMap}" varStatus="status">
								<%-- 타이틀 컬럼 --%>
								<tr class="dSale">
									<c:if test="${status.first}">
										<th class="left-header" rowspan="${dRowCount}">공제내역</th>
									</c:if>
									<c:forEach var="item" items="${items.value}">
										<th class="th-gray">${item.code_name}</th>
									</c:forEach>
								</tr>

								<%-- 금액 컬럼 --%>
								<tr class="dSale">
									<c:forEach var="item" items="${dSalaryValList}" begin="${status.index * 6}" end="${status.index * 6 + 5}">
										<td class="text-right">${item}</td>
									</c:forEach>
								</tr>
							</c:forEach>

                            <tr class="dSale">
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-gray"></th>
                                <th class="th-skyblue">
                                    <strong id="dh_1">공제합계액</strong>
                                </th>
                                <th class="th-skyblue">
                                    <strong id="dh_2">차인지급액</strong>
                                </th>
                            </tr>
                            <tr class="dSale">
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right"></td>
                                <td class="text-right td-orange text-secondary">
                                    <strong>${d_deduc_amt}</strong>
                                </td>
                                <td class="text-right td-orange text-secondary">
                                    <strong>${d_total_salary}</strong>
                                </td>
                            </tr>

                        </tbody>
                    </table>
<!-- /폼테이블 -->			
<!-- 			<div id="auiGridSalDetail" style="margin-top: 5px; height: 150px;"></div> -->
			<!-- /급여,상세명세서 -->			
			<!-- /급여사항 -->
<!-- 			<div id="auiGridSalary" style="margin-top: 5px; height: 150px;"></div> -->
			<!-- /인건비 종합 -->
			<!-- 근태 내역 -->
			<div id="workInfoDiv" class="title-wrap mt20">
				<h4>근태 내역</h4>
				<div id="auiGrid04" style="margin-top: 5px; height: 100px;"></div>
			</div>
			<!-- /근태 내역 -->
			<!-- 급여 계산방법 -->
			<div class="title-wrap mt20">
				<h4>급여 계산방법</h4>
				<div id="auiGrid03" style="margin-top: 5px; height: 250px;"></div>
			</div>
			<!-- /급여 계산방법 -->
			<c:if test="${serviceOrgYn eq 'Y'}">
			<!-- 손익사항 -->
			<div class="title-wrap mt20">
				<div class="left">
					<h4>손익사항</h4>
					<div class="form-check form-check-inline ml15">
						<input class="form-check-input" type="radio" id="s_center_yn_n" name="s_center_yn" value="N" <c:if test="${inputParam.s_center_yn eq 'N'}" >checked="checked"</c:if> onchange="javascript:goSearch();">
						<label class="form-check-label" for="s_center_yn_n">개인</label>
					</div>
					<div class="form-check form-check-inline">
						<input class="form-check-input" type="radio" id="s_center_yn_y" name="s_center_yn" value="Y" <c:if test="${inputParam.s_center_yn eq 'Y'}" >checked="checked"</c:if> onchange="javascript:goSearch();">
						<label class="form-check-label" for="s_center_yn_y">센터</label>
					</div>
				</div>
			</div>
			<div id="auiGrid02" style="margin-top: 5px; height: 200px;"></div>
			<!-- /손익사항 -->
			</c:if>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
	<!-- 급여명세서 추가개발간 도장은 출력물에만 필요. 유정은팀장님 요청. 21.12.22 김상덕 -->
<!-- 	<br><br><br><br><br> -->
<!-- 	<div style="text-align: center;"> -->
<!-- 		<img alt="" src="/static/img/yk도장.PNG" style=""> -->
<!-- 	</div> -->
</form>
</body>
</html>