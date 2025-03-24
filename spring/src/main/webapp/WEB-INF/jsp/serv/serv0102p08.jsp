<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 전화상담내역
-- 작성자 : 성현우
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

			goSearch();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "row",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "상담일자",
					dataField: "as_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				},
				{
					headerText: "차주명",
					dataField: "cust_name",
					style: "aui-center"
				},
				{
					headerText: "업체명",
					dataField: "breg_name",
					style: "aui-center "
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					style: "aui-center"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					style: "aui-center"
				},
				{
					headerText: "사용시간",
					dataField: "op_hour",
					style: "aui-center"
				},
				{
					headerText: "작성자",
					dataField: "reg_mem_name",
					style: "aui-center"
				},
				{
					headerText: "구분",
					dataField: "as_call_type_name",
					style: "aui-center"
				},
				{
					headerText: "상태",
					dataField: "appr_proc_status_name",
					style: "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();
		}

		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_start_dt", "s_end_dt"]}) == false) {
				return;
			}

			if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}

			var params = {
				"s_machine_seq": $M.getValue("machine_seq"),
				"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_seq" name="machine_seq" value="${inputParam.s_machine_seq}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="65px">
						<col width="252px">
						<col width="65px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>상담일자</th>
						<td>
							<div class="row widthfix">
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="상담일자" value="${inputParam.s_start_dt}">
									</div>
								</div>
								<div class="col width16px">~</div>
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="상담일자" value="${inputParam.s_end_dt}">
									</div>
								</div>
							</div>
						</td>
						<th>자료구분</th>
						<td>
							<select id="s_appr_proc_status_cd" name="s_appr_proc_status_cd" class="form-control">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['APPR_PROC_STATUS']}">
									<c:if test="${item.code_value ne '02' and item.code_value ne '04'}">
										<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : ''}>${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td class="">
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
			</div>
			<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /검색결과 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>