<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈매출현황 > 기종별 센터별 매출현황 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-11 14:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	var centerCd = [];
	
	$(document).ready(function() {
		fnInitDate();
		// AUIGrid 생성
		createAUIGrid();
	});

	// 검색 시작일자 세팅 현재날짜의 1년 전
	function fnInitDate() {
		/* var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addYears($M.toDate(now), -1));
		$M.setValue("s_end_dt", now); */
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			showFooter : true,
			footerPosition : "top",
		};
		var columnLayout = [
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				width : "7%", 
				style : "aui-center"
			},
			{ 
				headerText : "메이커코드", 
				dataField : "maker_cd", 
				width : "7%", 
				style : "aui-center",
				visible : false,
			},
			{
				headerText : "기종", 
				dataField : "machine_type_name", 
				width : "7%", 
				style : "aui-center"
			},
			{	
				dataField : "machine_type_cd", 
				visible : false,
			},
			{
				headerText : "전체",
				dataField : "total",	
				width : "6%", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-popup",
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
					var sum = 0;
					for (var i = 0; i < centerCd.length; ++i) {
					console.log($M.toNum(item[centerCd[i]]));
						sum += $M.toNum(item[centerCd[i]]);
						
					}
					return sum;
				}
			}
		];
		
		// 푸터레이아웃
		var footerColumnLayout = [ 
			{
				labelText : "합계",
				positionField : "maker_name",
				colSpan : 3,
				style : "aui-center"
			},
			{
				dataField : "total",
				positionField : "total",
				formatString : "#,##0",
				operation : "SUM",
				style : "aui-right"
			}
		]
		// 센터 목록 호출
		<c:forEach items="${rentCenters}" var="item">
			var obj = {
				headerText : "${item[1]}",
				dataField : "${item[0]}",
				dataType : "numeric",
				formatString : "#,##0",
				width : "6%",
				style : "aui-right aui-popup"
			}
			var sumObj = {
				dataField : "${item[0]}",
				positionField : "${item[0]}",
				formatString : "#,##0",
				operation : "SUM",
				style : "aui-right aui-footer",	
			}
			centerCd.push(${item[0]});
			columnLayout.push(obj);
			footerColumnLayout.push(sumObj);
		</c:forEach>

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		AUIGrid.resize(auiGrid);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if (event.dataField != "maker_name" && event.dataField != "machine_type_name" && event.value != "") {
				var params = {
					maker_cd 			: event.item.maker_cd,
					machine_type_cd 	: event.item.machine_type_cd,
					start_dt 			: $M.getValue("s_start_dt"),
					end_dt 				: $M.getValue("s_end_dt"),
					mng_org_code		: event.dataField != "total" ? event.dataField : "",
					"s_sort_key" 		: "t5.inout_dt desc, t1.rental_doc_no",
					"s_sort_method" 	: "asc",
				};
				
				var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=440, left=0, top=0";
 				$M.goNextPage('/rent/rent0402p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});
	}

	function goSearch() {
		var param = {
			s_start_dt 		  : $M.getValue("s_start_dt"),
			s_end_dt   		  : $M.getValue("s_end_dt"),
			s_maker_cd 		  : $M.getValue("s_maker_cd"),
			s_machine_type_cd : $M.getValue("s_machine_type_cd"),
			s_sort_key 		  : "",
			s_sort_method 	  : ""
		};
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}
		);
	}

	function fnDownloadExcel() {
		var exportProps = {};
		fnExportExcel(auiGrid, "기종_센터별 매출현황", exportProps);
    }

		
	
	
	</script>
</head>
<body  style="background : #fff;"  >
<form id="main_form" name="main_form">

	<div class="layout-box">
		<div class="content-wrap">				
<!-- 검색영역 -->					
			<div class="search-wrap mt10">				
				<table class="table">
					<colgroup>		
						<col width="70px">
						<col width="280px">						
						<col width="50px">
						<col width="75px">
						<col width="45px">
						<col width="130px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일"  value="${searchDtMap.s_start_dt }" onchange="goSearch();">
										</div>
									</div>
									<div class="col width16px text-center">~</div>
									<div class="col width110px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일"  value="${searchDtMap.s_end_dt }" onchange="goSearch();">
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
							<th>메이커</th>
							<td>
								<select class="form-control" id="s_maker_cd" name="s_maker_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MAKER']}" var="item">
										<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
											<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
										</c:if>
									</c:forEach>
								</select>
							</td>									
							<th>기종</th>
							<td>
								<select class="form-control" id="s_machine_type_cd" name="s_machine_type_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
										<c:if test="${item.use_yn eq 'Y'}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:if>
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
<!-- 기종별 센터별 매출현황 -->
			<div class="title-wrap mt10">
				<h4>기종별 센터별 매출현황</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /기종별 센터별 매출현황 -->
			<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>			
		</div>
	</div>		

</form>	
</body>
</html>