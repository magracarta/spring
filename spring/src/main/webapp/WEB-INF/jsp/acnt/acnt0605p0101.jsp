<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 월 평가서
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var canModify; // 수정 가능 권한

		$(document).ready(function () {
			createAUIGrid();
			goSearch();

			// 각 평점 최대평점 25점으로 제한
			for (let i = 1; i <= 4; i++) {
				var evalPointColName = "q" + String(i) + "_eval_point";
				document.getElementById(evalPointColName).addEventListener('blur', (event) => {
					let value = parseInt(event.target.value);
					if (!isNaN(value) && value > 25) {
						alert("최종 평점은 25점을 넘을 수 없습니다.");
						event.target.value = 25;
					}
				});
			}
		});

		// 조회
		function goSearch() {

			var memNo = $M.getValue("mem_no");
			var param = {
				"s_eval_year": $M.getValue("s_eval_year"),
				"s_mem_no": memNo,
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.monEvalList);
							$("#total_cnt").html(result.total_cnt);
							canModify = result.canModify;
							fnSetQtrEvalData(result.quarterEvalList);
						}
					}
			);
		}

		/**
		 * 분기 별 평가결과 데이터 세팅
		 * @param data
		 */
		function fnSetQtrEvalData(data) {
			$M.setHiddenValue("qtr_eval_year", data.eval_year);
			for (let i = 1; i <= 4; i++) {
				var prefix = "q" + String(i);
				var evalPointColName = prefix + "_eval_point";
				var remarkColName = prefix + "_remark";
				var evalPointCol = $("#" + evalPointColName);
				var remarkCol = $("#" + remarkColName);
				// set value
				evalPointCol.val(data[evalPointColName]);
				remarkCol.val(data[remarkColName]);
				// set readonly according to auth
				evalPointCol.prop("readonly", !canModify);
				remarkCol.prop("readonly", !canModify);
			}
		}

		// 분기 별 평가 저장
		function goSave() {
			if (!canModify) {
				alert("권한이 없습니다.");
				return false;
			}

			var form = $M.createForm();
			$M.setHiddenValue(form, 'eval_year', $M.getValue("qtr_eval_year"));
			$M.setHiddenValue(form, 'mem_no', $M.getValue("mem_no"));
			$M.setHiddenValue(form, 'org_code', $M.getValue("s_org_code"));

			for (let i = 1; i <= 4; i++) {
				var prefix = "q" + String(i);
				var evalPointColName = prefix + "_eval_point";
				var remarkColName = prefix + "_remark";
				// set value
				$M.setHiddenValue(form, evalPointColName, $M.getValue(evalPointColName));
				$M.setHiddenValue(form, remarkColName, $M.getValue(remarkColName));
			}

			$M.goNextPageAjaxSave("/acnt/acnt0605p10/save", form, {method: "POST"},
					function (result) {
						if (result.success) {
							goSearch();
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 소속원 평가 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "년",
					dataField: "eval_year",
					width: "60",
					style: "aui-center",
				},
				{
					headerText: "월",
					dataField: "eval_month",
					width: "60",
					style: "aui-center",
				},
				{
					headerText: "평가자",
					dataField: "eval_mem_name",
					width: "100",
					style: "aui-center",
				},
				{
					headerText: "직위",
					dataField: "grade_name",
					width: "100",
					style: "aui-center",
				},
				{
					headerText: "직급",
					dataField: "job_name",
					width: "100",
					style: "aui-center",
				},
				{
					headerText: "평가내용",
					dataField: "eval_text",
					style: "aui-left",
				},
				{
					headerText: "평가일자",
					dataField: "eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "110",
					style: "aui-center",
				},
				{
					headerText: "평점",
					dataField: "eval_point",
					width: "80",
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${memInfo.mem_no}"/>
	<input type="hidden" id="s_org_code" name="s_org_code" value="${memInfo.org_code}"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 조회조건 -->
		<div class="tabs-inner-line">
			<div class="boxing bd0 pd0 vertical-line mt5">
				<div class="tabs-search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>조회년도</th>
							<td>
								<select class="form-control" id="s_eval_year" name="s_eval_year" required="required"
										alt="조회년도">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_eval_year}">selected</c:if>>${year_option}년</option>
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
		<!-- /조회조건 -->

		<!-- 소속원평가 -->
		<div>
			<div class="title-wrap mt10" style="display: flex; justify-content: space-between; align-items: center;">
				<div class="left">
					<h4>소속원 평가</h4>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
			</div>
		</div>
		<!-- /소속원평가 -->

		<!-- 분기 별 평가결과 -->
		<div>
			<div class="title-wrap mt10">
				<h4>분기 별 평가결과</h4>
			</div>
			<table class="table-border mt5 widthfix">
				<colgroup>
					<col width="100px">
					<col width="100px">
					<col width="*">
				</colgroup>
				<tbody>
				<tr>
					<th class="title-bg text-center">분기</th>
					<th class="title-bg text-center">최종 평점</th>
					<th class="title-bg text-center">비고</th>
				</tr>
				<tr>
					<th class="title-bg text-center">1/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q1_eval_point" name="q1_eval_point"
							   title="1/4분기 평점" format="num"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q1_remark" name="q1_remark"
							   title="1/4분기 비고"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">2/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q2_eval_point" name="q2_eval_point"
							   title="2/4분기 평점" format="num"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q2_remark" name="q2_remark"
							   title="2/4분기 비고"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">3/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q3_eval_point" name="q3_eval_point"
							   title="3/4분기 평점" format="num"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q3_remark" name="q3_remark"
							   title="3/4분기 비고"
						/>
					</td>
				</tr>
				<tr>
					<th class="title-bg text-center">4/4분기</th>
					<td>
						<input type="text" class="form-control text-center"
							   id="q4_eval_point" name="q4_eval_point"
							   title="4/4분기 평점" format="num"
						/>
					</td>
					<td>
						<input type="text" class="form-control text-left"
							   id="q4_remark" name="q4_remark"
							   title="4/4분기 비고"
						/>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /분기 별 평가결과 -->

		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>