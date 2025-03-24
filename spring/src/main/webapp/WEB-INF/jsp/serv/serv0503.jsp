<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스일지 결재관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-07 13:10:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;

		$(document).ready(function () {
// 			fnInitDate();
			// AUIGrid 생성
			createAUIGrid();

			// 입력폼으로 포커스 인
			$("#s_org_name").focusin(function () {
				orgNameFormClear();
			});

			goSearch();
		});

		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function (result) {
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			});
		}

		function fnChangeDate() {
			if ($M.getValue("s_appr_proc_status_cd") == '06') {
				$("#s_date_title").hide();
				$("#s_date_title_width").hide();

				$("#s_date_dtl").hide();
				$("#s_date_dtl_width").hide();
			} else {
				$("#s_date_title").show();
				$("#s_date_title_width").show();

				$("#s_date_dtl").show();
				$("#s_date_dtl_width").show();
			}
		}


		// 검색조건 부서 초기화
		function orgNameFormClear() {
			$M.clearValue({field: ["s_org_name", "s_org_code"]});
		}

		// 시작일자 세팅 현재날짜의 1달 전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 			$M.setValue("s_end_dt", now);
// 		}

		// 조직도 팝업에서 가져온 부서코드 값 SET
		function fnSetOrgCode(result) {
			$M.setValue("s_org_code", result.org_code);
			$M.setValue("s_org_name", result.org_name);
		}

		// 서비스일지 결재관리 목록 조회
		function fnSearch(successFunc) {
			if($M.getValue("s_cost_ync") == "") {
				alert("유상, 무상, 전화 중 최소 한개 항목은 필수입니다.");
				return;
			}

			if ($M.validation(document.main_form) == false) {
				return;
			}

			if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}

			var apprProcStatCd = $M.getValue("s_appr_proc_status_cd");

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_kor_name": $M.getValue("s_kor_name"),
				"s_cost_ync_str" : $M.getValue("s_cost_ync"),
				"s_org_code": $M.getValue("s_org_code"),
				"s_my_appr": $M.getValue("s_my_appr"),
				"s_appr_proc_status_cd": apprProcStatCd,
				"page": page,
				"rows": $M.getValue("s_rows"),
                "s_date_type": $M.getValue("s_date_type")
			};

			if (apprProcStatCd == '06') {
				delete param.s_start_dt;
				delete param.s_end_dt;
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						isLoading = false;
						if (result.success) {
							successFunc(result);
						}
					}
			);
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			}
		}

		function goMoreData() {
			fnSearch(function (result) {
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_kor_name", "s_start_dt", "s_end_dt"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "작성일",
					dataField: "as_dt",
					dataType: "date",
					width: "65",
					minWidth: "65",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "결재완료일",
					dataField: "proc_date",
					dataType: "date",
					width: "65",
					minWidth: "65",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "전표일",
					dataField: "stat_dt",
					dataType: "date",
					width: "65",
					minWidth: "65",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width: "150",
					minWidth: "150",
					style: "aui-center",
				},
				{
					headerText: "장비일련번호",
					dataField: "machine_seq",
					visible: false,
					style: "aui-center"
				},
				{
					headerText: "정비일지 타입",
					dataField: "as_repair_type_ro",
					visible: false,
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width: "110",
					minWidth: "110",
					style: "aui-left"
				},
				{
					headerText: "판매일",
					dataField: "sale_dt",
					dataType: "date",
					width: "65",
					minWidth: "65",
					style: "aui-center",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "차주명",
					dataField: "cust_name",
					width: "130",
					minWidth: "130",
					style: "aui-center"
				},
				{
					headerText: "업체명",
					dataField: "breg_name",
					width: "140",
					minWidth: "140",
					style: "aui-center"
				},
				{
					headerText: "작성자",
					dataField: "reg_mem_name",
					width: "60",
					minWidth: "60",
					style: "aui-center"
				},
				{
					headerText: "결재",
					dataField: "path_appr_job_status_name",
					width: "340",
					minWidth: "340",
					style: "aui-left"
				},
				{
					headerText: "고객만족도",
					dataField: "cust_point",
					width: "65",
					minWidth: "65",
					style: "aui-center"
				},
				{
					headerText: "구분1",
					dataField: "clm_name",
					width: "50",
					minWidth: "50",
					style: "aui-center"
				},
				{
					headerText: "구분2",
					dataField: "type_name",
					width: "80",
					minWidth: "70",
					style: "aui-center aui-popup"
				},
				{
					headerText: "작성의견",
					dataField: "warranty_cnt",
					width: "65",
					minWidth: "65",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-center"
				},
				// 3차 추가
				{
					headerText: "합계",
					dataField: "total_amt",
					width: "150",
					minWidth: "45",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "부품비",
					dataField: "part_total_amt",
					width: "150",
					minWidth: "45",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "출장비",
					dataField: "travel_final_expense",
					width: "150",
					minWidth: "45",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "공임비",
					dataField: "work_total_amt",
					width: "150",
					minWidth: "45",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "W/R",
					dataField: "warranty_yn",
					width: "55",
					minWidth: "55",
					renderer: {
						type: "ButtonRenderer",
						onClick: function (event) {
							var params = {
								"s_as_no": event.item.as_no,
								"s_machine_seq": event.item.machine_seq,
							};

							var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=800, left=0, top=0";
							$M.goNextPage('/serv/serv0102p04', $M.toGetParam(params), {popupStatus: popupOption});
						}
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return 'W/R'
					},
					style: "aui-center aui-editable",
					editable: false,
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "type_name") {

					var params = {
						"s_as_no": event.item.as_no,
						"s_refresh_page_yn": "Y"
					};

					if (event.item.as_repair_type_ro == "R") {
						// 서비스일지 상세
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=800, left=0, top=0";
						$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});

					} else if (event.item.as_repair_type_ro == "O") {
						// 출하서비스일지 상세
						var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
						$M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});
					} else if (event.item.as_repair_type_ro == "") {
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
						$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
					}
				}
			});

			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "서비스일지 결재관리", "");
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="100px" id="s_date_title_width">
								<col width="260px" id="s_date_dtl_width">
								<col width="65px">
								<col width="100px">
								<col width="40px">
								<col width="130px">
								<col width="50px">
								<col width="100px">
								<col width="350px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th id="s_date_title">
									<select id="s_date_type" name="s_date_type" class="form-control">
                                        <option value="AS">작성일자</option>
                                        <option value="STAT">전표일자</option>
                                    </select>
								</th>
								<td id="s_date_dtl">
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
			                     		</jsp:include>	
									</div>
								</td>
								<th>자료구분</th>
								<td>
									<select class="form-control" id=s_appr_proc_status_cd name="s_appr_proc_status_cd" onchange="fnChangeDate();">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['APPR_PROC_STATUS']}">
											<c:if test="${list.code_value ne '02' && list.code_value ne '04' && list.code_value ne '06'}">
												<option value="${list.code_value}">${list.code_name}</option>
											</c:if>
										</c:forEach>
										<option value="06">미결</option>
									</select>
								</td>
								<th>부서</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="s_org_name" name="s_org_name" readonly="readonly">
										<input type="hidden" id="s_org_code" name="s_org_code">
										<button type="button" class="btn btn-icon btn-primary-gra" id="order_org_btn" name="order_org_btn" onclick="openOrgMapPanel('fnSetOrgCode');"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>작성자</th>
								<td>
									<input type="text" class="form-control" id="s_kor_name" name="s_kor_name" value="">
								</td>
								<td>&nbsp;&nbsp;
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_cost_y" name="s_cost_ync" value="Y" checked="checked">
										<label class="form-check-input" for="s_cost_y">유상</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_cost_n" name="s_cost_ync" value="N" checked="checked">
										<label class="form-check-input" for="s_cost_n">무상</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_cost_c"  name="s_cost_ync" value="C" checked="checked">
										<label class="form-check-input" for="s_as_type" >전화</label>
									</div>
									&nbsp;&nbsp;
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_my_appr"  name="s_my_appr" value="Y">
										<label class="form-check-input" for="s_my_appr">결재처리건 조회</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>