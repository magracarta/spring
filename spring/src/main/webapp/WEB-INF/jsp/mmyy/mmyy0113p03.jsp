<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 일일현황판 > 업무리스트
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-28 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var orgCode = "${s_org_code}";

		$(document).ready(function(){
			fnInit();
			createAUIGrid();
			goSearch();
		});

		function enter(fieldObj) {
			var field = ["s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		function fnInit() {
			// 일일현황 메뉴내기능 전체부서 조회 권한 없으면 부서 조회조건 비활성화
			if(${center_desable_yn eq 'Y'}) {
				$("#s_org_code").prop("disabled", true);
			}
		}

		function goSearch() {
			var param = {
				"s_search_type" : $M.getValue("s_search_type"),
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_org_code" : $M.getValue("s_org_code"),
				"s_day_board_type_cd" : $M.getValue("s_day_board_type_cd"),
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
							orgCode = $M.getValue("s_org_code");
						};
					}
			);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				enableSorting : true,
				editable : false,
				fillColumnSizeMode : true,
				height : 550,
				rowStyleFunction : function(rowIndex, item) {
					// 지정완료인 경우 bg컬러 그레이
					if(item.board_yn == "Y") {
						return "aui-background-darkgray";
					}
					return "";
				}
			};
			var columnLayout = [
				{
					headerText: "업무구분",
					dataField: "day_board_type_name",
					width : "80",
					minWidth : "60",
					style: "aui-center"
				},
				{
					headerText: "제목",
					dataField: "title",
					width : "180",
					minWidth : "140",
					editable : false,
					style: "aui-left aui-popup"
				},
				{
					headerText : "예정일자",
					dataField : "plan_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					width : "100",
					minWidth : "80"
				},
				{
					headerText : "정비희망시간",
					dataField : "repair_request_ti",
					style : "aui-center",
					width : "80",
					minWidth : "80"
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "연락처",
					dataField: "hp_no",
					width : "120",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "140",
					minWidth : "130",
					style: "aui-center"
				},
				{
					headerText: "원담당자",
					dataField: "origin_mem_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "지정담당자",
					dataField: "board_mem_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText : "지정일자",
					dataField : "board_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					width : "100",
					minWidth : "80"
				},
				{
					headerText: "지정시간",
					dataField: "work_period_ti",
					width : "100",
					minWidth : "80",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (item.work_st_ti == "" && item.work_ed_ti == "") {
							return "";
						}
						return item.work_st_ti + " ~ " + item.work_ed_ti;
					},
				},
				{
					headerText: "지정인",
					dataField: "reg_mem_name",
					width : "100",
					minWidth : "80",
					style: "aui-center"
				},
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "title") {
					if (event.item.board_yn == "Y") {
						var param = {
							"day_board_seq": event.item.day_board_seq
						}
						$M.goNextPage("/mmyy/mmyy0113p02", $M.toGetParam(param), {popupStatus : ""});
					} else {
						if (${edit_yn eq 'Y'}) {
							var data = event.item;
							var param = {
								"list_yn": "Y",
								"board_org_code": orgCode,
								"board_dt": event.item.plan_dt,
							}

							var tempMap = {};
							tempMap.cust_name = data.real_cust_name;
							tempMap.machine_name = data.machine_name;
							tempMap.body_no = data.body_no;
							tempMap.day_board_type_cd = data.day_board_type_cd;
							tempMap.day_board_type_name = data.day_board_type_name;
							tempMap.cust_no = data.cust_no;
							tempMap.stat_mon = data.stat_mon;
							tempMap.machine_seq = data.machine_seq;
							tempMap.as_todo_seq = data.as_todo_seq;
							tempMap.rental_doc_no = data.rental_doc_no;
							tempMap.job_report_no = data.job_report_no;
							tempMap.origin_mem_no = data.origin_mem_no;
							tempMap.origin_mem_name = data.origin_mem_name;
							tempMap.cap_cnt = data.cap_cnt;
							tempMap.area_name = data.area_name;
							tempMap.todo_text = data.todo_text;
							tempMap.day_job_report_no = "";

							var list_data = "";
							for (var key in tempMap) {
								list_data += key + '?|#' + tempMap[key] + '##?';
							}
							param.list_data = list_data;
							console.log(list_data);

							$M.goNextPage("/mmyy/mmyy0113p01", $M.toGetParam(param), {popupStatus: ""});
						} else {
							alert("업무스케쥴 작성 권한이 없습니다.");
						}
					}
				}
			});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
			var exportProps = {};
			fnExportExcel(auiGrid, "업무리스트", exportProps);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>

<body class="bg-white">
<form id="main_form" name="main_form">
	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="80px">
						<col width="260px">
						<col width="55px">
						<col width="100px">
						<col width="80px">
						<col width="100px">
						<col width="80px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>
							<select class="form-control" id="s_search_type" name="s_search_type">
								<option value="plan">예정일자</option>
								<option value="board">지정일자</option>
							</select>
						</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="검색시작일">
									</div>
								</div>
								<div class="col-auto">~</div>
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="검색종료일">
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
						<th>부서</th>
						<td>
							<select class="form-control" id="s_org_code" name="s_org_code">
								<c:forEach var="item" items="${center_list}">
									<option value="${item.org_code}" <c:if test="${inputParam.s_org_code == item.org_code}">selected</c:if>>${item.org_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>업무구분</th>
						<td>
							<select class="form-control" id="s_day_board_type_cd" name="s_day_board_type_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['DAY_BOARD_TYPE']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>담당자</th>
						<td>
							<input class="form-control" type="text" name="s_mem_name">
						</td>
						<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->

			<!-- 검색결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</div>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 550px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /검색결과 -->
		</div>
	</div>
</form>
</body>
</html>