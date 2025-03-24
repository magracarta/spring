<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 앱 고객정보관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-25 09:19:03
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
			createAUIGrid();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_web_id", "s_cust_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		function goSearch() {
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

		// 조회
		function fnSearch(successFunc) {
			if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_web_id": $M.getValue("s_web_id"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_c_cust_status_cd_str" : $M.getValue("s_c_cust_status_cd"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"page": page,
				"rows": $M.getValue("s_rows")
			};

			_fnAddSearchDt(param, "s_start_dt", "s_end_dt");
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

		// 엑셀 다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "앱 고객정보관리");
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				editable : false,
				fillColumnSizeMode : true,
				rowStyleFunction: function (rowIndex, item) {
					// 매칭성공시 배경 그레이 (장비보유 Y 등록이력 Y 고객은 승인과정 없이 바로 앱 사용 가능)
					if ((item["c_cust_mapping_cd"] == "01"||item["c_cust_mapping_cd"] == "03") && item["c_cust_status_cd"] == "02") {
						return "aui-background-darkgray";
					}
					// 탈퇴상태 배경 그레이
					if (item["c_cust_status_cd"] == "03") {
						return "aui-background-darkgray";
					}
				}
			};
			var columnLayout = [
				{
					headerText : "앱 고객",
					children: [
						{
							dataField : "app_cust_no",
							visible : false
						},
						{
							headerText : "가입일자",
							dataField : "reg_date",
							style : "aui-center",
							dataType : "date",
							formatString : "yyyy-mm-dd",
							width : "7%"
						},
						{
							headerText : "아이디",
							dataField : "web_id",
							style : "aui-center",
							width : "8%"
						},
						{
							headerText : "고객명",
							dataField : "app_cust_name",
							style : "aui-popup",
							width : "7%"
						},
						{
							headerText : "휴대폰",
							dataField : "app_hp_no",
							style : "aui-center",
							width : "9%",
						},
						{
							headerText : "주소",
							dataField : "app_addr",
							style : "aui-left",
							width : "17%",
						}
					]

				},
				{
					headerText : "매칭고객",
					children: [
						{
							dataField : "cust_no",
							visible : false
						},
						{
							headerText : "고객명",
							dataField : "cust_name",
							style : "aui-popup",
							width : "7%",
						},
						{
							headerText : "휴대폰",
							dataField : "hp_no",
							style : "aui-center",
							width : "9%",
						}
					]
				},
				{
					headerText : "장비보유여부",
					dataField : "machine_yn",
					style : "aui-center",
					width : "6%"
				},
				{
					headerText : "처리상태",
					dataField : "c_cust_status_name",
					style : "aui-popup",
					width : "8%"
				},
				{
					headerText : "센터명",
					dataField : "center_org_name",
					style : "aui-center",
					width : "6%"
				},
				{
					headerText : "처리자",
					dataField : "reg_name",
					style : "aui-center",
					width : "6%"
				},
				{
					headerText : "처리일",
					dataField : "c_cust_status_date",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "7%"
				},
				{
					headerText : "매칭상태",
					dataField : "c_cust_mapping_name",
					style : "aui-center",
					width : "6%"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				// 앱 고객정보 상세 팝업
				if (event.dataField == "app_cust_name") {
					var param = {
						app_cust_no : event.item["app_cust_no"]
					}
					$M.goNextPage("/cust/cust0501p01", $M.toGetParam(param), {popupStatus : ""});
				}

				// 고객정보 상세 팝업
				if (event.dataField == "cust_name") {
					var custNo = event.item["cust_no"];
					if (custNo != "") {
						var param = {
							cust_no : custNo
						}
						$M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : ""});
					}
				}

				// 매칭이력 팝업
				if (event.dataField == "c_cust_status_name") {
					var param = {
						app_cust_no : event.item["app_cust_no"]
					}
					$M.goNextPage("/cust/cust0501p02", $M.toGetParam(param), {popupStatus : ""});
				}
			});

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
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
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="260px">
								<col width="55px">
								<col width="120px">
								<col width="55px">
								<col width="120px">
								<col width="55px">
								<col width="100px">
								<col width="65px">
								<col width="180px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>가입일자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" value="${searchDtMap.s_start_dt}" dateFormat="yyyy-MM-dd" alt="조회 시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="조회 완료일">
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
								<th>아이디</th>
								<td>
									<input type="text" class="form-control" id="s_web_id" name="s_web_id">
								</td>
								<th>고객명</th>
								<td>
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
								</td>
								<th>센터</th>
								<td>
									<select class="form-control" id="s_center_org_code" name="s_center_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>처리상태</th>
								<td>
									<input type="text" style="width : 180px;"
										   id="s_c_cust_status_cd"
										   name="s_c_cust_status_cd"
										   easyui="combogrid"
										   header="Y"
										   easyuiname="c_cust_status_list"
										   panelwidth="200"
										   maxheight="300"
										   textfield="code_name"
										   multi="Y"
										   idfield="code_value" />
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
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
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
</form>
</body>
</html>