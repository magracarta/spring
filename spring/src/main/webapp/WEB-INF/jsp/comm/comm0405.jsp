<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스관련코드> 센터별 출장비 설정 관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-03-20 09:00:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});	
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				rowIdField : "sale_area_code", 
				rowIdTrustMode : true,
				showStateColumn : true,
				editable : true,
				fillColumnSizeMode : false,
				enableFilter : true
			};
			var columnLayout = [
				{ 
					dataField : "sale_area_code", 
					visible : false,
					editable : false
				},
				{ 
					dataField : "svc_travel_expense_seq", 
					visible : false,
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "0" : value;
					}
				},
				{ 
					headerText : "센터", 
					dataField : "center_org_name", 
					style : "aui-center",
					width : "10%", 
					filter : {
						showIcon : true
					},
					editable : false
				},
				{ 
					dataField : "center_org_code", 
					visible : false,
					editable : false
				},
				{
					headerText : "지역", 
					dataField : "path_sale_area_name", 
					width : "20%", 
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var area = value.split(" > ")
						return area[area.length-1];
					}
				},
				{ 
					dataField : "sale_area_code",
					visible : false, 
					editable : false
				},
				{
					headerText : "왕복거리(km)",
					children : [
						{
							dataField : "distance_min",
							headerText : "최소",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							formatString : "#,##0",
							style : "aui-center aui-editable",
						}, 
						{
							dataField : "distance_max",
							headerText : "최대",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							style : "aui-center aui-editable",
						}
					]
				}, 
				{
					headerText : "왕복이동시간(분)",
					children : [
						{
							dataField : "coast_min",
							headerText : "최소",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							style : "aui-center aui-editable",
						}, 
						{
							dataField : "coast_max",
							headerText : "최대",
							width : "8%",
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							style : "aui-center aui-editable",
						}
					]
				}, 
				{
					headerText : "왕복택시비(원)",
					children : [
						{
							dataField : "taxi_fare_min",
							headerText : "최소",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							style : "aui-center aui-editable",
						}, 
						{
							dataField : "taxi_fare_max",
							headerText : "최대",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
								validator : function(oldValue, newValue, rowItem) {  // 에디팅 유효성 검사
									function fnCheckDate(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
										// 리턴값은 Object 이며 validate 의 값이 true 라면 패스, false 라면 message 를 띄움
										return {
											"validate" : isValidDate(newValue),
											"message" : "yyyymmdd 형식으로 입력해주세요."
										};
									}
								},
							},
							style : "aui-center aui-editable",
						}
					]
				}, 
				{
					headerText : "YK출장비(원)",
					children : [
						{
							dataField : "travel_expense_min",
							headerText : "최소",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true, // 숫자만
							},
							style : "aui-center aui-editable",
						}, 
						{
							dataField : "travel_expense_max",
							headerText : "최대",
							width : "8%", 
							dataType : "numeric",
							editRenderer : {
								type : "InputEditRenderer",

							},
							style : "aui-center aui-editable",
						}
					]
				}, 
				{
					headerText : "작성일", 
					dataField : "reg_date", 
					width : "10%",
					dataType : "date",
					formatString : "yyyy-mm-dd", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "처리자", 
					dataField : "reg_mem_name", 
					editable : false,
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
		
		function goSearch() {
			var param = {
				s_center_org_code 	: $M.getValue("s_center_org_code"),
				s_area_do 			: $M.getValue("s_area_do"),
				s_sort_key 			: "c.org_kor_name",
				s_sort_method 		: "asc",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function enter(fieldObj) {
			var field = [ "s_area_do" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}

		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			// 수정된 행 아이템들
			var array = AUIGrid.getEditedRowItems("#auiGrid");
			console.log(array);

			var sale_area_code = [];	
			var seq = [];	
			var center_org_code = [];
			var path_sale_area_name = [];
			var distance_min = [];	
			var distance_max = [];	
			var coast_min = [];	
			var coast_max = [];	
			var taxi_fare_min = [];
			var taxi_fare_max = [];
			var travel_expense_min = [];
			var travel_expense_max = [];

			for (var i = 0; i < array.length; ++i) {
				if(array[i].svc_travel_expense_seq == "") {
					seq.push("0");							
				} else {
					seq.push(array[i].svc_travel_expense_seq);			
				};
				
				if(checkRangeNumValue(array[i].distance_min, array[i].distance_max) == false) {
					alert(array[i].center_org_name + " " + array[i].path_sale_area_name + "의 왕복거리 값을 확인하세요.");	
					return;
				};
				console.log(array[i].coast_min + " / " + array[i].coast_max);
				if(checkRangeNumValue(array[i].coast_min, array[i].coast_max) == false) {
					alert(array[i].center_org_name + " " + array[i].path_sale_area_name + "의 왕복이동시간 값을 확인하세요.");		
					return;
				};
				
				if(checkRangeNumValue(array[i].taxi_fare_min, array[i].taxi_fare_max) == false) {
					alert(array[i].center_org_name + " " + array[i].path_sale_area_name + "의 왕복택시비 값을 확인하세요.");		
					return;
				};
				
				if(checkRangeNumValue(array[i].travel_expense_min, array[i].travel_expense_max) == false) {
					alert(array[i].center_org_name + " " + array[i].path_sale_area_name + "의 YK출장비 값을 확인하세요.");		
					return;
				};
				
				sale_area_code.push(array[i].sale_area_code);
				center_org_code.push(array[i].center_org_code);
				var pathSaleAreaNameSplit = array[i].path_sale_area_name.split(" > ");
				path_sale_area_name.push(pathSaleAreaNameSplit[pathSaleAreaNameSplit.length-1]);
				distance_min.push(array[i].distance_min);
				distance_max.push(array[i].distance_max);
				coast_min.push(array[i].coast_min);
				coast_max.push(array[i].coast_max);
				taxi_fare_min.push(array[i].taxi_fare_min);
				taxi_fare_max.push(array[i].taxi_fare_max);
				travel_expense_min.push(array[i].travel_expense_min);
				travel_expense_max.push(array[i].travel_expense_max);
			}		

			var option = {
				isEmpty : true
			};
			
			var param = {
				"sale_area_code_str" 			:	$M.getArrStr(sale_area_code),
				"center_org_code_str" 			:	$M.getArrStr(center_org_code),
				"svc_travel_expense_seq_str" 	:	$M.getArrStr(seq),
				"area_name_str" 				:	$M.getArrStr(path_sale_area_name, option),
				"distance_min_str" 				:	$M.getArrStr(distance_min, option),
				"distance_max_str" 				:	$M.getArrStr(distance_max, option),
				"coast_min_str" 				:	$M.getArrStr(coast_min, option),
				"coast_max_str" 				:	$M.getArrStr(coast_max, option),
				"taxi_fare_min_str" 			:	$M.getArrStr(taxi_fare_min, option),
				"taxi_fare_max_str" 			:	$M.getArrStr(taxi_fare_max, option),
				"travel_expense_min_str" 		:	$M.getArrStr(travel_expense_min, option),
				"travel_expense_max_str" 		:	$M.getArrStr(travel_expense_max, option)
			}

			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : "post"},
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}

		function checkRangeNumValue(startVal, endVal) {
			var stValue = $M.nvl(startVal, 0);
			var edValue = $M.nvl(endVal, 0);
			var result = stValue <= edValue;

			return result;
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
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
					</div>
	<!-- /메인 타이틀 -->
					<div class="contents">
	<!-- 검색영역 -->					
						<div class="search-wrap">				
							<table class="table table-fixed">
								<colgroup>
									<col width="40px">
									<col width="80px">								
									<col width="40px">
									<col width="120px">		
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>센터</th>
										<td>
											<select class="form-control" id="s_center_org_code" name="s_center_org_code">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${orgCenterList}">
													<option value="${item.org_code}">${item.org_name}</option>
												</c:forEach>
											</select>
										</td>	
										<th>지역</th>
										<td>
											<input type="text" class="form-control" id="s_area_do" name="s_area_do">
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
									<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include> --%>
								</div>
							</div>
						</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->	
						<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
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
	</form>
</body>
</html>