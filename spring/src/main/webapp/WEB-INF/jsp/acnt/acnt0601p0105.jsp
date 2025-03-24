<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 복리후생
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridDocMoney;
		var auiGridDocCareerAndWork;
		$(document).ready(function () {
			createAUIGridDocMoney();
			createAUIGridDocCareerAndWork();

			goSearch();
		});

		// 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			var param = {
				"s_start_year": $M.getValue("s_start_year"),
				"s_end_year": $M.getValue("s_end_year"),
				"s_mem_no": $M.getValue("mem_no")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGridDocMoney, result.docMoneyList);
							AUIGrid.setGridData(auiGridDocCareerAndWork, result.docCareerAndWorkList);
						}
					}
			);
		}

		//팝업 닫기
		function fnClose() {
			top.window.close();
		}

		// 복리후생 신청내역 그리드 생성
		function createAUIGridDocMoney() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "작성일자",
					dataField: "doc_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "경조항목",
					dataField: "doc_money_name",
					width: "300",
					minWidth: "290",
					style: "aui-left aui-popup"
				},
				{
					headerText: "경조일자",
					dataField: "money_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "비고",
					dataField: "remark",
					width: "400",
					minWidth: "390",
					style: "aui-left"
				},
				{
					headerText: "결재",
					dataField: "path_appr_job_status_name",
					width: "300",
					minWidth: "290",
					style: "aui-left"
				},
				{
					headerText: "지급일자",
					dataField: "proc_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "지급자",
					dataField: "proc_mem_name",
					width: "120",
					minWidth: "110",
					style: "aui-center"
				},
				{
					headerText: "문서번호",
					dataField: "doc_no",
					visible: false
				}
			];

			auiGridDocMoney = AUIGrid.create("#auiGridDocMoney", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridDocMoney, []);
			$("#auiGridDocMoney").resize();

			AUIGrid.bind(auiGridDocMoney, "cellClick", function (event) {
				if (event.dataField == "doc_money_name") {
					var params = {
						"doc_no": event.item.doc_no
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
					$M.goNextPage('/mmyy/mmyy011105p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
		}

		// 증명서 신청내역 그리드 생성
		function createAUIGridDocCareerAndWork() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "작성일자",
					dataField: "doc_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "신청구분",
					dataField: "doc_type_name",
					width: "300",
					minWidth: "290",
					style: "aui-left"
				},
				{
					headerText: "체출용도",
					dataField: "submit_text",
					width: "400",
					minWidth: "390",
					style: "aui-left aui-popup"
				},
				{
					headerText: "신청매수",
					dataField: "apply_cnt",
					width: "120",
					minWidth: "110",
					style: "aui-center"
				},
				{
					headerText: "상태",
					dataField: "code_name",
					width: "120",
					minWidth: "110",
					style: "aui-center"
				},
				{
					headerText: "문서번호",
					dataField: "doc_no",
					visible: false
				},
				{
					headerText: "신청구분",
					dataField: "doc_type_cd",
					visible: false
				}
			];

			auiGridDocCareerAndWork = AUIGrid.create("#auiGridDocCareerAndWork", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridDocCareerAndWork, []);
			$("#auiGridDocCareerAndWork").resize();

			AUIGrid.bind(auiGridDocCareerAndWork, "cellClick", function (event) {
				if (event.dataField == "submit_text") {
					var params = {
						"doc_no": event.item.doc_no
					};

					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
					if(event.item.doc_type_cd == "WORK") {
						$M.goNextPage('/mmyy/mmyy011106p01', $M.toGetParam(params), {popupStatus: popupOption});
					}

					if(event.item.doc_type_cd == "CAREER") {
						$M.goNextPage('/mmyy/mmyy011107p01', $M.toGetParam(params), {popupStatus: popupOption});
					}
				}
			});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${inputParam.s_mem_no}"/>
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
								<col width="14px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control" id="s_start_year" name="s_start_year" required="required" alt="조회 시작년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<td class="text-center">~</td>
								<td>
									<select class="form-control" id="s_end_year" name="s_end_year" required="required" alt="조회 종료년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
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

			</div>
			<!-- /탭내용 -->
			<!-- 복리후생 신청내역 -->
			<div class="title-wrap mt10">
				<h4>복리후생 신청내역</h4>
			</div>
			<div id="auiGridDocMoney" style="margin-top: 5px; height: 200px;"></div>
			<!-- /복리후생 신청내역 -->
			<!-- 증명서 신청내역 -->
			<div class="title-wrap mt10">
				<h4>증명서 신청내역</h4>
			</div>
			<div id="auiGridDocCareerAndWork" style="margin-top: 5px; height: 200px;"></div>
			<!-- /증명서 신청내역 -->
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