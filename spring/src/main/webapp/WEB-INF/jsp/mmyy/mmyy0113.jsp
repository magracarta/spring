<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 일일현황판
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-26 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style type="text/css">
		/* 커스텀 행 스타일 (비활성화) */
		.my-row-style-disable {
			text-align:left;
			background-color: #E9ECEF;
		}
		/* 커스텀 행 스타일 (중첩, 비활성화) */
		.my-row-style-dup1 {
			color:red;
			text-align:left;
			background-color: #E9ECEF;
		}
		/* 커스텀 행 스타일 (일정 중첩, 활성화) */
		.my-row-style-dup2 {
			color:red;
			text-align:left;
		}
	</style>

	<script type="text/javascript">
		var auiGrid;
		var orgCode = "${s_org_code}";
		var searchDt = "${s_search_dt}";

		$(document).ready(function() {
			fnInit();
			createAUIGrid();
			goSearch();
		});

		// 화면 초기화
		function fnInit() {
			if (${inputParam.s_popup_yn ne 'Y'}) {
				// 메뉴내기능 권한 없으면 부서 조회조건 비활성화
				if(${page.fnc.F04743_001 ne 'Y'}) {
					$("#s_org_code").prop("disabled", true);
				}
			}
		}

		// 정비예약가능 버튼 노출 세팅
		function fnSetResvAvleBtn() {
			// 고객앱 조회일자에 정비예약가능여부에 따라 버튼노출여부 설정
			if ($M.getValue("am_resv_able_yn") == "Y") {
				$("#_goAmResvAble").hide();
				$("#_goAmResvNotAble").show();
			} else if ($M.getValue("am_resv_able_yn") == "N") {
				$("#_goAmResvAble").show();
				$("#_goAmResvNotAble").hide();
			} else {
				$("#_goAmResvAble").hide();
				$("#_goAmResvNotAble").hide();
			}
            if ($M.getValue("pm_resv_able_yn") == "Y") {
				$("#_goPmResvAble").hide();
				$("#_goPmResvNotAble").show();
			} else if ($M.getValue("pm_resv_able_yn") == "N") {
				$("#_goPmResvAble").show();
				$("#_goPmResvNotAble").hide();
            } else {
				$("#_goPmResvAble").hide();
				$("#_goPmResvNotAble").hide();
			}
			fnShowResvState();
		}

		// 조회
		function goSearch(s_org_code, s_search_dt) {
			if (s_org_code != undefined) {
				$M.setValue("s_org_code", s_org_code);
			}
			if (s_search_dt != undefined) {
				$M.setValue("s_search_dt", s_search_dt);
			}

			if($M.getValue("s_search_dt")==""){
				alert("조회일자는 필수입력입니다.");
				return false;
			}

			if($M.getValue("s_org_code")==""){
				alert("센터는 필수선택입니다.");
				return false;
			}

			var param = {
				"s_search_dt" : $M.getValue("s_search_dt"),
				"s_org_code" : $M.getValue("s_org_code")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							destroyGrid();
							fnResult(result);
							orgCode = $M.getValue("s_org_code");
							searchDt = $M.getValue("s_search_dt");
						} else {
							destroyGrid();
							createAUIGrid();
						}
					}
			);
		}

		// 예약불가로 상태 변경
		function goAmResvNotAble() {
			var param = {
				"am_yn": "N",
				"apm_gubun": "A",
			}
			goChangeAbleResv(param, 'N');
		}

		// 예약가능으로 상태 변경
		function goAmResvAble() {
			var param = {
				"am_yn": "Y",
				"apm_gubun": "A",
			}
			goChangeAbleResv(param, 'Y');
		}

		// 예약불가로 상태 변경
		function goPmResvNotAble() {
			var param = {
				"pm_yn": "N",
				"apm_gubun": "P",
			}
			goChangeAbleResv(param, 'N');
		}

		// 예약가능으로 상태 변경
		function goPmResvAble() {
			var param = {
				"am_yn": "Y",
				"apm_gubun": "P",
			}
			goChangeAbleResv(param, 'Y');
		}

		// 예약가능상태 변경
		function goChangeAbleResv(param, ableYn) {
			param.not_dt = searchDt;
			param.org_code = orgCode;

			var msg = "고객앱의 " + $M.dateFormat(searchDt, "yyyy-MM-dd") + " 날짜에 ";
			msg += param.apm_gubun == 'A' ? "오전" : "오후";
			if(ableYn == "N") {
				msg += " 예약 불가";
			} else {
				msg += " 예약가능";
			}
			msg += " 상태로 변경하시겠습니까?"

			$M.goNextPageAjaxMsg(msg, this_page + "/resv", $M.toGetParam(param), {method : 'post'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							if(param.apm_gubun == "A") {
								$M.setValue("am_resv_able_yn", ableYn);
							} else {
								$M.setValue("pm_resv_able_yn", ableYn);
							}
							fnSetResvAvleBtn();
						}
					}
			);
		}

		// 그리드 생성
		function createAUIGrid() {
			// 조회결과
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: false,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				rowSelectionWithMerge : true,
				fixedColumnCount : 1,
				editable : false
			};

			var columnLayout = [
				{
					headerText : "시간",
					dataField : "day_board_time_name",
					width : "130",
					minWidth : "20",
					style : "aui-center"
				},
				{
					dataField : "day_board_time_cd",
					visible : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
			// 조회 후 "펼침" 버튼 초기화
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);
		};

		// 조회결과 세팅
		function fnResult(result) {
			// 버튼 노출 세팅
			$M.setValue("am_resv_able_yn", result.info.am_resv_able_yn);
			$M.setValue("pm_resv_able_yn", result.info.pm_resv_able_yn);
			fnSetResvAvleBtn();

			// 정비신청/렌탈출고/렌탈회수 미지정건
			$("#not_ref_cnt").text(result.info.not_ref_cnt);

			// 조회결과
			var gridPros = {
				rowIdField : "day_board_time_cd",
				showRowNumColumn: false,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				rowSelectionWithMerge : true,
				fixedColumnCount : 1,
				editable : false,
				wordWrap: true
			};

			var columnLayout = [
				{
					headerText : "시간",
					dataField : "day_board_time_name",
					width : "130",
					minWidth : "20",
					style : "aui-center"
				},
				{
					dataField : "day_board_time_cd",
					visible : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			var memList = result.mem_list;
			AUIGrid.setGridData(auiGrid, []);
			if (memList != null && memList.length > 0) {
				for (var i = 0; i < memList.length; ++i) {
					var row = memList[i];
					var memNo = row.mem_no
					var memNoFieldName = "a_" + memNo;
					var headerTextName = row.mem_name;
					var dataFieldName = memNo + "_content";
					var seqStrFieldName = memNo + "_day_board_seq_str";

					var columnObj = [
						{
							headerText: headerTextName,
							dataField: dataFieldName,
							width: "15%",
							editable : false,
							renderer : {
								type : "TemplateRenderer"
							},
							cellMerge : true,
							// 그리드 스타일 함수 정의
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								var ret = "aui-left";
								var tempMemNo = dataField.split("_")[0];
								var disableYn = item[tempMemNo + "_disable_yn"];

								var seqStr = item[tempMemNo + "_day_board_seq_str"];
								if(seqStr != null && seqStr.split("#").length > 1) {
									if (disableYn == "Y") {
										ret = "my-row-style-dup1";
									} else {
										ret = "my-row-style-dup2";
									}
								} else {
									if (disableYn == "Y") {
										ret = "my-row-style-disable";
									}
								}
								return ret;
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
								var tempMemNo = dataField.split("_")[0];
								var daySeqStr = item[tempMemNo + "_day_board_seq_str"];

								var template = "";
								if (daySeqStr != null && daySeqStr != "" && daySeqStr != undefined) {
									template = '<div class="aui-grid-renderer-base" style="overflow: hidden; white-space: nowrap; width: 100%;">';

									var innerTemplate = '';
									var seqArr = daySeqStr.split("#");
									for (var i=0; i<seqArr.length; i++) {
										var content = item[tempMemNo + "_" + seqArr[i] + "_content"];
										if (content != null && content != "" && content != undefined) {
											var planStTi = item[tempMemNo + "_plan_st_ti"];
											var planEdTi = item[tempMemNo + "_plan_ed_ti"];
											innerTemplate = innerTemplate==''? '' : innerTemplate + '<br>';
											var underlineText = ${inputParam.s_popup_yn eq 'Y'}? "" : "text-decoration: underline;";
											innerTemplate += '<span style="cursor: pointer; ' +underlineText+ '" title="'+ content +'" onclick="javascript:goDetailDayBoardPop('+ seqArr[i] +', \'' + planStTi + '\',\'' + planEdTi + '\');">'+ content +'</span>';
										}
									}
									template += innerTemplate ;

									template += '</div>';
								}

								return template;
							},
						},
						{
							dataField: memNoFieldName,
							visible: false
						},
						{
							dataField: seqStrFieldName,
							visible: false
						},
					];

					AUIGrid.addColumn(auiGrid, columnObj, 'last');
				}
			}

			AUIGrid.setGridData(auiGrid, result.list);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField.endsWith("_content")) {
					var tempMemNo = event.dataField.split("_")[0];
					if (event.item[tempMemNo + "_day_board_seq_str"] == "" && ${inputParam.s_popup_yn ne 'Y'}) {
						var param = {
							"board_mem_no": tempMemNo,
							"board_org_code": orgCode,
							"board_dt": searchDt,
							"work_st_ti": event.item["day_board_time_cd"],
							"work_ed_ti": fnGetNextTi(event.item["day_board_time_cd"]),
							"plan_st_ti": event.item[tempMemNo+"_plan_st_ti"],
							"plan_ed_ti": event.item[tempMemNo+"_plan_ed_ti"]
						}

						if (event.item[tempMemNo + "_disable_yn"] == 'N') {
							// 활성화 된 칸이면 작성권한 체크 후 등록팝업
							if (${page.fnc.F04743_002 eq 'Y'}) {
								goNewDayBoardPop(param);
							} else {
								alert("업무스케쥴 작성 권한이 없습니다.");
							}
						}
					}
				}
			});
		}

		// 다음 시간 가져오기
		function fnGetNextTi(val) {
			var tiList = ${ti_list};
			if (tiList != null && tiList.length > 0) {
				var idx = tiList.findIndex(obj => obj.code_value == val);
				var nextIdx = idx == tiList.length-1? idx : idx + 1;
			}
			return tiList[nextIdx].code_value;
		}

		// 출하캘린더 팝업
		function goOutCalPopup() {
			var param = {};
			$M.goNextPage("/sale/sale0101p13", $M.toGetParam(param), {popupStatus : ""});
		}

		// 업무리스트 팝업
		function goWorkListPop () {
			var param = {
				"s_org_code": orgCode,
				"s_search_dt": searchDt
			}
			$M.goNextPage("/mmyy/mmyy0113p03", $M.toGetParam(param), {popupStatus : ""});
		}

		// 일일현황 등록 팝업
		function goNewDayBoardPop(param) {
			$M.goNextPage("/mmyy/mmyy0113p01", $M.toGetParam(param), {popupStatus : ""});
		}

		// 일일현황 상세 팝업
		function goDetailDayBoardPop(dayBoardSeq, planStTi, planEdTi) {
			var param = {
				"day_board_seq": dayBoardSeq,
				"plan_st_ti": planStTi,
				"plan_ed_ti": planEdTi
			}
			$M.goNextPage("/mmyy/mmyy0113p02", $M.toGetParam(param), {popupStatus : ""});
		}

		// 화면 새로고침
		function fnReload(){
			location.reload();
		}

		// 예약 마감 상태
		function fnShowResvState() {
			var amResv = $M.getValue("am_resv_able_yn");
			var pmResv = $M.getValue("pm_resv_able_yn");

			var state = "오전 : " + (amResv == "Y" ? "예약가능" : "예약마감")
			            + ", 오후 : " + (pmResv == "Y" ? "예약가능" : "예약마감");

			$("#resv_state").html(state);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>
<div class="layout-box">
	<input type="hidden" name="am_resv_able_yn" value="${info.am_resv_able_yn}">
	<input type="hidden" name="pm_resv_able_yn" value="${info.pm_resv_able_yn}">
	<c:if test="${inputParam.s_popup_yn eq 'Y'}">
		<input type="hidden" name="s_search_dt" value="${inputParam.s_search_dt}">
		<input type="hidden" name="s_org_code" value="${inputParam.s_org_code}">
	</c:if>
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<div class="contents">
				<!-- 기본 -->
				<c:if test="${inputParam.s_popup_yn ne 'Y'}">
					<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="65px">
								<col width="120px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회일자</th>
								<td>
									<div class="form-row inline-pd" style="padding-left: 10px;">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_search_dt" name="s_search_dt" dateFormat="yyyy-MM-dd"  value="${s_search_dt}" alt="조회일자">
										</div>
									</div>
								</td>
								<th>부서</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
									<c:forEach var="item" items="${center_list}">
										<option value="${item.org_code}" <c:if test="${s_org_code == item.org_code}">selected</c:if>>${item.org_name}</option>
									</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
								</td>
								<td class="text-right">
									정비신청/렌탈출고/렌탈회수 미지정건 : <span id="not_ref_cnt" style="color: red;">0</span>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<span id="resv_state">
								</span>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
				</c:if>

				<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>

		<c:if test="${inputParam.s_popup_yn ne 'Y'}">
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</c:if>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>