<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 위탁판매점직원관리
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});

		function goSearch() {
			var param = {
				s_agency_gubun_cd : $M.getValue("s_agency_gubun_cd"),
				s_agency_rep_yn : $M.getValue("s_agency_rep_yn"),
				s_breg_name : $M.getValue("s_breg_name"),
				s_mem_name : $M.getValue("s_mem_name"),
				s_org_code : $M.getValue("s_org_code"),
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				s_work_status_cd : $M.getValue("s_work_status_cd"),
				s_app_yn : $M.getValue("s_app_yn"),
				s_sort_key : "org_code",
				s_sort_method : "desc",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		function goNew() {
			$M.goNextPage("/sale/sale030301");
		}

		function fnExcelDownload() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
			  // fnExportExcel(auiGrid, "대리점직원관리", exportProps);
			  fnExportExcel(auiGrid, "위탁판매점직원관리", exportProps);
		}

		function enter(fieldObj) {
			var field = ["s_mem_name", "s_breg_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "mem_no",
				height : 555,
				headerHeight : 40
			};
			var columnLayout = [
				{
					dataField : "mem_no",
					visible : false
				},
				{
					headerText : "아이디",
					dataField : "web_id",
					width : "100",
					minWidth : "65",
					style : "aui-center"
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점구분",
					headerText : "위탁판매점구분",
					dataField : "agency_gubun_name",
					width : "90",
					minWidth : "75",
					style : "aui-center",
				},
				{
					// // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점명",
					headerText : "위탁판매점명",
					dataField : "org_name",
					width : "110",
					minWidth : "65",
					style : "aui-center"
				},
				{
					headerText : "상호(사업자명)",
					dataField : "breg_name",
					width : "130",
					minWidth : "65",
					style : "aui-center"
				},
				{
					headerText : "계약일자",
					dataField : "sale_contract_dt",
					width : "80",
					minWidth : "75",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "직원구분",
					dataField : "agency_rep_yn",
					width : "60",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "이름",
					dataField : "mem_name",
					width : "80",
					minWidth : "75",
					style : "aui-center aui-popup",
				},
				{
					headerText : "핸드폰",
					dataField : "hp_no",
					width : "100",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "이메일",
					dataField : "email",
					width : "150",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "사무실",
					dataField : "tel_no",
					width : "100",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "팩스",
					dataField : "fax_no",
					width : "100",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "주소",
					dataField : "addr",
					width : "220",
					minWidth : "75",
					style : "aui-left"
				},
				{
					headerText : "재직구분",
					dataField : "work_status_name",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "마케팅능력",
					dataField : "sale_ability_hmb",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "직원앱<br/>사용여부",
					dataField : "app_yn",
					width : "65",
					minWidth : "65",
					style : "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'mem_name') {
					var params = {
						"mem_no" : event.item["mem_no"]
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0303p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			$("#auiGrid").resize();
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
<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="200px">
								<col width="70px">
								<col width="80px">
								<col width="70px">
								<col width="100px">
								<col width="55px">
								<col width="150px">
								<col width="55px">
								<col width="100px">
								<col width="100x">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<th>대리점구분</th>--%>
									<th>위탁판매점구분</th>
									<td>
										<select class="form-control" name="s_agency_gubun_cd">
											<option value="">- 전체 -</option>
											<option value="04">건기</option>
											<option value="05">농기</option>
											<option value="06">특수</option>
											<option value="03">협력</option>
										</select>
									</td>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<th>대리점명</th>--%>
									<th>위탁판매점명</th>
									<td>
										<select class="form-control" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgNameList}">
												<option value="${item.org_code }">${item.org_name }</option>
											</c:forEach>
										</select>
									</td>
									<th>직원구분</th>
									<td>
										<select class="form-control" name="s_agency_rep_yn">
											<option value="">- 전체 -</option>
											<option value="Y">대표</option>
											<option value="N">직원</option>
										</select>
									</td>
									<th>재직구분</th>
									<td>
										<select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['WORK_STATUS']}">
												<option value="${list.code_value}" <c:if test="${list.code_value eq '01'}">selected</c:if>>${list.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>상호</th>
									<td>
										<input type="text" class="form-control" name="s_breg_name">
									</td>
									<th>이름</th>
									<td>
										<input type="text" class="form-control" name="s_mem_name">
									</td>
									<th>직원앱사용여부</th>
									<td>
										<select id="s_app_yn" name="s_app_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
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
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
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

					<div id="auiGrid" style="margin-top: 5px;"></div>

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
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
