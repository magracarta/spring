<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객관리 > 고객센터 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-17 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_reg_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		function goNew() {
			$M.goNextPage("/cust/cust040101");
		}

		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_start_dt", "s_end_dt"]}) == false) {
				return;
			}

			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			};

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_cust_center_proc_cd": $M.getValue("s_cust_center_proc_cd"),
				"s_reg_name": $M.getValue("s_reg_name"),
				"s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "불만접수내역");
		}

		function createAUIGrid() {
			var gridPros = {
				editable: false,
				showRowCheckColumn: false,
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "접수일자",
					dataField: "reg_date",
					dataType: "date",
					formatString: "yy-mm-dd",
					width : "70",
					minWidth : "60",
					style: "aui-popup"
				},
				{
					headerText: "접수자",
					dataField: "reg_mem_name",
					width : "70",
					minWidth : "60"
				},
				{
					headerText: "접수부서",
					dataField: "receipt_org_name",
					width : "70",
					minWidth : "60"
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "90",
					minWidth : "80"
				},
				{
					headerText: "휴대폰",
					dataField: "hp_no",
					width : "110",
					minWidth : "100"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "100",
					minWidth : "90"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "150",
					minWidth : "140"
				},
				{
					headerText: "출고일자",
					dataField: "out_dt",
					dataType: "date",
					formatString: "yy-mm-dd",
					width : "70",
					minWidth : "60",
				},
				{
					headerText: "판매자",
					dataField: "sale_mem_name",
					width : "70",
					minWidth : "60"
				},
				{
					headerText: "진행상태",
					dataField: "cust_center_proc_name",
					width : "70",
					minWidth : "60",
				},
				{
					headerText: "접수내용",
					dataField: "req_memo",
					style: "aui-left",
					width : "210",
					minWidth : "200",
				},
				{
					headerText: "처리일시",
					dataField: "proc_date",
					dataType: "date",
					formatString: "yy-mm-dd",
					width : "70",
					minWidth : "60",
				},
				{
					headerText: "처리자",
					dataField: "proc_mem_name",
					width : "70",
					minWidth : "60",
				},
				{
					headerText: "처리내용",
					dataField: "resp_memo",
					style: "aui-left",
					width : "70",
					minWidth : "60",
				},
				{
					headerText: "접수자넘버",
					dataField: "reg_mem_no",
					visible: false
				},
				{
					headerText: "상담일련번호",
					dataField: "cust_center_seq",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=470, left=0, top=0";
				var param = {
					"s_cust_center_seq": event.item.cust_center_seq
				};

				if (event.dataField == "reg_date") {
					$M.goNextPage('/cust/cust0401p01', $M.toGetParam(param), {popupStatus: popupOption});
				}
			});
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
								<col width="60px">
								<col width="260px">
								<col width="40px">
								<col width="120px">
								<col width="70px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>접수일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="접수시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group dev_nf">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="접수종료일" value="${searchDtMap.s_end_dt}">
											</div>
										</div>

										<!-- <details data-popover="up">

										</details> -->
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
											<jsp:param name="st_field_name" value="s_start_dt"/>
											<jsp:param name="ed_field_name" value="s_end_dt"/>
											<jsp:param name="click_exec_yn" value="Y"/>
											<jsp:param name="exec_func_name" value="goSearch();"/>
										</jsp:include>
									</div>
								</td>
								<th>접수자</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_reg_name" name="s_reg_name">
									</div>
								</td>
								<th>진행상태</th>
								<td>
									<select class="form-control" id="s_cust_center_proc_cd" name="s_cust_center_proc_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['CUST_CENTER_PROC']}">
											<c:if test="${list.code_value eq '0' || list.code_value eq '3'}">
												<option value="${list.code_value}">${list.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" onclick="javascript:goSearch()" style="width: 50px;">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>불만접수내역</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
									</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" class="mt10" style="margin-top: 5px; height: 500px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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