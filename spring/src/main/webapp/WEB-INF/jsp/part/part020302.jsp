<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > 정비부품 입/출고처리 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-05 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var org = ${orgBeanJson};
			if(org.org_gubun_cd != "BASE") {
				$("#s_org_code").prop("disabled", true);
			}
		}

		// 조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_start_dt", "s_end_dt"]}) == false) {
				return;
			}

			var param = {
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_org_code": $M.getValue("s_org_code"),
				"s_job_status_cd": $M.getValue("s_job_status_cd")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "정비부품 입/출고처리");
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColum: true
			};

			var columnLayout = [
				{
					headerText: "상담일",
					dataField: "consult_dt",
					width : "75",
					minWidth : "75",
					style: "aui-center aui-popup",
					dataType : "date",
					formatString : "yy-mm-dd",
				},
				{
					headerText: "방문일",
					dataField: "visit_dt",
					width : "75",
					minWidth : "75",
					style: "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd",
				},
				{
					headerText: "차주명",
					dataField: "cust_name",
					width : "130",
					minWidth : "130",
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "120",
					minWidth : "120",
					style: "aui-left"
				},
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "160",
					minWidth : "160",
					style: "aui-center"
				},
				{
					headerText: "접수자",
					dataField: "reg_mem_name",
					width : "70",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "정비자",
					dataField: "eng_mem_name",
					width : "70",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "진행",
					dataField: "job_status_name",
					width : "90",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "서비스일",
					dataField: "as_dt",
					width : "75",
					minWidth : "75",
					style: "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText: "관련번호",
					dataField: "job_report_no",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var jobNo = value;
						return jobNo.substring(4, 16);
					},
					style: "aui-center"
				},
				{
					headerText: "작업센터",
					dataField: "org_name",
					width : "70",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "접수",
					dataField: "qty",
					width : "50",
					minWidth : "50",
					style: "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText: "출고",
					dataField: "out_qty",
					width : "50",
					minWidth : "50",
					style: "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText: "사용",
					dataField: "use_qty",
					width : "50",
					minWidth : "50",
					style: "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText: "반품",
					dataField: "return_qty",
					width : "50",
					minWidth : "50",
					style: "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "전표바코드",
					dataField : "doc_barcode_no",
					visible : false
				},
				{
					headerText : "작업지시서진행상태코드",
					dataField : "job_status_cd",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "consult_dt") {
					var params = {
						"doc_barcode_no" : event.item.doc_barcode_no
					};

					if(event.item.job_status_cd == "0") {
						alert("[접수] 상태의 정비건은 출고처리 할 수 없습니다.");
						return;
					}

					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
					$M.goNextPage('/part/part0203p02', $M.toGetParam(params), {popupStatus: poppupOption});
				}
			});
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>발송일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="발송시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="발송종료일" value="${searchDtMap.s_end_dt}">
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
								<th>센터</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
											<option value="${item.code_value}" <c:if test="${item.code_value == orgBean.org_code}">selected="selected"</c:if> >${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>진행상태</th>
								<td>
									<select class="form-control" name="s_job_status_cd" id="s_job_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['JOB_STATUS']}">
											<c:if test="${list.code_value ne 8}">
												<option value="${list.code_value}">${list.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px; width: 100%;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>