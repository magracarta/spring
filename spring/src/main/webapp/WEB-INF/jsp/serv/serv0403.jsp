<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전산업무미결/예정 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-23 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	
	var auiGrid;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		fnInit();

		goSearch();
	});

	function fnInit() {
		// 업무일지
		if ("${inputParam.s_page_type}" == "work") {
			$M.setValue("s_start_dt", "${inputParam.s_start_dt}");
			$M.setValue("s_end_dt", "${inputParam.s_end_dt}");
		} else {
			$M.setValue("s_start_dt", "${searchDtMap.s_start_dt}");
			$M.setValue("s_end_dt", "${searchDtMap.s_end_dt}");
		}
	}

	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_cust_name", "s_reg_mem_name", "s_appr_mem_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			}
		});
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField: "_$uid",
			showRowNumColumn: true,
			enableFilter :true,
		};
		var columnLayout = [
			{
				headerText: "업무구분",
				dataField: "gubun_text",
				style: "aui-left",
				width: "300",
				minWidth: "290",
				filter : {
					showIcon : true
				},
			},
			{
				headerText: "관리번호",
				dataField: "doc_no",
				style: "aui-center aui-popup",
				width: "140",
				minWidth: "130",
				filter : {
					showIcon : true
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var str = value.length > 6 ? value.substring(4, 16) : value;
					return str;
				}
			},
			{
				headerText: "고객명",
				dataField: "cust_name",
				style: "aui-center",
				width : "150",
				minWidth : "140",
				filter : {
					showIcon : true
				},
			},
			{
				headerText: "차대번호",
				dataField: "body_no",
				style: "aui-center",
				width : "150",
				minWidth : "140",
				filter : {
					showIcon : true
				},
			},
			{
				headerText: "담당자",
				dataField: "reg_mem_name",
				style: "aui-center",
				width : "150",
				minWidth : "140",
				filter : {
					showIcon : true
				},
			},
			{
				headerText : "담당자 부서",
				dataField : "org_code",
				visible : false
			},
			{
				headerText : "구분",
				dataField : "gubun",
				visible : false
			},
			{
				headerText : "담당자번호",
				dataField : "reg_mem_no",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);

		AUIGrid.bind(auiGrid, "cellClick", function (event) {
			if (event.dataField == "doc_no") {
				var params = {};
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";

				switch (event.item.gubun) {
					case "JOB_REPORT" :
						params.s_job_report_no = event.item.doc_no;
						$M.goNextPage("/serv/serv0101p01", $M.toGetParam(params), {popupStatus: poppupOption});
						break;
					case "AS_REPAIR_R" :
						params.s_as_no = event.item.doc_no;
						$M.goNextPage("/serv/serv0102p01", $M.toGetParam(params), {popupStatus: poppupOption});
						break;
					case "AS_REPAIR_O" :
						params.s_as_no = event.item.doc_no;
						$M.goNextPage("/serv/serv0102p12", $M.toGetParam(params), {popupStatus: poppupOption});
						break;
					case "AS_CALL" :
						params.s_as_no = event.item.doc_no;
						$M.goNextPage("/serv/serv0102p06", $M.toGetParam(params), {popupStatus: poppupOption});
						break;
					case "WORK_DIARY" :
						params.s_mem_no = event.item.reg_mem_no;
						params.s_work_dt = event.item.cust_no;

						var orgGubun = event.item.org_code.substr(0, 1);
						//서비스부
						if(orgGubun == "5") {
							$M.goNextPage('/mmyy/mmyy0103p01', $M.toGetParam(params), {popupStatus : poppupOption});
						}

						//영업부
						if(orgGubun == "4" ) {
							$M.goNextPage('/mmyy/mmyy0103p02', $M.toGetParam(params), {popupStatus : poppupOption});
						}

						//관리부,경영지원부
						if(orgGubun == "2" ||  orgGubun == "3") {
							$M.goNextPage('/mmyy/mmyy0103p03', $M.toGetParam(params), {popupStatus : poppupOption});
						}

						//부품부
						if(orgGubun == "6" ) {
							$M.goNextPage('/mmyy/mmyy0103p04', $M.toGetParam(params), {popupStatus : poppupOption});
						}

						break;
					case "MCH_TODO" :

						params = {
							"__s_machine_seq" : event.item.doc_no,
							"__s_as_no" : '',
							"__page_type" : $M.nvl($M.getValue("page_type"), "N"),
							"parent_js_name" : "fnSetJobOrder"
						};
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
						$M.goNextPage('/serv/serv0101p07', $M.toGetParam(params), {popupStatus : popupOption});
						break;
				}
			}
		});

		$("#auiGrid").resize();
	}

	// 조회
	function goSearch() {
		var param = {
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_cust_name": $M.getValue("s_cust_name"),
			"s_reg_mem_name": $M.getValue("s_reg_mem_name"),
			"s_appr_mem_name": $M.getValue("s_appr_mem_name"),
			"login_mem_no" : $M.getValue("login_mem_no")
		};

		// [재호 2023/11/30] 업무일지 상세(서비스부) 에서 열린 경우
		// - jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp 를 include 하지 않아서 fnAddSearchDt 가 없음
		if(${inputParam.s_page_type ne 'work'}) {
			_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
		}
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "미결업무내역");
	}

	function fnSetJobOrder() {
		// 해당 화면에서는 아무것도 안함
	}
</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="login_mem_no" name="login_mem_no" value="${inputParam.login_mem_no}">
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
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="60px">
								<col width="120px">
								<col width="55px">
								<col width="120px">
								<col width="55px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="종료일">
											</div>
										</div>

										<!-- <details data-popover="up">

                                        </details> -->
										<c:if test="${inputParam.s_page_type ne 'work'}">
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
												<jsp:param name="st_field_name" value="s_start_dt"/>
												<jsp:param name="ed_field_name" value="s_end_dt"/>
												<jsp:param name="click_exec_yn" value="Y"/>
												<jsp:param name="exec_func_name" value="goSearch();"/>
											</jsp:include>
										</c:if>
									</div>
								</td>
								<th>차주명</th>
								<td><input type="text" class="form-control" id="s_cust_name" name="s_cust_name"></td>
								<th>담당자</th>
								<td><input type="text" class="form-control" id="s_reg_mem_name" name="s_reg_mem_name"></td>
								<th>결재자</th>
								<td><input type="text" class="form-control" id="s_appr_mem_name" name="s_appr_mem_name"></td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>미결업무내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>