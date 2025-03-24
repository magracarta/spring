<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > 수주참조
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));

			// 매출처리 수주참조의 경우 확정으로 비활성화
			// 3차 신화면. 확정상태 삭제되어 작성중 상태로 변경됨.
			$M.setValue("s_part_sale_status_cd", "0");
			$("#s_part_sale_status_cd").prop("disabled", true);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "part_sale_no",
				// No. 제거
				showRowNumColumn: true,
				editable : false
			};
			var columnLayout = [
				{
					headerText : "수주일자",
					dataField : "sale_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "14%",
					style : "aui-center"
				},
				{
					headerText : "번호",
					dataField : "part_sale_no",
					width : "12%",
					style : "aui-center"
				},
				{
					headerText : "수주처",
					dataField : "cust_name",
					width : "15%",
					style : "aui-center",
				},
				{
					headerText : "적요",
					dataField : "desc_text",
					width : "37%",
					style : "aui-left",
				},
				{
					headerText : "금액",
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%",
					style : "aui-right",
				},
				{
					headerText : "상태",
					dataField : "part_sale_status_name",
					width : "10%",
					style : "aui-cetner",
				},
				{
					dataField : "part_sale_status_cd",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				}
			});
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}


		//조회
		function goSearch() {
			var param = {
					"s_sort_key" : "sale_dt desc, part_sale_no",
					"s_sort_method" : "desc",
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_part_sale_status_cd" : $M.getValue("s_part_sale_status_cd"),
					"s_part_sale_type_ca" : $M.getValue("s_part_sale_type_ca"),
					"s_refer_yn" : "${inputParam.s_refer_yn}",
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}

		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
      	  <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>수주현황</h4>
			</div>
<!-- 검색영역 -->
			<div class="search-wrap mt5">
				<table class="table table-fixed">
					<colgroup>
						<col width="65px">
						<col width="260px">
						<col width="65px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="65px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>수주일자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="">
										</div>
									</div>
									<div class="col-auto text-center">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
										</div>
									</div>
								</div>
							</td>
							<th>수주처명</th>
							<td>
								<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
							</td>
							<%-- <th>진행구분</th>
							<td>
								<select class="form-control" id="s_part_sale_status_cd" name="s_part_sale_status_cd">
									<option value="">- 전체 -</option>
									<c:forEach var="item" items="${codeMap['PART_SALE_STATUS']}">
					 				<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td> --%>
							<c:choose>
								<c:when test="${inputParam.s_refer_yn eq 'Y'}">
									<th>진행구분</th>
									<td>
										<input class="form-control" type="text" value="${codeMap['PART_SALE_STATUS'][0].code_name} 이상" readonly="readonly">
									</td>
								</c:when>
								<c:otherwise>
									<th>진행구분</th>
									<td>
									<select class="form-control" id="s_part_sale_status_cd" name="s_part_sale_status_cd" disabled="disabled">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['PART_SALE_STATUS']}">
						 					<option value="${item.code_value}" ${inputParam.s_job_status_cd eq item.code_value ? 'selected' : ''}>${item.code_name}</option>
										</c:forEach>
									</select>
									</td>
								</c:otherwise>
							</c:choose>
							<th>처리구분</th>
							<td>
								<select class="form-control" id="s_part_sale_type_ca" name="s_part_sale_type_ca">
					 				<option value="C">고객</option>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
					 				<%--<option value="A">대리점</option>--%>
					 				<option value="A">위탁판매점</option>
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
<!-- 폼테이블 -->
			<div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /폼테이블-->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
