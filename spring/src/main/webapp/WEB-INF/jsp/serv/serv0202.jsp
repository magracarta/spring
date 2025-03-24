<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 장비 입/출고 > 출하의뢰 부품현황 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-19 15:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	
	$(document).ready(function() {
		fnInitDate();
		// AUIGrid 생성
		createAUIGrid();
	});
	
	// 시작일자 세팅 현재날짜의 1달 전
	function fnInitDate() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
	}
	
	// 출하의뢰 부품현황 목록 조회
	function goSearch() {
		if ($M.validation(document.main_form) == false) {
			return;
		};
		
		if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
			return;
		}; 
		
		var param = {
			s_start_dt 			: $M.getValue("s_start_dt"),
			s_end_dt 			: $M.getValue("s_end_dt"),
			s_out_org_code 		: $M.getValue("s_out_org_code"),
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
	
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			rowStyleFunction : function(rowIndex, item) {
				var style = "";
				if ((item.current_stock - item.qty) < 1 && item.out_org_name != null) {
					style = "aui-status-reject-or-urgent";
				}
				return style;
			}
		};
		var columnLayout = [
			{ 
				headerText : "출하예정센터", 
				dataField : "out_org_name", 
				style : "aui-center",
				width : "100",
				minWidth : "100",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					return value == "" || value == null ? "기타센터" : value;
				},
			},
			{
				headerText : "부품번호", 
				dataField : "part_no", 
				style : "aui-center",
				width : "120",
				minWidth : "100",
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name", 
				style : "aui-left",
				width : "250",
				minWidth : "100",
			},
			{ 
				headerText : "출하예정수량", 
				dataField : "qty", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				width : "100",
				minWidth : "100",
			},
			{ 
				headerText : "차이수량", 
				dataField : "qty_term", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					var result = item.current_stock - item.qty;
					return result;
				},
				width : "100",
				minWidth : "100",
			},
			{ 
				headerText : "센터현재고", 
				dataField : "current_stock", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				width : "100",
				minWidth : "100",
			},
			{ 
				headerText : "전체현재고", 
				dataField : "all_current_stock", 
				style : "aui-center aui-popup",
				dataType : "numeric",
				formatString : "#,##0",
				width : "100",
				minWidth : "100",
			},
		];
	
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// 부품명 셀 클릭 시 부품마스터상세 팝업 호출
			var popupOption = "";
			var param = {
				"part_no" : event.item["part_no"]
			};
			if(event.dataField == 'all_current_stock') {
				$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
			};
		});
		
	}
	
	
	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "출하의뢰 부품현황", "");
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
						<table class="table table-fixed">
							<colgroup>
								<col width="70px">
								<col width="260px">				
								<col width="80px">
								<col width="100px">	
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회기간</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일">
<!-- 													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${inputParam.s_current_dt}">
<!-- 													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
												</div>
											</div>
										</div>
									</td>
									<th>출하예정센터</th>
									<td>
										<select class="form-control" id="s_out_org_code" name="s_out_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${centerList}">
												<c:if test="${list.org_code ne '5110' and list.org_code ne '5120'}">
													<option value="${list.org_code}">${list.org_name}</option>
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
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								기타센터로 표기되는 이유 : 구전산은 센터가 지정되지 않으면 평택으로 집계하지만, 신전산에서는 기타로 분류합니다. 출하센터 지정은 출하의뢰서 관리확인단계에서 합니다.
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height: 550px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
				</div>						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>