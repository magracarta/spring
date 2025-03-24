<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 거래처별 매입현황
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-25 18:23:54
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
			var field = ["s_item_id", "s_item_name", "s_cust_name"];
			$.each(field, function () {
				if (fieldObj.name == "s_cust_name") {
					fnSearchClientComm();
				} else {
					goSearch();
				}
			});
		}

		// 엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "거래처별 매입현황");
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
			var params = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_item_id": $M.getValue("s_item_id"),
				"s_item_name": $M.getValue("s_item_name"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_com_buy_group_cd": $M.getValue("s_com_buy_group_cd"),
				"s_part_production_cd": $M.getValue("s_part_production_cd"),
				"s_part_mng_cd" : $M.getValue("s_part_mng_cd"),
				"s_part_group_cd" : $M.getValue("s_part_group_cd"),	// (Q&A 11935) 분류구분 검색조건 추가 21.09.06 박예진
				"page": page,
				"rows": $M.getValue("s_rows")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						isLoading = false;
						if (result.success) {
							successFunc(result);

							// 만약 칼럼 사이즈들의 총합이 그리드 크기보다 작다면, 나머지 값들을 나눠 가져 그리드 크기에 맞추기
							var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);

							// 구해진 칼럼 사이즈를 적용 시킴.
							AUIGrid.setColumnSizeList(auiGrid, colSizeList);
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

		// 닫기
		function fnClose() {
			window.close();
		}

		// 매입처조회
		function fnSearchClientComm() {
			var param = {
				's_cust_name': $M.getValue('s_cust_name')
			};
			openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
		}

		function setSearchClientInfo(data) {
			$M.setValue("s_cust_name", data.cust_name);
			$M.setValue("s_cust_no", data.cust_no);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColum: true,
				editable: false
			};

			var columnLayout = [
				{
					headerText: "매입처",
					dataField: "client_cust_name",
					style: "aui-left"
				},
				{
					headerText: "입고일자",
					dataField: "inout_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					style: "aui-center"
				},
				{
					headerText: "번호",
					dataField: "seq_no",
					style: "aui-center"
				},
				{
					headerText: "품번",
					dataField: "item_id",
					style: "aui-left"
				},
				{
					headerText: "품명",
					dataField: "item_name",
					style: "aui-left"
				},
				{
					headerText: "수량",
					dataField: "qty",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-center"
				},
				{
					headerText: "단가",
					dataField: "unit_price",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "금액",
					dataField: "amt",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0"
				},
				{
					headerText: "VAT",
					dataField: "vat_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "합계",
					dataField: "tot_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "비고",
					dataField: "desc_text",
					style: "aui-left"
				},
				{
					headerText: "매입자",
					dataField: "reg_mem_name",
					style: "aui-center"
				},
				{
					headerText: "계약납기일",
					dataField: "delivary_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					style: "aui-center"
				},
				{
					headerText: "발주번호",
					dataField: "part_order_no",
					style: "aui_center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="s_cust_no" name="s_cust_no">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="260px">
						<col width="50px">
						<col width="120px">
						<col width="60px">
						<col width="120px">
						<col width="60px">
						<col width="160px">
						<col width="*">
					</colgroup>
					<tbody>
					<tr>
						<th>입고일자</th>
						<td>
							<div class="row mg0">
								<div class="col-5">
									<div class="input-group dev_nf">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 시작일" value="${inputParam.s_start_dt}">
									</div>
								</div>
								<div class="col-auto">~</div>
								<div class="col-5">
									<div class="input-group dev_nf">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 종료일" value="${inputParam.s_end_dt}">
									</div>
								</div>
							</div>
						</td>
						<th>부품번호</th>
						<td>
							<input type="text" class="form-control" id="s_item_id" name="s_item_id">
						</td>
						<th>부품명</th>
						<td>
							<input type="text" class="form-control" id="s_item_name" name="s_item_name">
						</td>
						<th>매입처</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0" placeholder="" id="s_cust_name" name="s_cust_name" value="" readonly="readonly">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
						</tr>
						<tr>
						<th>업체그룹</th>
						<td>
							<select class="form-control width180px" id="s_com_buy_group_cd" name="s_com_buy_group_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">
									<option value="${item.code_value}">${item.code_desc}</option>
								</c:forEach>
							</select>
						</td>
						<th>생산구분</th>
						<td>
							<select class="form-control" id="s_part_production_cd" name="s_part_production_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['PART_PRODUCTION']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>부품구분</th>
						<td>
							<select class="form-control" id="s_part_mng_cd" name="s_part_mng_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['PART_MNG']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>분류구분</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col">
									<div class="input-group">
										<input type="text" id="s_part_group_cd" name="s_part_group_cd" style="width : 170px";
										 easyui="combogrid" easyuiname="partGroupCode" idfield="code_value"  textfield="code_name" multi="N" />
									</div>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div class="title-wrap mt5">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>
				<div class="right" id="btnHide">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /검색결과 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>