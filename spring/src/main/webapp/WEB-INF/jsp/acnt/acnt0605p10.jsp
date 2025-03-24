<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 분기별 평가결과 일괄작성 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-06-07 11:30:15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		// 저장 권한 보유 여부
		var hasSaveAuth = ${hasSaveAuth};

		$(document).ready(function () {
			createAUIGrid();
			goSearch();

			// 권한이 없는 경우 저장버튼 숨김
			if (!hasSaveAuth) {
				$("#_goSave").addClass("dpn");
			}
		});

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// enter key binding
		function enter(fieldObj) {
			var field = ["s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 조회
		function goSearch() {
			var param = {
				"s_year" : $M.getValue("s_year"), // 조회년도
				"s_org_code" : $M.getValue("s_org_code"), // 부서
				"s_mem_name": $M.getValue("s_mem_name"), // 직원명
			};

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method: "GET"},
                function (result) {
                    if (result.success) {
						// 그리드 초기화
						AUIGrid.destroy("#auiGrid");
						auiGrid = null;
						createAUIGrid();
                        AUIGrid.setGridData(auiGrid, result.list);
                        $("#total_cnt").html(result.total_cnt);
                    }
                }
            );
		}

		// 저장
		function goSave() {
			if (!hasSaveAuth) {
				alert("권한이 없습니다.");
				return false;
			}

			if (fnChangeGridDataCnt(auiGrid) < 1) {
				alert("변경내역이 없습니다.");
				return false;
			}

			// 수정된 행만
			var gridData = AUIGrid.getEditedRowItems(auiGrid);

			var evalYearArr = [];
			var memNoArr = [];
			var q1EvalPointArr = [];
			var q1RemarkArr = [];
			var q2EvalPointArr = [];
			var q2RemarkArr = [];
			var q3EvalPointArr = [];
			var q3RemarkArr = [];
			var q4EvalPointArr = [];
			var q4RemarkArr = [];

			gridData.forEach(row => {
				evalYearArr.push(row.eval_year);
				memNoArr.push(row.mem_no);
				q1EvalPointArr.push(row.q1_eval_point);
				q1RemarkArr.push(row.q1_remark);
				q2EvalPointArr.push(row.q2_eval_point);
				q2RemarkArr.push(row.q2_remark);
				q3EvalPointArr.push(row.q3_eval_point);
				q3RemarkArr.push(row.q3_remark);
				q4EvalPointArr.push(row.q4_eval_point);
				q4RemarkArr.push(row.q4_remark);
			});

			var option = {
				isEmpty : true
			};

			var paramForm = $M.createForm();
			$M.setValue(paramForm, "eval_year_str", $M.getArrStr(evalYearArr, option));
			$M.setValue(paramForm, "mem_no_str", $M.getArrStr(memNoArr, option));
			$M.setValue(paramForm, "q1_eval_point_str", $M.getArrStr(q1EvalPointArr, option));
			$M.setValue(paramForm, "q1_remark_str", $M.getArrStr(q1RemarkArr, option));
			$M.setValue(paramForm, "q2_eval_point_str", $M.getArrStr(q2EvalPointArr, option));
			$M.setValue(paramForm, "q2_remark_str", $M.getArrStr(q2RemarkArr, option));
			$M.setValue(paramForm, "q3_eval_point_str", $M.getArrStr(q3EvalPointArr, option));
			$M.setValue(paramForm, "q3_remark_str", $M.getArrStr(q3RemarkArr, option));
			$M.setValue(paramForm, "q4_eval_point_str", $M.getArrStr(q4EvalPointArr, option));
			$M.setValue(paramForm, "q4_remark_str", $M.getArrStr(q4RemarkArr, option));

			$M.goNextPageAjaxSave(this_page + "/save", paramForm, {method: "POST"},
					function (result) {
						if (result.success) {
							goSearch();
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
				editable : hasSaveAuth,
			};

			var columnLayout = [
				{
					headerText: "부서",
					dataField: "org_name",
					width: "80",
					style: "aui-center",
					editable : false,
				},
				{
					dataField: "org_code",
					visible: false
				},
				{
					dataField: "mem_no",
					visible: false
				},
				{
					headerText: "직원명",
					dataField: "mem_name",
					width: "80",
					style: "aui-center",
					editable : false,
				},
				{
					headerText: "직책",
					dataField: "job_name",
					width: "80",
					style: "aui-center",
					editable : false,
				},
				{
					dataField: "job_cd",
					visible: false
				},
				{
					dataField: "eval_year",
					visible: false
				}
			];

			var isCurrentYear = $M.getValue("s_year") === "${inputParam.s_current_year}";

			for (let i = 1; i <= 4; i++) {
				var headerTxt = String(i) + "/4분기";
				var pointDataField = "q" + String(i) + "_eval_point";
				var remarkDataField = "q" + String(i) + "_remark";
				var repeatCol =
				{
					headerText: headerTxt,
					children: [
						{
							headerText: "최종평점",
							dataField: pointDataField,
							width: "60",
							style: hasSaveAuth ? "aui-center aui-editable" : "aui-center",
							editable: hasSaveAuth && isCurrentYear,
							editRenderer : {
								type : "InputEditRenderer",
								validator : function(oldValue, newValue, item, dataField, fromClipboard, which) {
									var isValid = true;
									var msg = null;

									if (isNaN(newValue)) {
										isValid = false;
									} else {
										var numVal = Number(newValue);
										if (numVal > 25 || numVal < 0) {
											isValid = false;
											msg = numVal > 25 ? "최대 평점은 25점입니다." : null;
										}
									}
									return {"validate" : isValid, "message" : msg};
								}
							},
						},
						{
							headerText: "비고",
							dataField: remarkDataField,
							style: hasSaveAuth ? "aui-left aui-editable" : "aui-left",
							editable: hasSaveAuth && isCurrentYear
						}
					]
				};
				columnLayout.push(repeatCol);
			}

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				// 최종평점 edit binding
				if (event.dataField.includes("_eval_point")) {
					// 공백 삭제 및 숫자 처리
					if (event.value) {
						AUIGrid.setCellValue(auiGrid, event.rowIndex, event.dataField, Number(event.value.trim()));
					}
				}
			});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var excelProps = {
				// 엑셀 다운로드 시 제외 컬럼 - 숨김 컬럼
				exceptColumnFields: AUIGrid.getHiddenColumnDataFields(auiGrid)
			};
			fnExportExcel(auiGrid, "분기별 평가결과 일괄작성", excelProps);
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="contents">
				<!-- 상단 조회 조건 -->
				<div class="search-wrap mt10">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="80px">
							<col width="40px">
							<col width="100px">
							<col width="60px">
							<col width="100px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>조회년도</th>
							<td>
								<select class="form-control" id="s_year" name="s_year">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
									</c:forEach>
								</select>
							</td>
							<th>부서</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgList}" >
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
											<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
												<c:if test="${list.code_value ne '6000' and list.code_v2 eq 'Y'}">
													<option value="${list.code_value}">${list.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
							<th>직원명</th>
							<td>
								<input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
							</td>
							<td>
								<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<span class="text-warning mr5">
								※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.
							</span>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- 그리드 -->
				<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
				<!-- 하단 영역 -->
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>
