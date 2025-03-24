<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 정보수정 > 인사고과정보 > 소속원평가
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-05-09 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		// 당월 총 평점 (기준)
		var score = 0;
		// 전월 총 평점 (기준)
		var prevScore = 0;
		// 당월 총 평점 (변경)
		var nowThisScore;
		// 전월 총 평점 (변경)
		var nowLastScore;
		// 전월 평가 필요 여부
		var needLastMonEval = false;
		// 당년월
		var thisYearMon;


		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		// 조회
		function goSearch() {

			var param = {
				"s_year": $M.getValue("s_year"),
				"s_mem_no": $M.getValue("s_mem_no")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
							score = result.score;
							prevScore = result.prev_score;
							nowThisScore = score;
							nowLastScore = prevScore;
							needLastMonEval = result.need_eval_last_month === "Y";
							thisYearMon = result.this_year_mon;
							fnCalcTotalScore();
							setTotalScoreText();
						}
					}
			);
		}

		/**
		 * 총점 텍스트 세팅
		 */
		function setTotalScoreText() {
			$("#total_score_text").empty();
			// 당월
			var scoreText = $("<span></span>").text(String(nowThisScore)).css("font-size", "15px");
			var text = $("<span></span>").text("총 평점 : ").append(scoreText).append("점");

			// 전월 평가가 필요한 경우
			if (needLastMonEval) {
				var prevScoreText = $("<span></span>").text(String(nowLastScore)).css("font-size", "15px");
				var prevText = $("<span></span>").text("전월 총 평점 : ").append(prevScoreText).append("점 / 당월 ");
				text = prevText.append(text);
			}
			$("#total_score_text").append(text);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showStateColumn : true,
				editable : true,
			};

			var columnLayout = [
				{
					headerText: "년",
					dataField: "eval_year",
					width: "80",
					minWidth: "90",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "월",
					dataField: "eval_month",
					width: "50",
					minWidth: "40",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "직원명",
					dataField: "mem_name",
					width: "90",
					minWidth: "50",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "직위",
					dataField: "grade_name",
					width: "130",
					minWidth: "100",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "직급",
					dataField: "job_name",
					width: "130",
					minWidth: "100",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "평가내용(본인포함)",
					dataField: "eval_text",
					style: "aui-left",
					styleFunction: (rowIndex, columnIndex, value, headerText, item, dataField) => {
						if (item.aui_status_cd === "C") {
							return "aui-status-complete";
						} else {
							return "aui-editable";
						}
					},
					editable: true,
					required : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 250, // 500자이나 한글은 250자
					}
				},
				{
					headerText: "평가일자",
					dataField: "eval_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "100",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "평점",
					dataField: "eval_point",
					width: "80",
					dataType: "numeric",
					editRenderer : {
						  type : "InputEditRenderer",
						  onlyNumeric : true,
						  allowNegative : false,
						  // 에디팅 유효성 검사
						  validator : AUIGrid.commonValidator
					},
					styleFunction: (rowIndex, columnIndex, value, headerText, item, dataField) => {
						if (item.aui_status_cd === "C") {
							return "aui-status-complete";
						} else {
							return "aui-editable";
						}
					},
					editable: true,
					required : true,
				},
				{	// 평가대상 직원
					dataField: "mem_no",
					visible: false
				},
				{
					dataField: "org_code",
					visible: false
				},
				{
					dataField: "eval_mon",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 편집 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				// 당월, 전월만 편집 가능
				if (event.item.aui_status_cd === "C") {
					return false;
				}
			});

			AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
				// 평점 수정 시 총점 수정
				if (event.dataField === "eval_point") {
					fnCalcTotalScore();
					// 전체 평점이 총 평점 이상이면 alert
					if (nowThisScore < 0 || nowLastScore < 0) {
						alert("입력한 평점이 \"총 평점\"을 넘었습니다");
					}
					setTotalScoreText();
				}
				// 평가내용 작성 시 trim 처리
				if (event.dataField === "eval_text") {
					AUIGrid.updateRow(auiGrid, { "eval_text" : event.value.trim() }, event.rowIndex);
				}
			});
		}

		// 총점 자동 계산
		function fnCalcTotalScore() {
			var gridData = AUIGrid.getGridData(auiGrid)
					.filter(data => data.aui_status_cd !== 'C' && data.eval_point != undefined);

			<%--var thisYear = "${inputParam.s_current_year}";--%>
			<%--var thisMon = "${inputParam.s_current_mon}".substring(4, 6);--%>

			var thisYear = thisYearMon.substring(0, 4);
			var thisMon = thisYearMon.substring(4, 6);

			var totalScore = gridData
					.filter(data => data.eval_year == thisYear && data.eval_month == thisMon)
					.map(data => data.eval_point)
					.reduce((a, b) => a + b, 0);
			nowThisScore = score - totalScore;

			if (needLastMonEval) {
				var lastYearMon = "${s_last_mon}";
				var lastYear = lastYearMon.substring(0, 4);
				var lastMon = lastYearMon.substring(4, 6);
				var lastScore = gridData
					.filter(data => data.eval_year == lastYear && data.eval_month == lastMon)
					.map(data => data.eval_point)
					.reduce((a, b) => a + b, 0);
				nowLastScore = prevScore - lastScore;
			}
		}

		// 저장 (업데이트)
		function goSave() {

			if (AUIGrid.getEditedRowItems(auiGrid).length === 0) {
				alert("변경내역이 없습니다.");
				return false;
			}

			let notFilledText = AUIGrid.getGridData(auiGrid).filter(data => data.aui_status_cd !== 'C' && !data.eval_text);
			if (notFilledText.length > 0) {
				alert("평가내용과 평점 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			fnCalcTotalScore();
			setTotalScoreText();

			// 총 평점 0점 여부
			var isTotalScoreZero = nowThisScore === 0 && nowLastScore === 0;
			if (!isTotalScoreZero) {
				alert("총 총점이 “0”이 되어야 저장이 가능합니다.");
				return false;
			}

			var columns = ["eval_mon", "mem_no", "org_code", "eval_point", "eval_text"];
			var form = fnChangeGridDataToForm(auiGrid, '', columns);

			$M.goNextPageAjaxSave(this_page + "/save", form, {method : 'POST'},
				function(result) {
					if (result.success) {
						goSearch();
					}
				}
			);
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
						<span class="text-warning mr5">※ 소속원(본인포함) 1인당 10점이 부여됩니다.</span>
						<span id="total_score_text" style="font-weight: bold;" ></span>
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