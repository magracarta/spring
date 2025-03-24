<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > 종료점검 Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-20 19:54:29
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
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var now = $M.getCurrentDate("yyyyMMdd");

			if ("${inputParam.s_work_gubun}" != "Y") {
				$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
				$M.setValue("s_end_dt", $M.toDate(now));
			}

			if ("${inputParam.s_work_gubun}" == "Y") {
				$M.setValue("s_total_search", "Y");
				$M.setValue("s_treat_yn", "");

			}

			var org = ${orgBeanJson};
			if (org.org_gubun_cd != "BASE") {
				$("#s_center_org_code").prop("disabled", true);
			}
			goSearch();
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
				rowIdField: "_$uid",
				showRowNumColumn: true,
				enableFilter :true,
			};

			var columnLayout = [
				{
					headerText: "판매일",
					dataField: "sale_dt",
					style: "aui-center",
					dataType: "date",
					width : "90", 
					minWidth : "90",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "125", 
					minWidth : "140",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "130", 
					minWidth : "130",
					style: "aui-center",
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
					headerText: "연락처",
					dataField: "hp_no",
					width : "125", 
					minWidth : "125",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "담당센터",
					dataField: "center_org_name",
					width : "100", 
					minWidth : "100",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "판매자",
					dataField: "sale_mem_name",
					width : "90", 
					minWidth : "90",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "A/S담당",
					dataField: "service_mem_name",
					headerStyle : "aui-fold",
					width : "90", 
					minWidth : "90",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "AS담당내선",
					dataField: "service_office_tel",
					headerStyle : "aui-fold",
					width : "130", 
					minWidth : "130",
					style: "aui-center",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "종료점검예정일",
					dataField: "deadline_dt",
					style: "aui-center",
					width : "105", 
					minWidth : "105",
					dataType: "date",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
				},
				{
					headerText: "종료점검처리일",
					dataField: "as_dt",
					style: "aui-center aui-popup",
					dataType: "date",
					width : "105", 
					minWidth : "105",
					formatString: "yy-mm-dd",
					filter : {
						showIcon : true,
						displayFormatValues : true,
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						return "aui-grid-selection-row-satuday-bg";
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.treat_yn == "N" && value != "") {
							return "작성중";
						} else if (item.treat_yn == "N" && value == "") {
							return "일지등록"
						} else if (item.treat_yn == "Y") {
							return value;
						}
					},
				},
				{
					headerText: "AS번호",
					dataField: "as_no",
					visible: false
				},
				{
					headerText: "장비대장번호",
					dataField: "machine_seq",
					visible: false
				},
				{
					headerText: "일지상태",
					dataField: "treat_yn",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				if (event.dataField == "as_dt") {
					var params = {
						"as_call_type_cd": "3"
					};
					if (event.item.as_no == "") {
						params.s_machine_seq = event.item.machine_seq;
						$M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						params.s_as_no = event.item.as_no
						$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
					}
				}

				if (event.dataField == "body_no") {
					var params = {
						"s_machine_seq": event.item.machine_seq
					};

					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
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
			fnExportExcel(auiGrid, "종료점검Call");
		}

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

		// 검색
		function fnSearch(successFunc) {
			var sTreatYn = $M.getValue("s_treat_yn");
			var sTotalSearch = $M.getValue("s_total_search");
			if (sTreatYn == "" || sTreatYn == null) {
				sTotalSearch = "Y";
			}

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_treat_yn": $M.getValue("s_treat_yn"),
				"s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_total_search": sTotalSearch,
				"s_work_gubun" : $M.getValue("s_work_gubun"),
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
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
			});
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="s_total_search" name="s_total_search">
<input type="hidden" id="s_work_gubun" name="s_work_gubun" value="${inputParam.s_work_gubun}">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="250px">
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>판매일자</th>
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
								<th>일지상태</th>
								<td>
									<select id="s_treat_yn" name="s_treat_yn" class="form-control">
										<option value="">- 전체 -</option>
										<option value="N" selected="selected">미결</option>
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
					<!-- 종료점검 Call 조회결과 -->
					<div class="title-wrap mt10">
						<h4>종료점검 Call 조회결과</h4>
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
					<!-- /종료점검 Call 조회결과 -->
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