<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-05-21 14:23:48
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
			// 그리드 생성
			createAUIGrid();

			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no", "s_cust_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		function goNew() {
			$M.goNextPage('/sale/sale020501');
		}

		function goSearch() {
			// if($M.getValue("s_cust_name") == "" && $M.getValue("s_body_no") == "") {
			// 	alert("[고객명, 차대번호] 중 하나는 필수입니다.");
			// 	return;
			// }

			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function (result) {
				AUIGrid.setGridData(auiGrid, result.list);
				console.log(result.total_cnt);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			});
		}

		// 검색기능
		function fnSearch(successFunc) {
			var param = {
				"s_body_no": $M.getValue("s_body_no"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_engine_no_1": $M.getValue("s_engine_no_1"),
				"page": page,
				"rows": $M.getValue("s_rows")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
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

		// 액셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "장비대장관리");
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				height: 515,
				showRowNumColumn: true,
			};

			// 컬럼레이아웃
			var columnLayout = [
				{
					headerText: "차대번호",
					dataField: "body_no",
					style: "aui-center aui-popup"
				},
				{
					headerText: "장비구분",
					dataField: "machine_owner",
					width: "5%",
					style: "aui-center"
				},
				{
					headerText: "메이커",
					dataField: "maker_name",
					// width : "10%",
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					// width : "15%",
					style: "aui-center"
				},
				{
					headerText: "엔진번호",
					dataField: "engine_no_1",
					// width : "10%",
					style: "aui-center"
				},
				{
					headerText: "차주명",
					dataField: "cust_name",
					// width : "10%",
					style: "aui-center"
				},
				{
					headerText: "관리등급",
					dataField: "cust_grade_cd",
					// width : "10%",
					style: "aui-center"
				},
				{
					headerText: "업체명",
					dataField: "breg_name",
					// width : "15%",
					style: "aui-center"
				},
				{
					headerText: "장비기사명",
					dataField: "driver_name",
					style: "aui-center"
				},
				{
					headerText: "장비일련번호",
					dataField: "machine_seq",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "body_no") {
					// 보낼 데이터
					var params = {
						"s_machine_seq": event.item.machine_seq
					};
					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
			$("#auiGrid").resize();

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
								<col width="50px">
								<col width="200px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="200px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>차대번호</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_body_no" name="s_body_no" class="form-control">
									</div>
								</td>
                <th>엔진번호</th>
                <td>
                  <div class="icon-btn-cancel-wrap">
                    <input type="text" id="s_engine_no_1" name="s_engine_no_1" class="form-control">
                  </div>
                </td>
								<th>차주명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" id="s_cust_name" name="s_cust_name" class="form-control">
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>모델명</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
										<jsp:param name="required_field" value="s_machine_name"/>
										<jsp:param name="s_maker_cd" value=""/>
										<jsp:param name="s_machine_type_cd" value=""/>
										<jsp:param name="s_sale_yn" value=""/>
										<jsp:param name="readonly_field" value=""/>
									</jsp:include>
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
						<h4>장비내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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