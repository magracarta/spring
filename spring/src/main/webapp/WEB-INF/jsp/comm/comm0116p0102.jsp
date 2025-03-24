<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 정보수정 > 인사고과정보 > 부서평가
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-12 17:42:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		// 조회
		function goSearch() {
			var param = {
				"s_year": $M.getValue("s_year"),
				"s_eval_qtr": $M.getValue("s_eval_qtr"),
				"s_mem_no": $M.getValue("s_mem_no")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showStateColumn : true,
				fillColumnSizeMode : true,
				editable : true,
			};

			var columnLayout = [
				{
					dataField : "eval_year",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText: "분기",
					dataField: "eval_qtr",
					width: "6%",
					minWidth: "90",
					style: "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value + "/4";
					}
				},
				{
					headerText : "평가대상부서",
					dataField : "org_name",
					width : "12%",
					minWidth : "70",
					style : "aui-center",
					editable: false
				},
				{
					headerText : "평가자",
					dataField : "mem_name",
					width : "8%",
					minWidth : "70",
					style : "aui-center",
					editable: false
				},
				{
					headerText : "직급",
					dataField : "grade_name",
					width : "8%",
					minWidth : "70",
					style : "aui-center",
					editable: false
				},
				{
					headerText : "평가내용",
					dataField : "remark",
					width : "34%",
					minWidth : "70",
					style : "aui-left",
					editable: true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 100,
						validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${inputParam.s_current_year}" == item["eval_year"] && item["edit_yn"] == "Y" && "${SecureUser.mem_no}" == item["mem_no"]) {
							return "aui-editable"
						}
						return null;
					}
				},
				{
					headerText: "평가일자",
					dataField: "eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "10%",
					minWidth: "90",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "평점",
					dataField: "eval_origin_point",
					style: "aui-center",
					width: "8%",
					minWidth: "50",
					editable: true,
					editRenderer : {
						type : "InputEditRenderer",
						max : 100,
						onlyNumeric : true,
						validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${inputParam.s_current_year}" == item["eval_year"] && item["edit_yn"] == "Y" && "${SecureUser.mem_no}" == item["mem_no"]) {
							return "aui-editable"
						}
						return null;
					}
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				// 당해년도만 수정 가능, 작성자만 가능
				if (event.dataField == "remark" || event.dataField == "eval_origin_point") {
					if ("${inputParam.s_current_year}" != event.item["eval_year"] || event.item["edit_yn"] != "Y" || "${SecureUser.mem_no}" != event.item["mem_no"]) {
						return false;
					}
				}
			});
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + '/save', frm , {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${s_mem_no}"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<div>
			<div class="tabs-inner-line">
				<div class="boxing bd0 pd0 vertical-line mt5">
					<div class="tabs-search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="80px">
								<col width="50px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<th>분기</th>
								<td>
									<select class="form-control" id="s_eval_qtr" name="s_eval_qtr">
										<option value="">- 전체 -</option>
										<c:forEach var="i" begin="1" end="4" step="1">
											<option value="${i}">${i}/4</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="title-wrap mt10">
				<div class="btn-group">
					<h4>조회결과</h4>
					<div>
						<span class="text-warning mr5">※ 평가자는 분기 별 100점을 기준으로 작성하세요!</span>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
			<!-- 하단 영역 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /하단 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>