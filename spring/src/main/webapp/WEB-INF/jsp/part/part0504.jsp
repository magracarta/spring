<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > CYCLE CHECK > null > null
-- 작성자 : 박준영.
-- 최초 작성일 : 2020-08-04 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;

	$(document).ready(function(){
		createAUIGrid();
	
		$("#btnHide").children().eq(0).attr('id','btnNewContract');
	});
	
	function goSearch() {
				
		if($M.getValue("s_warehouse_cd") == ""){	
			alert("센터를 선택해 주세요");
			return;
		}
		
		var param = {
			s_check_year   : $M.getValue("s_check_year"),
			s_warehouse_cd : $M.getValue("s_warehouse_cd"),
			s_year_mon 	   : $M.dateFormat($M.toDate('${inputParam.s_current_dt}'), 'yyyyMM'),
			s_sort_key     : "check_mon",
			s_sort_method  : "desc"
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

	function fnDownloadExcel() {
		  // 엑셀 내보내기 속성
		  var exportProps = {
		         // 제외항목
		         //exceptColumnFields : ["removeBtn"]
		  };
		  fnExportExcel(auiGrid, "CYCLE_CHECK 이력", exportProps);
	}

	function goNew() {
		
		if($M.getValue("s_warehouse_cd") == ""){	
			alert("센터를 선택해 주세요");
			return;
		}
		else {
			
			//이번달이 시작일인 품의서가 등록됬는지 확인하기
			var param = {	
					"s_warehouse_cd" 	 : $M.getValue("s_warehouse_cd"),
					"s_year_mon" 	 	 : $M.dateFormat($M.toDate('${inputParam.s_current_dt}'), 'yyyyMM'),
					"s_warehouse_name"   : 	$("#s_warehouse_cd option:checked").text()
			};	
			
			$M.goNextPageAjax(this_page + "/checkCycleCheckStartThisMonth", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
	
						//이번달이 시작일인 품의서가 있는경우
						if(result.result_count > 0){						
							alert("조사기간이 당월 시작인  품의서가 있습니다.\n다시 검색해주세요.");							
							return;
						}	
						else{								
							$M.goNextPage("/part/part050401",$M.toGetParam(param));						
						}
					}
			});				

		}
	}

	function createAUIGrid() {

		var gridPros = {
			rowIdField : "_$uid",
			wrapSelectionMove : false,
			showRowNumColumn : false,
			editable : false,
			showFooter : true,
			footerPosition : "top"
		};
		
		var columnLayout = [
			{
				headerText : "조회년월",
				dataField : "check_mon",
				width : "10%",
				style : "aui-center",
				labelFunction : function(value, columnValues, footerValues) {
					if(footerValues == ""){
						return ""; 
					}
					else{
						return footerValues.substring(0,4) + '-' + footerValues.substring(4); 
					}
				}
			},
			{
				headerText : "품의번호",
				dataField : "cycle_check_no",
			 	width : "10%",
				style : "aui-center aui-popup"
			},
			{
				headerText : "조사기간",
				dataField : "cycle_term_dt",
				width : "10%",
				style : "aui-center"
			},
			{
				headerText : "조사항목수",
				dataField : "check_total_cnt",
				width : "10%",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "과부족발생수",
				dataField : "diff_total_cnt",
				width : "10%",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "조사총금액",
				dataField : "check_total_amt",
				width : "10%",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "조사차이금액",
				dataField : "diff_total_amt",
				width : "10%",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "백분율",
				dataField : "check_rate",
				width : "6%",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0.##"
			},
			{
				dataField : "appr_proc_status_cd",
				visible : false
			},
			{
				headerText : "진행상태",
				dataField : "appr_proc_status_name",
				width : "8%",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
				     return (item.appr_proc_status_cd == '05') ? '결재완료' : value; 
				},
				style : "aui-center"
			},
			{
				headerText : "전산상태",
				dataField : "part_adjust_appr_status_name",
				width : "8%",
				style : "aui-center"
			},
			{
				headerText : "반영일자",
				dataField : "adjust_dt",
				dataType : "date",   
				formatString : "yyyy-mm-dd",
				style : "aui-center"
			},
			{
				dataField : "period_cycle_term_dt",
				visible : false
			},
			{
				dataField : "sum_check_total_cnt",
				visible : false
			},
			{
				dataField : "sum_diff_total_cnt",
				visible : false
			},
			{
				dataField : "sum_check_total_amt",
				visible : false
			},
			{
				dataField : "sum_diff_total_amt",
				visible : false
			},
			{
				dataField : "avg_persent",
				visible : false
			}
		];
		
		// 푸터 설정
		var footerLayout = [
			{
				labelText : "총 결산",
				positionField : "cycle_check_no",
				style: "aui-center aui-footer"
			},
			{
				dataField : "period_cycle_term_dt",
				positionField : "cycle_term_dt",
				style: "aui-center aui-footer",
				// 파라메터 : columnValues : dataField 에 해당되는 모든 칼럼의 값들(Array)
				labelFunction : function(value, columnValues, footerValues) {
					if(columnValues == ""){
						return ""; 
					}
					else{
						return columnValues[0]; 
					}
				}
			},
			{
				dataField : "sum_check_total_cnt",
				positionField : "check_total_cnt",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					if(columnValues==""){
						return ""; 
					}
					else{
						return Math.max.apply(this, columnValues); 
					}					
				}
			},
			{
				dataField : "sum_diff_total_cnt",
				positionField : "diff_total_cnt",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					if(columnValues==""){
						return ""; 
					}
					else{
						return Math.max.apply(this, columnValues); 
					}
				}
			},
			{
				dataField : "sum_check_total_amt",
				positionField : "check_total_amt",
				formatString : "#,##0",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					if(columnValues==""){
						return ""; 
					}
					else{
						return Math.max.apply(this, columnValues); 
					}
				}
			},		
			{
				dataField : "sum_diff_total_amt",
				positionField : "diff_total_amt",
				formatString : "#,##0",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					if(columnValues==""){
						return ""; 
					}
					else{
						return Math.max.apply(this, columnValues); 
					}
				}					
			},				
			{
				dataField : "avg_persent",
				positionField : "check_rate",
				formatString : "#,##0.##",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					if(columnValues==""){
						return ""; 
					}
					else{
						return Math.max.apply(this, columnValues); 
					}
				}
			},		
		];
		

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGrid, footerLayout);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "cycle_check_no") {
				
				var param = {
						"cycle_check_no" : event.item.cycle_check_no,	
						"warehouse_cd" 	 : $M.getValue("s_warehouse_cd")
				};	
			
				var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1550, height=680, left=0, top=0";
				$M.goNextPage('/part/part0504p01', $M.toGetParam(param), {popupStatus : poppupOption});
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
	<!-- 기본 -->					
				<div class="search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="40px">
							<col width="90px">
							<col width="65px">
							<col width="90px">								
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>부서</th>
								<td>								
									<!-- 로그인 계정이 센터가 아닌경우, 창고목록 콤보그리드 선택가능 -->
									<!-- 로그인 계정이 센터인경우 해당부서코드 Set -->
									<c:choose>
										<c:when test="${page.fnc.F00441_001 eq 'Y'}">
											<select class="form-control" id="s_warehouse_cd" name="s_warehouse_cd">
												<option value="">- 전체 - </option>
												<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
													<option value="${item.code_value}">${item.code_name}</option>										
												</c:forEach>
											</select>
										</c:when>
										<c:when test="${page.fnc.F00441_002 eq 'Y'}">
											<select class="form-control" id="s_warehouse_cd" name="s_warehouse_cd">																				
												<option value="${SecureUser.org_code}">${SecureUser.org_name}</option>																					
											</select>
										</c:when>
									</c:choose>								
								</td>
								<th>조회년도</th>
								<td>
									<select class="form-control" name="s_check_year" id="s_check_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+5}" step="1">
												<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
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
	<!-- /기본 -->	
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
				<div id="auiGrid" class="mt10" style="margin-top: 5px; width: 100%;height: 400px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt" >0</strong>건
					</div>
					<div class="right" id="btnHide"  >
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
	<!-- 상태별 설명 -->
				<div class="alert alert-secondary mt10">
					<div class="title">
						<i class="material-iconserror font-16"></i>
							상태별 설명
					</div>
					<div class="row">
						<ul class="col-12">
							<li>반영완료 : 과부족 발생수가 0이거나, 차이 수량은 발생했지만 선 조정이 완료된 건</li>
							<li>반려 : 재고조정요청현황에서 반려된 건</li>
							<li>대기중 : 재고조정요청현황에서 결재중인 건</li>									
						</ul>
					</div>						
				</div>
	<!-- /상태별 설명 -->
			</div>
		</div>	
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>