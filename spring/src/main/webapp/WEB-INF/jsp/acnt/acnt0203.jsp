<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 받을어음관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
			goInitSearch();
		});
		
		// 초기화면 화면 검색
		function goInitSearch() {
			$M.setValue("s_year", $M.getCurrentDate("yyyy"));
		}
	
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "받을어음관리");
		}
	
		function goNew() {
			$M.goNextPage("/acnt/acnt020301");
		}
	
		function goSearch() {
			var param = {
				"s_year" 				 : $M.getValue("s_year"),
				"s_billin_type_cd" 		 : $M.getValue("s_billin_type_cd"),
				"s_billin_proc_type_cd"  : $M.getValue("s_billin_proc_type_cd"),
				"s_sort_key" 			 : "deposit_dt desc, billin_no",
				"s_sort_method" 		 : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				rowIdField : "billin_no",
				showRowNumColum : true,
				showFooter : true,
				footerPosition : "top",
			};
	
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "billin_no",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var billinNo = value;
				    	return billinNo.substring(4, 11);; 
					}
				},
				{
					headerText : "어음번호",
					dataField : "bill_no",
					width : "180",
					minWidth : "180",
					style : "aui-center aui-popup"
				},
				{
					headerText : "입금일자",
					dataField : "deposit_dt",
					dataType : "date",   
					width : "90",
					minWidth : "90",
					style : "aui-center",					
					formatString : "yy-mm-dd",
				},
				{
					dataField : "deposit_cust_no",
					visible : false
				},
				{
					headerText : "입금처",
					dataField : "deposit_cust_name",
					width : "150",
					minWidth : "150",
					style : "aui-center"
				},
				{
					headerText : "만기일자",
					dataField : "end_dt",
					dataType : "date",   
					width : "90",
					minWidth : "90",
					style : "aui-center",					
					formatString : "yy-mm-dd",
				},
				{
					dataField : "billin_type_cd",
					visible : false
				},
				{
					headerText : "어음종류",
					dataField : "billin_type_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
					headerText : "금액",
					dataField : "amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right"
				},
				{
					headerText : "지급장소",
					dataField : "give_place",
					width : "200",
					minWidth : "200",
					style : "aui-left"
				},
				{
					headerText : "발행처",
					dataField : "corp_cust_name",
					width : "150",
					minWidth : "150",
					style : "aui-center"
				},
				{
					headerText : "처리구분",
					dataField : "billin_proc_type_name",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					dataField : "billin_proc_type_cd",
					visible : false
				},
				{
					headerText : "처리일자",
					dataField : "proc_dt",
					dataType : "date",   
					width : "90",
					minWidth : "90",
					style : "aui-center",					
					formatString : "yy-mm-dd",
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "billin_no",
					style : "aui-right aui-footer",
					colSpan : 7
				},
				{
					dataField: "amt",
					positionField: "amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "bill_no") {
					var param = {
							"billin_no" : event.item["billin_no"]
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=500, left=0, top=0";
					$M.goNextPage('/acnt/acnt0203p01', $M.toGetParam(param), {popupStatus : poppupOption});
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
				<!-- 검색영역 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="60px">
							<col width="80px">
							<col width="65px">
							<col width="100px">
							<col width="65px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>관리년도</th>
							<td>
								<select class="form-control" id="s_year" name="s_year">
									<c:forEach var="i" begin="${inputParam.s_current_year - 5}" end="${inputParam.s_current_year + 5}" step="1">
										<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
									</c:forEach>
								</select>
							</td>
							<th>어음종류</th>
							<td>
								<select class="form-control" id="s_billin_type_cd" name="s_billin_type_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['BILLIN_TYPE']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th>처리구분</th>
							<td>
								<select class="form-control" id="s_billin_proc_type_cd" name="s_billin_proc_type_cd">
									<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['BILLIN_PROC_TYPE']}" var="item">
									<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
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
				<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- /조회결과 -->
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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