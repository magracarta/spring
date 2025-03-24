<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비현황 > 모델별 연식별 장비현황 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		var array = [];
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					dataField : "mng_org_code",
					visible : false
				},
				{
					dataField : "own_org_code",
					visible : false
				},
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "70",
					minWidth : "50", 
					style : "aui-center"
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "110",
					minWidth : "50",
					style : "aui-left"
				},
				{
					headerText : "전체",
					dataField : "total",	
					width : "50",
					minWidth : "40",
					style : "aui-center aui-popup",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
						var sum = 0;
						for (var i = 0; i < array.length; ++i) {
							sum+=$M.toNum(item[array[i]]);
						}
						return sum;
					}
				},			
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
					style : "aui-center"
				},
				{
					dataField : "total",
					positionField : "total",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center",
				},
			];
			<c:forEach items="${years}" var="item">
				var obj = {
					headerText : "${item}"+"년식",
					dataField : "${item}",
					width : "80",
					minWidth : "70",
					style : "aui-center aui-popup"
				}
				var sumObj = {
					dataField : "${item}",
					positionField : "${item}",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
				}
				array.push(${item});
				columnLayout.push(obj);
				footerColumnLayout.push(sumObj);
			</c:forEach>
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.resize(auiGrid);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField != "maker_name" && event.dataField != "machine_name"
						&& event.value!="") {
					var params = {
						type : "year",
						maker_cd : event.item.maker_cd,
						machine_plant_seq : event.item.machine_plant_seq,
						mng_org_code : event.item.mng_org_code,
						own_org_code : event.item.own_org_code,
						made_dt : event.dataField != "total" ? event.dataField : ""
					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=440, left=0, top=0";
	 				$M.goNextPage('/rent/rent0401p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}
		
		function goSearch() {
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_own_org_code : $M.getValue("s_own_org_code"),
				s_sort_key : "vm.maker_cd, vm.machine_name", // 이건 무시됨
				s_sort_method : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						if (result.list && result.list.length > 0) {
							for (var i = 0; i < result.list.length; ++i) {
								result.list[i]["mng_org_code"] = $M.getValue("s_mng_org_code");
								result.list[i]["own_org_code"] = $M.getValue("s_own_org_code");
							} 
						}
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "모델별 연식별 장비현황", exportProps);
	    }
	
	
	</script>
</head>
<body style="background : #fff;"  >
<form id="main_form" name="main_form">
	<div class="content-box">
		<div class="contents">			
			<div class="search-wrap mt10">				
				<table class="table">
					<colgroup>							
						<col width="50px">
						<col width="75px">
						<col width="40px">
						<col width="160px">
						<col width="65px">
						<col width="75px">
						<col width="65px">
						<col width="75px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
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
							<th>관리센터</th>
							<td>
								<select class="form-control" name="s_mng_org_code">
									<option value="">- 전체 -</option>
									<c:forEach items="${orgCenterList}" var="item">
										<option value="${item.org_code}">${item.org_name}</option>
									</c:forEach>
								</select>
							</td>
							<th>소유센터</th>
							<td>
								<select class="form-control" name="s_own_org_code">
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
<!-- 모델별 연식별 장비현황 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left">
						<h4>모델별 연식별 장비현황</h4>
					</div>
					<div class="right">
						<button type="button" class="btn btn-default"  onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>
			</div>
<!-- /모델별 연식별 장비현황 -->
			<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>	
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