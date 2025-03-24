<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > 미수금 Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-20 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
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

			var org = ${orgBeanJson};
			if(org.org_gubun_cd != "BASE") {
				$("#s_center_org_code").prop("disabled", true);
			}
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "고객명",
					dataField: "cust_name",
					style: "aui-center aui-popup"
				},
				{
					headerText: "연락처",
					dataField: "hp_no",
					style: "aui-center"
				},
				{
					headerText: "총미수금",
					dataField: "ed_misu_amt",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0"
				},
				{
					headerText: "담당센터",
					dataField: "misu_org_name",
					style: "aui-center"
				},
				{
					headerText: "미수담당자",
					dataField: "misu_mem_name",
					style: "aui-center"
				},
				{
					headerText: "미수입금예정일",
					dataField: "deposit_plan_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd",
				},
				{
					headerText : "고객번호",
					dataField : "cust_no",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "cust_name") {
					var params = {
						"s_cust_no" : event.item.cust_no,
						"s_start_dt" : $M.getValue("s_start_dt"),
						"s_end_dt" : $M.getValue("s_end_dt")
					};

					openDealLedgerPanel($M.toGetParam(params));
				}
			});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "미수금Call");
		}

		// 조회
		function goSearch() {
			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_treat_yn": $M.getValue("s_treat_yn"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}
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
								<col width="250px">
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>미수입금예정일자</th>
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
					<!-- 미수금 Call 조회결과 -->
					<div class="title-wrap mt10">
						<h4>미수금 Call 조회결과</h4>
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
					<!-- /미수금 Call 조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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