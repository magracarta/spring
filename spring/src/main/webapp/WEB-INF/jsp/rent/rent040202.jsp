<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈매출현황 > 모델별 연식별 매출현황 > null
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
		var dateList = ${dateList};
		
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
			var qtyArray = [];
			var amtArray = [];		
			
			var gridPros = {
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
					dataField : "maker_cd", 
					visible : false,
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "10%", 
					style : "aui-center"
				},
				{
					headerText : "전체",
					children: [
						{
							headerText : "매출액",
							dataField : "total_amt",	
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center aui-popup",
							expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
								var sum = 0;
								for (var i = 0; i < amtArray.length; ++i) {
									sum+=$M.toNum(item[amtArray[i]]);
								}
								return sum;
							}
						},
						{
							headerText : "대수",
							dataField : "total_qty",	
							width : "6%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center aui-popup",
							labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
								var sum = 0;
								for (var i = 0; i < qtyArray.length; ++i) {
									sum+=$M.toNum(item[qtyArray[i]]);
								}
								return sum;
							}
						},
					]
				},			
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
					dataField : "total_amt",
					positionField : "total_amt",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center",
				},
				{
					dataField : "total_qty",
					positionField : "total_qty",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center",
				},
			];

			for (var i = 0; i < dateList.length; ++i) {
				var obj = {
					headerText : dateList[i].year_col + "년식",
					children: [
						{
							headerText : "매출액",
							dataField : dateList[i].year_field + "_amt",
							width : "7%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"									
								};
							},
						},
						{
							headerText : "대수",
							dataField : dateList[i].year_field + "_qty",
							width : "7%", 
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(value != 0) {
									return "aui-popup"									
								};
							},
						},
					]
					
				};
				var sumObj1 = {
					dataField : dateList[i].year_field + "_amt",
					positionField : dateList[i].year_field + "_amt",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
				};
				var sumObj2 = {
					dataField : dateList[i].year_field + "_qty",
					positionField : dateList[i].year_field + "_qty",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
				};
				columnLayout.push(obj);
				footerColumnLayout.push(sumObj1);
				footerColumnLayout.push(sumObj2);
				
				amtArray.push(dateList[i].year_field + "_amt");
				qtyArray.push(dateList[i].year_field + "_qty");
			}
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.resize(auiGrid);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				if(event.value == 0) {
					return;
				};
				var madeYear = event.dataField.split("_");
				console.log(madeYear);
				if (event.dataField.indexOf("_amt") != -1) {
					// 렌탈매출현황 상세 팝업 호출
					
					var params = {
						made_year 			: event.dataField != "total_amt" ? madeYear[1] : "",
						maker_cd 			: event.item.maker_cd,
						machine_name 		: event.item.machine_name,
						mng_org_code	 	: $M.getValue("s_mng_org_code"),
						"s_sort_key" 		: "t5.inout_dt desc, t1.rental_doc_no",
						"s_sort_method" 	: "asc",
					};
					
					var popupOption = "";
	 				$M.goNextPage('/rent/rent0402p01', $M.toGetParam(params), {popupStatus : popupOption});
				} else if (event.dataField.indexOf("_qty") != -1) {
					var params = {
						mode 			  : "STAT",
						maker_cd 		  : event.item.maker_cd,
						machine_plant_seq : event.item.machine_plant_seq,
						mng_org_code 	  : $M.getValue("s_mng_org_code"),
						made_dt 		  : event.dataField != "total_qty" ? madeYear[1] : "",
					};
					// 렌탈장비현황상세 팝업
					var popupOption = "";
	 				$M.goNextPage('/rent/rent0401p01', $M.toGetParam(params), {popupStatus : popupOption});
				};
			}); 
		}
		
		function goSearch() {
			var param = {
				s_start_dt 		: $M.getValue("s_start_dt"),
				s_end_dt 		: $M.getValue("s_end_dt"),
				s_maker_cd 		: $M.getValue("s_maker_cd"),
				s_machine_name 	: $M.getValue("s_machine_name"),
				s_mng_org_code 	: $M.getValue("s_mng_org_code"),
				s_sort_key : "maker_sort_no, machine_name",
				s_sort_method : "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						console.log(result.dateList);
						if($M.nvl(result.dateList, "") != "") {
							dateList = result.dateList;							
						}
						destroyGrid();
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	
		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		};
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "모델별 연식별 장비현황", exportProps);
	    }

	
	</script>
</head>
<body style="background : #fff;" >
<form id="main_form" name="main_form">
	<div class="layout-box">
		<div class="content-wrap">				
<!-- 검색영역 -->					
			<div class="search-wrap mt10">				
				<table class="table">
					<colgroup>		
						<col width="70px">
						<col width="290px">						
						<col width="50px">
						<col width="75px">
						<col width="45px">
						<col width="130px">
						<col width="45px">
						<col width="110px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt }" onchange="goSearch();">
										</div>
									</div>
									<div class="col width16px text-center">~</div>
									<div class="col width110px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt }" onchange="goSearch();">
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
							<th>모델</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<div class="input-group">
											<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
					                     		<jsp:param name="required_field" value=""/>
					                     	</jsp:include>						
										</div>
									</div>
								</div>
							</td>	
							<th>센터</th>
							<td>
								<select class="form-control" name="s_mng_org_code" id="s_mng_org_code" onchange="goSearch();">
									<option value="">- 전체 -</option>
									<c:forEach items="${orgCenterList}" var="item">
										<option value="${item.org_code}">${item.org_name}</option>
									</c:forEach>
								</select>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();" >조회</button>
							</td>				
						</tr>						
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
<!-- 모델별 연식별 매출현황 -->
			<div class="title-wrap mt10">
				<h4>모델별 연식별 매출현황</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /모델별 연식별 매출현황 -->
			<div id="auiGrid" style="margin-top: 5px; height: 545px;"></div>	
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>				
			</div>		
		</div>
	</div>		
</form>	
</body>
</html>