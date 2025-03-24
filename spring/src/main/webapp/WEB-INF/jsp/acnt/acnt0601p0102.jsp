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
		$(document).ready(function () {
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var workGubunCd = $M.getValue("work_gubun_cd");

			var hideList = ["mng_eval_dt", "mng_eval_point"];
			if("04" != workGubunCd) {
				// 서비스 부서만 매니저 관련 컬럼 노출
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}

			goSearch();
		}

		// 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			var param = {
				"s_eval_mon": $M.getValue("s_eval_mon"),
				"s_mem_no": $M.getValue("mem_no")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 월 평가서 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				rowHeight : 40
			};

			var columnLayout = [
				{
					headerText: "월",
					dataField: "eval_mon",
					width: "100",
					minWidth: "90",
					postfix : "월",
					style: "aui-center"
				},
				{
					headerText: "상사 평가일자",
					dataField: "boss_eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				},
				{
					headerText: "상사 근태/업무평가",
					dataField: "boss_eval_text",
					width: "550",
					minWidth: "540",
					style: "aui-left"
				},
				{
					headerText: "상사평점",
					dataField: "boss_eval_point",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				},
				{
					headerText: "매니저 평가일자",
					dataField: "mng_eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				},
				{
					headerText: "매니저평점",
					dataField: "mng_eval_point",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				},
				{
					headerText: "최종평가일자",
					dataField: "last_eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				},
				{
					headerText: "최종평점",
					dataField: "last_eval_point",
					width: "200",
					minWidth: "190",
					style: "aui-center"
				}
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
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control" id="s_eval_mon" name="s_eval_mon" required="required" alt="조회년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
								<td>
									<div class="text-warning ml5">
										(※ 월 평가서는 [고과평가관리 > 월 평가서]에서 작성한 내역이 보여집니다.)
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- /탭내용 -->
			<div class="title-wrap mt10">
				<h4>월 평가서</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
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