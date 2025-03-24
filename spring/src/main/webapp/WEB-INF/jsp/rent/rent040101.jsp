<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비현황 > 기종별 센터별 장비현황 > null
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
		var centerCd = [];
		var machineSubTypeMap = ${machineSubTypeMap};
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "70",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "기종", 
					dataField : "machine_type_name", 
					width : "80",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "규격",
					dataField : "machine_sub_type_name",
					width : "80",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "전체",
					dataField : "total",	
					width : "60",
					minWidth : "50", 
					style : "aui-center aui-popup",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
						var sum = 0;
						for (var i = 0; i < centerCd.length; ++i) {
							sum+=$M.toNum(item[centerCd[i]]);
						}
						return sum;
					}
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_sub_type_name",
					style : "aui-center"
				},
				{
					dataField : "total",
					positionField : "total",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center"
				}
			]
			<c:forEach items="${rentCenters}" var="item">
				var obj = {
					headerText : "${item[1]}",
					dataField : "${item[0]}",
					width : "60",
					minWidth : "50",
					style : "aui-center aui-popup"
				}
				var sumObj = {
					dataField : "${item[0]}",
					positionField : "${item[0]}",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
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
				if (event.dataField != "maker_name" && event.dataField != "machine_type_name"
						&& event.value!="") {
					var params = {
						maker_cd : event.item.maker_cd,
						machine_type_cd : event.item.machine_type_cd,
						machine_sub_type_cd : event.item.machine_sub_type_cd,
						mng_org_code : event.dataField != "total" ? event.dataField : ""
					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=440, left=0, top=0";
	 				$M.goNextPage('/rent/rent0401p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}
	
		function goSearch() {
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_type_cd : $M.getValue("s_machine_type_cd"),
				s_machine_sub_type_cd : $M.getValue("s_machine_sub_type_cd"),
				s_sort_key : "vm.maker_cd, vm.machine_name",
				s_sort_method : "asc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.list.length);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "기종별 센터별 장비배치현황", exportProps);
	    }

		// 기종에 따른 규격 세팅
		function fnMachineSubTypeList(val) {
			var machineTypeCd = val;
			// select box 옵션 전체 삭제
			$("#s_machine_sub_type_cd option").remove();
			// select box option 추가
			$("#s_machine_sub_type_cd").append(new Option('- 선택 -', ""));

			// 기종에 따른 규격 list를 세팅
			if (machineSubTypeMap.hasOwnProperty(machineTypeCd)) {
				var machineSubTypeCdList = machineSubTypeMap[machineTypeCd];
				for (item in machineSubTypeCdList) {
					$("#s_machine_sub_type_cd").append(new Option(machineSubTypeCdList[item].code_name, machineSubTypeCdList[item].code));
				}
			}
		}
	</script>
</head>
<body  style="background : #fff;" >
<form id="main_form" name="main_form">

	<div class="content-box">	
		<div class="contents">	
			<div class="search-wrap mt10">				
				<table class="table">
					<colgroup>							
						<col width="50px">
						<col width="75px">
						<col width="80px">
						<col width="250px">
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
											<option value="${item.code_value}">${item.code_name}</option>
										</c:if>
									</c:forEach>
								</select>
							</td>									
							<th>기종/규격</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<select class="form-control" id="s_machine_type_cd" name="s_machine_type_cd" onchange="javascript:fnMachineSubTypeList(this.value);">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
												<c:if test="${item.use_yn eq 'Y'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</div>
									<div class="col-5">
										<select class="form-control" id="s_machine_sub_type_cd" name="s_machine_sub_type_cd" alt="규격">
											<option value="">- 선택 -</option>
										</select>
									</div>
								</div>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();"  >조회</button>
							</td>									
						</tr>						
					</tbody>
				</table>					
			</div>
<!-- /검색영역 -->
<!-- 기종별 센터별 장비배치현황 -->
			<div class="title-wrap mt10">
				<div class="btn-group">
					<div class="left">
						<h4>기종별 센터별 장비배치현황</h4>
					</div>
					<div class="right">
						<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"  ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>
			</div>
<!-- /기종별 센터별 장비배치현황 -->
			<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
			</div>			
		</div>
	</div>
</form>	
</body>
</html>