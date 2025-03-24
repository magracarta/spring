<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-20 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<style type="text/css">
		/* 커스텀 행 스타일 ( complete, underline ) */
		.my-row-style {
			background-color: #eee;
			color: #999;
			text-decoration: underline;
			cursor: pointer;
			text-underline-position: under;
		}
	</style>

	<script type="text/javascript">

		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var now = "${inputParam.s_current_dt}";

			if ("${inputParam.s_work_gubun}" != "Y") {
				$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
				$M.setValue("s_end_dt", $M.toDate(now));
			}

			// 업무일지
			if ("${inputParam.s_work_gubun}" == "Y") {
			}

			var org = ${orgBeanJson};
			if (org.org_gubun_cd != "BASE") {
				$("#s_center_org_code").prop("disabled", true);
				// _goSurvey, _goCurrSituation
				$("#_goSurvey").addClass("dpn");
				$("#_goCurrSituation").addClass("dpn");
			}
			goSearch();
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_name", "s_cust_name", "s_body_no"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "job_report_no",
				showRowNumColumn: true,
				enableFilter :true,
				showRowCheckColumn : true,
				showRowAllCheckBox : true,
				// independentAllCheckBox : true,
				// rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
				// 	if (item["happycall_mile_cd"] =='02') {
				// 		return false;
				// 	}
				// 	return true;
				// },
				rowStyleFunction : function(rowIndex, item) {
					// 적립제외
					if (item["happycall_mile_cd"] == "02") {
						return "aui-status-complete";
					}
				}
			};
			var columnLayout = [
				{
					headerText: "정비일",
					dataField: "work_dt",
					style: "aui-center",
					width : "85", 
					minWidth : "85",
					dataType: "date",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "정비완료일",
					dataField: "job_ed_dt",
					style: "aui-center",
					width : "85", 
					minWidth : "85",
					dataType: "date",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "150", 
					minWidth : "150",
					style: "aui-center aui-popup",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					headerStyle : "aui-fold",
					width : "130", 
					minWidth : "130",
					style: "aui-left",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "150", 
					minWidth : "150",
					style: "aui-center aui-popup",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "연락처",
					dataField: "hp_no",
					width : "110", 
					minWidth : "110",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "담당센터",
					dataField: "org_name",
					width : "100", 
					minWidth : "100",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "AS담당",
					dataField: "eng_mem_name",
					headerStyle : "aui-fold",
					width : "90", 
					minWidth : "90",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				// {
				// 	headerText: "AS담당내선",
				// 	dataField: "service_tel_no",
				// 	headerStyle : "aui-fold",
				// 	width : "110",
				// 	minWidth : "110",
				// 	style: "aui-center",
				// 	filter : {
				// 		showIcon : true
				// 	},
				// },
				{
					headerText: "발송일",
					dataField: "sms_send_dt",
					style: "aui-center",
					width : "85", 
					minWidth : "85",
					dataType: "date",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "발송상태",
					dataField: "sms_result_name",
					headerStyle : "aui-fold",
					width : "70", 
					minWidth : "70",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "응답여부",
					dataField: "reply_yn",
					width : "75", 
					minWidth : "75",
					style: "aui-center",
					filter : {
						showIcon : true
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item["survey_seq"] != "" && item["reply_yn"] == 'O') {
							if (item["happycall_mile_cd"] == "02") {
								return "my-row-style";
							} else {
								return "aui-popup";
							}
						}
						return null;
					}
				},
				{
					headerText: "마일리지 적립여부",
					dataField: "happycall_mile_name",
					width : "120",
					minWidth : "120",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "회신내용",
					dataField : "ans_text",
					style : "aui-center",
					width : "450"
				},
				{
					headerText: "정비지시서번호",
					dataField: "job_report_no",
					visible: false
				},
				{
					headerText: "설문번호",
					dataField: "survey_seq",
					visible: false
				},
				{
					headerText: "장비대장번호",
					dataField: "machine_seq",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
			// 	if(event.checked) {
			// 		var uniqueValues = AUIGrid.getGridData(auiGrid);
			// 		var list = [];
			// 		for (var i = 0; i < uniqueValues.length; ++i) {
			// 			if (uniqueValues[i].happycall_mile_cd != "02") {
			// 				list.push(uniqueValues[i].job_report_no);
			// 			}
			// 		}
			// 		AUIGrid.setCheckedRowsByValue(event.pid, "job_report_no", list);
			// 	} else {
			// 		AUIGrid.setCheckedRowsByValue(event.pid, "job_report_no", []);
			// 	}
			// });

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "body_no") {
					var params = {
						"s_machine_seq" : event.item["machine_seq"]
					};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});

					// var params = {
					// 	"s_job_report_no": event.item.job_report_no
					// };
					// var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
					// $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				}

				if (event.dataField == "cust_name") {
					var params = {
						"cust_no": event.item["cust_no"]
					};
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
					$M.goNextPage('/cust/cust0102p01', $M.toGetParam(params), {popupStatus: popupOption});
				}

				if (event.dataField == "reply_yn" && event.item.reply_yn == "O") {
					var params = {
						"survey_seq": event.item.survey_seq,
						"job_report_no": event.item.job_report_no
					};

					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=500, left=0, top=0";
					$M.goNextPage('/serv/serv040404p02', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "HappyCall");
		}

		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			isLoading = true;
			$M.setValue("clickedRowIndex", "");
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

		// 조회
		function fnSearch(successFunc) {
			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_date_type": $M.getValue("s_date_type"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_body_no": $M.getValue("s_body_no"),
				"s_happycall_mile_cd": $M.getValue("s_happycall_mile_cd"),
				"s_reply_yn": $M.getValue("s_reply_yn"),
				"s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"page": page,
				"rows": $M.getValue("s_rows")
			};

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
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}

		// 설문관리
		function goSurvey() {
			var params = [{}];
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=650, left=0, top=0";
			$M.goNextPage('/serv/serv040404p01', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 발송현황
		function goCurrSituation() {
			var params = [{}];
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=450, left=0, top=0";
			$M.goNextPage('/serv/serv040404p03', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 응답현황
		function goDataSearch() {
			var params = [{}];
			var popupOption = "";
			$M.goNextPage('/serv/serv040404p05', $M.toGetParam(params), {popupStatus: popupOption});
		}


		// 미적립건 조회
		function fnGetCheckedNoMileRows() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("선택된 항목이 없습니다.");
				return false;
			}

			var noMileRows = [];
			for (var i=0; i<rows.length; i++) {
				if (rows[i].happycall_mile_cd == "01") {
					noMileRows.push(rows[i]);
				}
			}

			if (noMileRows == null || noMileRows.length == 0) {
				alert("선택한 항목 중 미적립 건이 없습니다. 확인후 진행해주세요.");
				return false;
			}
			return noMileRows;
		}

		// 마일리지 적립
		function goNewMile() {
			var checkedResult = fnGetCheckedNoMileRows();
			if (checkedResult == false) {
				return false;
			}

			var concatCols = ["job_report_no", "cust_no"];
			var gridFrm = fnGridDataToForm(concatCols, checkedResult);
			var msg = "미적립 " + checkedResult.length + "건이 적립됩니다. 진행하시겠습니까?"

			$M.goNextPageAjaxMsg(msg, this_page + '/save/mile', gridFrm, {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 마일리지 적립제외
		function goExceptMile() {
			var checkedResult = fnGetCheckedNoMileRows();
			if (checkedResult == false) {
				return false;
			}
			var concatCols = ["job_report_no"];
			var gridFrm = fnGridDataToForm(concatCols, checkedResult);

			var msg = "미적립 " + checkedResult.length + "건이 제외처리 됩니다. 진행하시겠습니까?"
			$M.goNextPageAjaxMsg(msg, this_page + '/except/mile', gridFrm, {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 2023.04.27 [재호] : 사용하지 않아 제거
		// function fnTest() {
		// 	var param = {
		// 		"shorcut_url": "/serv/serv040404p04",
		// 		"job_report_no": "JR20201102-001"
		// 	};
		//
		// 	$M.goNextPageAjax("/shortenUrl/makeShortenUrl", $M.toGetParam(param), {method: "GET"},
		// 			function (result) {
		// 				alert(result.url)
		// 			}
		// 	);
		// }
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="100px">
								<col width="240px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100x">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="75px">
								<col width="70px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<select class="form-control" id="s_date_type" name="s_date_type">
										<option value="sms_send_dt">발송일</option>
										<option value="job_ed_dt">정비완료일자</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일" value="${inputParam.s_start_dt}">
											</div>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="조회 완료일" value="${inputParam.s_end_dt}">
											</div>
										</div>
									</div>
								</td>
								<th>담당센터</th>
								<td>
									<select class="form-control" id="s_center_org_code" name="s_center_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}" <c:if test="${item.org_code eq orgBean.org_code}">selected="selected"</c:if> >${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>모델명</th>
								<td>
									<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
								</td>
								<th>고객명</th>
								<td>
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
								</td>
								<th>차대번호</th>
								<td>
									<input type="text" class="form-control" id="s_body_no" name="s_body_no">
								</td>
								<th>적립여부</th>
								<td>
									<select class="form-control" id="s_happycall_mile_cd" name="s_happycall_mile_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['HAPPYCALL_MILE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>응답여부</th>
								<td>
									<select class="form-control" id="s_reply_yn" name="s_reply_yn">
										<option value="">- 전체 -</option>
										<option value="Y">O</option>
										<option value="N">X</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- Happy Call 조회결과 -->
					<div class="title-wrap mt10">
						<h4>Happy Call 조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</c:if>									
								<label for="s_toggle_column" style="color:black;">
								<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>	
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /Happy Call 조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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